-- P1-16: Create reporting views
-- Seven views that encapsulate complex joins for reporting consumers
-- (APEX dashboards in Phase 2, Power BI in Phase 3).
--
-- Views: v_control_register, v_control_coverage, v_coverage_summary,
--        v_approval_pipeline, v_audit_trail, v_user_activity,
--        v_control_health

-- ============================================================
-- 1. V_CONTROL_REGISTER — master control view
-- ============================================================
-- Joins controls to owner, type, risk category, and aggregates
-- covered business entities into a comma-separated list.
CREATE OR REPLACE VIEW v_control_register AS
SELECT
    c.control_id,
    c.control_reference,
    c.control_name,
    c.control_description,
    -- Owner: join to users table to get the full name
    u.first_name || ' ' || u.last_name     AS control_owner,
    -- Type and risk: join to lookup tables for display names
    ct.type_name                            AS control_type,
    rc.category_name                        AS risk_category,
    c.control_frequency,
    c.status,
    -- Aggregate entity names into a comma-separated list
    -- LISTAGG is Oracle's equivalent of PostgreSQL's STRING_AGG
    (
        SELECT LISTAGG(be.entity_name, ', ') 
               WITHIN GROUP (ORDER BY be.entity_name)
        FROM control_business_entities cbe
        JOIN business_entities be ON be.entity_id = cbe.entity_id
        WHERE cbe.control_id = c.control_id
    )                                       AS covered_entities,
    c.created_at,
    c.updated_at
FROM controls c
JOIN users u              ON u.user_id = c.control_owner_id
JOIN control_types ct     ON ct.control_type_id = c.control_type_id
JOIN risk_categories rc   ON rc.risk_category_id = c.risk_category_id;

-- ============================================================
-- 2. V_CONTROL_COVERAGE — one row per control-entity pair
-- ============================================================
-- Flat view useful for filtering: "show me all controls that
-- cover Global Markets" or "which entities does CTRL-003 cover?"
CREATE OR REPLACE VIEW v_control_coverage AS
SELECT
    c.control_id,
    c.control_reference,
    c.control_name,
    be.entity_id,
    be.entity_name,
    be.entity_type,
    be.region,
    c.status
FROM controls c
JOIN control_business_entities cbe ON cbe.control_id = c.control_id
JOIN business_entities be          ON be.entity_id = cbe.entity_id;

-- ============================================================
-- 3. V_COVERAGE_SUMMARY — controls per business entity
-- ============================================================
-- Aggregated count: how many active controls cover each entity?
-- Useful for heatmaps and gap analysis in Power BI.
CREATE OR REPLACE VIEW v_coverage_summary AS
SELECT
    be.entity_id,
    be.entity_name,
    be.entity_type,
    be.region,
    COUNT(cbe.control_id)                   AS control_count,
    -- How many of those controls are active?
    SUM(CASE WHEN c.status = 'Active' THEN 1 ELSE 0 END) 
                                            AS active_control_count
FROM business_entities be
LEFT JOIN control_business_entities cbe ON cbe.entity_id = be.entity_id
LEFT JOIN controls c                    ON c.control_id = cbe.control_id
GROUP BY be.entity_id, be.entity_name, be.entity_type, be.region;

-- ============================================================
-- 4. V_APPROVAL_PIPELINE — maker/checker workflow view
-- ============================================================
-- Shows all control versions with human-readable submitter and
-- reviewer names. Used for the validation queue in APEX.
CREATE OR REPLACE VIEW v_approval_pipeline AS
SELECT
    cv.version_id,
    cv.control_id,
    c.control_reference,
    c.control_name,
    cv.change_type,
    cv.proposed_data,
    cv.review_status,
    -- Submitter details
    sub.first_name || ' ' || sub.last_name  AS submitted_by_name,
    cv.submitted_at,
    -- Reviewer details (NULL if not yet reviewed)
    COALESCE(rev.first_name || ' ' || rev.last_name, 'Awaiting review')
                                            AS reviewed_by_name,
    cv.reviewed_at,
    cv.review_comments
FROM control_versions cv
-- LEFT JOIN to controls: control_id is NULL for Create flows
LEFT JOIN controls c    ON c.control_id = cv.control_id
-- INNER JOIN to submitter: always present
JOIN users sub          ON sub.user_id = cv.submitted_by
-- LEFT JOIN to reviewer: NULL until reviewed
LEFT JOIN users rev     ON rev.user_id = cv.reviewed_by;

-- ============================================================
-- 5. V_AUDIT_TRAIL — human-readable audit log
-- ============================================================
-- Formats the audit_log with readable timestamps and exposes
-- the JSON data for downstream parsing.
CREATE OR REPLACE VIEW v_audit_trail AS
SELECT
    al.log_id,
    al.table_name,
    al.record_id,
    al.action,
    al.old_data,
    al.new_data,
    al.changed_fields,
    al.changed_by,
    al.changed_at,
    -- Formatted timestamp for display
    TO_CHAR(al.changed_at, 'YYYY-MM-DD HH24:MI:SS') AS changed_at_formatted
FROM audit_log al
ORDER BY al.changed_at DESC;

-- ============================================================
-- 6. V_USER_ACTIVITY — user workload summary
-- ============================================================
-- How many controls each user owns, how many versions they've
-- submitted, how many they've reviewed. Useful for workload
-- analysis and audit.
CREATE OR REPLACE VIEW v_user_activity AS
SELECT
    u.user_id,
    u.employee_id,
    u.first_name || ' ' || u.last_name      AS full_name,
    r.role_name,
    u.is_active,
    -- Controls owned by this user
    (SELECT COUNT(*) FROM controls c 
     WHERE c.control_owner_id = u.user_id)   AS controls_owned,
    -- Versions submitted (maker activity)
    (SELECT COUNT(*) FROM control_versions cv 
     WHERE cv.submitted_by = u.user_id)      AS versions_submitted,
    -- Versions reviewed (checker activity)
    (SELECT COUNT(*) FROM control_versions cv 
     WHERE cv.reviewed_by = u.user_id)       AS versions_reviewed
FROM users u
JOIN roles r ON r.role_id = u.role_id;

-- ============================================================
-- 7. V_CONTROL_HEALTH — controls that may need attention
-- ============================================================
-- Flags potential issues:
--   - Controls with zero entity coverage
--   - Controls with pending versions awaiting review
--   - Retired controls (for review/cleanup)
CREATE OR REPLACE VIEW v_control_health AS
SELECT
    c.control_id,
    c.control_reference,
    c.control_name,
    u.first_name || ' ' || u.last_name       AS control_owner,
    c.status,
    -- Count of business entities covered
    (SELECT COUNT(*) FROM control_business_entities cbe
     WHERE cbe.control_id = c.control_id)    AS entity_coverage_count,
    -- Count of pending versions awaiting review
    (SELECT COUNT(*) FROM control_versions cv
     WHERE cv.control_id = c.control_id
     AND cv.review_status = 'Pending')       AS pending_versions,
    -- Health flag
    CASE
        WHEN c.status = 'Retired' THEN 'Retired'
        WHEN (SELECT COUNT(*) FROM control_business_entities cbe
              WHERE cbe.control_id = c.control_id) = 0 
            THEN 'No coverage'
        WHEN (SELECT COUNT(*) FROM control_versions cv
              WHERE cv.control_id = c.control_id
              AND cv.review_status = 'Pending') > 0 
            THEN 'Pending changes'
        ELSE 'Healthy'
    END                                      AS health_status
FROM controls c
JOIN users u ON u.user_id = c.control_owner_id;