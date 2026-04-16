-- P1-09: Create workflow and audit tables
-- Two tables that power the maker/checker validation workflow and the
-- immutable audit trail.
--
-- Tables: control_versions, audit_log
-- Depends on: controls, users (from P1-08)

-- ============================================================
-- 1. CONTROL_VERSIONS — maker/checker staging table
-- ============================================================
-- When a Write user proposes a change (create, update, or retire a
-- control), the proposed data is stored here as a JSON snapshot.
-- A Validate user then approves or rejects the proposal.
-- 
-- control_id is nullable: for a "Create" flow, the control doesn't
-- exist yet, so there's nothing to reference.
CREATE TABLE control_versions (
    -- Primary key
    version_id          NUMBER          NOT NULL,
    -- Which control this version relates to (NULL for new creates)
    control_id          NUMBER,
    -- What kind of change is being proposed
    change_type         VARCHAR2(10)    NOT NULL,
    -- JSON snapshot of the proposed field values
    proposed_data       CLOB            NOT NULL,
    -- Workflow status
    review_status       VARCHAR2(10)    DEFAULT 'Pending' NOT NULL,
    -- Who submitted and when
    submitted_by        NUMBER          NOT NULL,
    submitted_at        TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    -- Who reviewed and when (NULL until reviewed)
    reviewed_by         NUMBER,
    reviewed_at         TIMESTAMP WITH TIME ZONE,
    review_comments     CLOB,
    -- Constraints
    CONSTRAINT pk_control_versions      PRIMARY KEY (version_id),
    CONSTRAINT ck_cv_change_type        CHECK (change_type IN (
        'Create', 'Update', 'Retire'
    )),
    CONSTRAINT ck_cv_status             CHECK (review_status IN (
        'Pending', 'Approved', 'Rejected'
    )),
    CONSTRAINT ck_cv_proposed_json      CHECK (proposed_data IS JSON),
    CONSTRAINT fk_cv_controls           FOREIGN KEY (control_id)
                                        REFERENCES controls (control_id),
    CONSTRAINT fk_cv_submitted          FOREIGN KEY (submitted_by)
                                        REFERENCES users (user_id),
    CONSTRAINT fk_cv_reviewed           FOREIGN KEY (reviewed_by)
                                        REFERENCES users (user_id)
);

-- ============================================================
-- 2. AUDIT_LOG — immutable change history
-- ============================================================
-- Every INSERT, UPDATE, DELETE on key tables is recorded here via
-- AFTER triggers (built in P1-13). Rows in this table must never
-- be modified or deleted (enforced by a trigger in P1-14).
--
-- old_data: NULL for INSERT (no previous state)
-- new_data: NULL for DELETE (no new state)
-- changed_fields: NULL for INSERT/DELETE (delta only applies to UPDATE)
CREATE TABLE audit_log (
    -- Primary key
    log_id              NUMBER          NOT NULL,
    -- What changed
    table_name          VARCHAR2(100)   NOT NULL,
    record_id           NUMBER          NOT NULL,
    action              VARCHAR2(10)    NOT NULL,
    -- JSON snapshots
    old_data            CLOB,
    new_data            CLOB,
    changed_fields      CLOB,
    -- Who and when
    changed_by          VARCHAR2(100),
    changed_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    -- Constraints
    CONSTRAINT pk_audit_log             PRIMARY KEY (log_id),
    CONSTRAINT ck_al_action             CHECK (action IN (
        'INSERT', 'UPDATE', 'DELETE'
    )),
    CONSTRAINT ck_al_old_json           CHECK (old_data IS JSON),
    CONSTRAINT ck_al_new_json           CHECK (new_data IS JSON),
    CONSTRAINT ck_al_delta_json         CHECK (changed_fields IS JSON)
);