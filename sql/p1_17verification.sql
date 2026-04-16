-- P1-17: Schema verification queries
-- Structured test of the entire Phase 1 schema: tables, triggers,
-- views, constraints, and data integrity.
--
-- Run via SQL Scripts. Expected result: all statements succeed
-- except the deliberate constraint violation tests (which should
-- error — proving the constraints work).

-- ============================================================
-- TEST 1: ROW COUNTS — verify seed data volumes
-- ============================================================
-- Expected: roles=3, control_types=3, risk_categories=6,
--   business_entities=10, users=7, controls=15, CBE=45,
--   control_versions=7, audit_log=67
SELECT 'Row Counts' AS test_group,
    (SELECT COUNT(*) FROM roles)                     AS roles,
    (SELECT COUNT(*) FROM control_types)             AS control_types,
    (SELECT COUNT(*) FROM risk_categories)           AS risk_categories,
    (SELECT COUNT(*) FROM business_entities)         AS business_entities,
    (SELECT COUNT(*) FROM users)                     AS users_tbl,
    (SELECT COUNT(*) FROM controls)                  AS controls,
    (SELECT COUNT(*) FROM control_business_entities) AS cbe,
    (SELECT COUNT(*) FROM control_versions)          AS control_versions,
    (SELECT COUNT(*) FROM audit_log)                 AS audit_log
FROM dual;

-- ============================================================
-- TEST 2: FOREIGN KEY INTEGRITY — no orphaned references
-- ============================================================
-- Every user should have a valid role
SELECT 'FK: users→roles' AS test_name, COUNT(*) AS orphaned_rows
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM roles r WHERE r.role_id = u.role_id
);

-- Every control should have a valid owner, type, and risk category
SELECT 'FK: controls→users' AS test_name, COUNT(*) AS orphaned_rows
FROM controls c
WHERE NOT EXISTS (
    SELECT 1 FROM users u WHERE u.user_id = c.control_owner_id
);

SELECT 'FK: controls→control_types' AS test_name, COUNT(*) AS orphaned_rows
FROM controls c
WHERE NOT EXISTS (
    SELECT 1 FROM control_types ct WHERE ct.control_type_id = c.control_type_id
);

SELECT 'FK: controls→risk_categories' AS test_name, COUNT(*) AS orphaned_rows
FROM controls c
WHERE NOT EXISTS (
    SELECT 1 FROM risk_categories rc WHERE rc.risk_category_id = c.risk_category_id
);

-- Every CBE row should reference a valid control and entity
SELECT 'FK: CBE→controls' AS test_name, COUNT(*) AS orphaned_rows
FROM control_business_entities cbe
WHERE NOT EXISTS (
    SELECT 1 FROM controls c WHERE c.control_id = cbe.control_id
);

SELECT 'FK: CBE→business_entities' AS test_name, COUNT(*) AS orphaned_rows
FROM control_business_entities cbe
WHERE NOT EXISTS (
    SELECT 1 FROM business_entities be WHERE be.entity_id = cbe.entity_id
);

-- All orphaned_rows counts should be 0

-- ============================================================
-- TEST 3: TRIGGER BEHAVIOUR — auto-increment and updated_at
-- ============================================================
-- Insert a role without specifying an ID — trigger should assign one
INSERT INTO roles (role_name, role_description)
VALUES ('Trigger Test Role', 'Testing auto-increment trigger');

-- Verify the ID was assigned (should be >= 4 since sequences were reset)
SELECT 'Auto-increment test' AS test_name, role_id, role_name
FROM roles WHERE role_name = 'Trigger Test Role';

-- Update the role — updated_at trigger should fire
UPDATE roles SET role_description = 'Modified by test'
WHERE role_name = 'Trigger Test Role';

-- Verify updated_at is now populated
SELECT 'Updated_at test' AS test_name, role_id,
    CASE WHEN updated_at IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS result
FROM roles WHERE role_name = 'Trigger Test Role';

-- Clean up the test role
DELETE FROM roles WHERE role_name = 'Trigger Test Role';

-- ============================================================
-- TEST 4: AUDIT TRAIL — verify triggers logged the controls inserts
-- ============================================================
-- Count audit entries by table — should match seed data inserts
SELECT table_name, action, COUNT(*) AS entry_count
FROM audit_log
GROUP BY table_name, action
ORDER BY table_name, action;

-- Verify audit entries have valid JSON in new_data
-- This checks a sample — if the IS JSON constraint passed on insert,
-- the data is valid, but let's confirm with a query
SELECT 'Audit JSON validity' AS test_name,
    COUNT(*) AS total_entries,
    SUM(CASE WHEN new_data IS JSON THEN 1 ELSE 0 END) AS valid_new_json,
    SUM(CASE WHEN old_data IS JSON OR old_data IS NULL THEN 1 ELSE 0 END) AS valid_old_json
FROM audit_log;

-- ============================================================
-- TEST 5: AUDIT LOG IMMUTABILITY — UPDATE and DELETE blocked
-- ============================================================
-- These two statements SHOULD fail with ORA-20001.
-- SQL Scripts will show them as errors — that is the correct outcome.

-- Attempt to update an audit record (should fail)
UPDATE audit_log SET action = 'TAMPERED' WHERE log_id = 1;

-- Attempt to delete an audit record (should fail)
DELETE FROM audit_log WHERE log_id = 1;

-- ============================================================
-- TEST 6: CONSTRAINT ENFORCEMENT — invalid data rejected
-- ============================================================
-- These statements SHOULD fail — proving constraints work.

-- Invalid control frequency (should fail: CHECK constraint)
INSERT INTO controls (control_reference, control_name, control_owner_id, 
    control_type_id, risk_category_id, control_frequency, status)
VALUES ('CTRL-BAD', 'Bad Frequency', 1, 1, 1, 'Biweekly', 'Active');

-- Invalid status (should fail: CHECK constraint)
INSERT INTO controls (control_reference, control_name, control_owner_id, 
    control_type_id, risk_category_id, control_frequency, status)
VALUES ('CTRL-BAD', 'Bad Status', 1, 1, 1, 'Daily', 'Unknown');

-- Duplicate control reference (should fail: UNIQUE constraint)
INSERT INTO controls (control_reference, control_name, control_owner_id, 
    control_type_id, risk_category_id, control_frequency, status)
VALUES ('CTRL-001', 'Duplicate Ref Test', 1, 1, 1, 'Daily', 'Active');

-- Invalid FK — non-existent user (should fail: FK constraint)
INSERT INTO controls (control_reference, control_name, control_owner_id, 
    control_type_id, risk_category_id, control_frequency, status)
VALUES ('CTRL-BAD', 'Bad Owner', 999, 1, 1, 'Daily', 'Active');

-- ============================================================
-- TEST 7: VIEW OUTPUT — all 7 views return data
-- ============================================================
SELECT 'v_control_register' AS view_name, COUNT(*) AS row_count 
FROM v_control_register;

SELECT 'v_control_coverage' AS view_name, COUNT(*) AS row_count 
FROM v_control_coverage;

SELECT 'v_coverage_summary' AS view_name, COUNT(*) AS row_count 
FROM v_coverage_summary;

SELECT 'v_approval_pipeline' AS view_name, COUNT(*) AS row_count 
FROM v_approval_pipeline;

SELECT 'v_audit_trail' AS view_name, COUNT(*) AS row_count 
FROM v_audit_trail;

SELECT 'v_user_activity' AS view_name, COUNT(*) AS row_count 
FROM v_user_activity;

SELECT 'v_control_health' AS view_name, COUNT(*) AS row_count 
FROM v_control_health;