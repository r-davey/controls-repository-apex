-- P1-12: Create updated_at triggers
-- Each trigger fires BEFORE UPDATE and sets updated_at to the current
-- timestamp. This ensures updated_at is always accurate without
-- relying on the caller to set it.
--
-- 6 triggers — one per table that has an updated_at column.
-- control_business_entities is excluded (junction rows are
-- created/deleted, not updated — no updated_at column).
--
-- Convention: trg_[table]_updated_at
-- Excluded tables:
--   control_business_entities — junction rows are created/deleted, not updated
--   control_versions — uses submitted_at / reviewed_at instead
--   audit_log — immutable table, uses changed_at only

-- ============================================================
-- LOOKUP TABLES
-- ============================================================

CREATE OR REPLACE TRIGGER trg_roles_updated_at
BEFORE UPDATE ON roles
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_control_types_updated_at
BEFORE UPDATE ON control_types
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_risk_categories_updated_at
BEFORE UPDATE ON risk_categories
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_business_entities_updated_at
BEFORE UPDATE ON business_entities
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- ============================================================
-- CORE TABLES
-- ============================================================

CREATE OR REPLACE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_controls_updated_at
BEFORE UPDATE ON controls
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/
