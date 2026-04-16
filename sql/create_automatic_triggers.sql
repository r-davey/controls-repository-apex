-- P1-11: Create auto-increment triggers
-- Each trigger fires BEFORE INSERT on its table and populates the
-- primary key column from the corresponding sequence (created in P1-06).
--
-- Pattern: IF :NEW.pk_col IS NULL THEN assign from sequence END IF;
-- This respects explicitly provided IDs (useful for seed data).
--
-- Convention: trg_[table]_id

-- ============================================================
-- LOOKUP TABLES
-- ============================================================

CREATE OR REPLACE TRIGGER trg_roles_id
BEFORE INSERT ON roles
FOR EACH ROW
BEGIN
    IF :NEW.role_id IS NULL THEN
        :NEW.role_id := roles_seq.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_control_types_id
BEFORE INSERT ON control_types
FOR EACH ROW
BEGIN
    IF :NEW.control_type_id IS NULL THEN
        :NEW.control_type_id := control_types_seq.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_risk_categories_id
BEFORE INSERT ON risk_categories
FOR EACH ROW
BEGIN
    IF :NEW.risk_category_id IS NULL THEN
        :NEW.risk_category_id := risk_categories_seq.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_business_entities_id
BEFORE INSERT ON business_entities
FOR EACH ROW
BEGIN
    IF :NEW.entity_id IS NULL THEN
        :NEW.entity_id := business_entities_seq.NEXTVAL;
    END IF;
END;
/

-- ============================================================
-- CORE TABLES
-- ============================================================

CREATE OR REPLACE TRIGGER trg_users_id
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        :NEW.user_id := users_seq.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_controls_id
BEFORE INSERT ON controls
FOR EACH ROW
BEGIN
    IF :NEW.control_id IS NULL THEN
        :NEW.control_id := controls_seq.NEXTVAL;
    END IF;
END;
/

-- ============================================================
-- JUNCTION TABLE
-- ============================================================

CREATE OR REPLACE TRIGGER trg_cbe_id
BEFORE INSERT ON control_business_entities
FOR EACH ROW
BEGIN
    IF :NEW.control_entity_id IS NULL THEN
        :NEW.control_entity_id := cbe_seq.NEXTVAL;
    END IF;
END;
/

-- ============================================================
-- WORKFLOW AND AUDIT TABLES
-- ============================================================

CREATE OR REPLACE TRIGGER trg_control_versions_id
BEFORE INSERT ON control_versions
FOR EACH ROW
BEGIN
    IF :NEW.version_id IS NULL THEN
        :NEW.version_id := control_versions_seq.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_log_id
BEFORE INSERT ON audit_log
FOR EACH ROW
BEGIN
    IF :NEW.log_id IS NULL THEN
        :NEW.log_id := audit_log_seq.NEXTVAL;
    END IF;
END;
/