-- P1-13: Create audit trail triggers
-- AFTER INSERT/UPDATE/DELETE triggers on three business tables that log
-- every change to audit_log with JSON snapshots of old/new data and
-- a delta of changed fields.
--
-- Tables audited: controls, control_versions, control_business_entities
-- Target table:   audit_log
--
-- JSON includes core business fields only (not CLOBs or audit metadata).
-- Convention: trg_[table]_audit

-- ============================================================
-- 1. CONTROLS — the control register audit trigger
-- ============================================================
-- Tracks: control_id, control_reference, control_name,
--         control_owner_id, control_type_id, risk_category_id,
--         control_frequency, status
-- Skips:  control_description (CLOB), audit metadata columns
CREATE OR REPLACE TRIGGER trg_controls_audit
AFTER INSERT OR UPDATE OR DELETE ON controls
FOR EACH ROW
DECLARE
    v_action    VARCHAR2(10);
    v_record_id NUMBER;
    v_old_data  CLOB := NULL;
    v_new_data  CLOB := NULL;
    v_changed   CLOB := NULL;
    v_sep       VARCHAR2(1) := '';
BEGIN
    -- Determine which DML operation fired the trigger
    IF INSERTING THEN
        v_action    := 'INSERT';
        v_record_id := :NEW.control_id;
    ELSIF UPDATING THEN
        v_action    := 'UPDATE';
        v_record_id := :NEW.control_id;
    ELSIF DELETING THEN
        v_action    := 'DELETE';
        v_record_id := :OLD.control_id;
    END IF;

    -- Build old_data JSON (UPDATE and DELETE only)
    IF UPDATING OR DELETING THEN
        v_old_data := '{'
            || '"control_id":'          || :OLD.control_id
            || ',"control_reference":"' || :OLD.control_reference || '"'
            || ',"control_name":"'      || :OLD.control_name || '"'
            || ',"control_owner_id":'   || :OLD.control_owner_id
            || ',"control_type_id":'    || :OLD.control_type_id
            || ',"risk_category_id":'   || :OLD.risk_category_id
            || ',"control_frequency":"' || :OLD.control_frequency || '"'
            || ',"status":"'            || :OLD.status || '"'
            || '}';
    END IF;

    -- Build new_data JSON (INSERT and UPDATE only)
    IF INSERTING OR UPDATING THEN
        v_new_data := '{'
            || '"control_id":'          || :NEW.control_id
            || ',"control_reference":"' || :NEW.control_reference || '"'
            || ',"control_name":"'      || :NEW.control_name || '"'
            || ',"control_owner_id":'   || :NEW.control_owner_id
            || ',"control_type_id":'    || :NEW.control_type_id
            || ',"risk_category_id":'   || :NEW.risk_category_id
            || ',"control_frequency":"' || :NEW.control_frequency || '"'
            || ',"status":"'            || :NEW.status || '"'
            || '}';
    END IF;

    -- Build changed_fields delta (UPDATE only)
    -- Each entry shows the old and new value for fields that differ.
    IF UPDATING THEN
        v_changed := '{';

        IF :OLD.control_reference != :NEW.control_reference THEN
            v_changed := v_changed || v_sep
                || '"control_reference":{"old":"' || :OLD.control_reference
                || '","new":"' || :NEW.control_reference || '"}';
            v_sep := ',';
        END IF;

        IF :OLD.control_name != :NEW.control_name THEN
            v_changed := v_changed || v_sep
                || '"control_name":{"old":"' || :OLD.control_name
                || '","new":"' || :NEW.control_name || '"}';
            v_sep := ',';
        END IF;

        IF :OLD.control_owner_id != :NEW.control_owner_id THEN
            v_changed := v_changed || v_sep
                || '"control_owner_id":{"old":' || :OLD.control_owner_id
                || ',"new":' || :NEW.control_owner_id || '}';
            v_sep := ',';
        END IF;

        IF :OLD.control_type_id != :NEW.control_type_id THEN
            v_changed := v_changed || v_sep
                || '"control_type_id":{"old":' || :OLD.control_type_id
                || ',"new":' || :NEW.control_type_id || '}';
            v_sep := ',';
        END IF;

        IF :OLD.risk_category_id != :NEW.risk_category_id THEN
            v_changed := v_changed || v_sep
                || '"risk_category_id":{"old":' || :OLD.risk_category_id
                || ',"new":' || :NEW.risk_category_id || '}';
            v_sep := ',';
        END IF;

        IF :OLD.control_frequency != :NEW.control_frequency THEN
            v_changed := v_changed || v_sep
                || '"control_frequency":{"old":"' || :OLD.control_frequency
                || '","new":"' || :NEW.control_frequency || '"}';
            v_sep := ',';
        END IF;

        IF :OLD.status != :NEW.status THEN
            v_changed := v_changed || v_sep
                || '"status":{"old":"' || :OLD.status
                || '","new":"' || :NEW.status || '"}';
            v_sep := ',';
        END IF;

        v_changed := v_changed || '}';
    END IF;

    -- Write the audit record
    INSERT INTO audit_log (
        table_name, record_id, action,
        old_data, new_data, changed_fields,
        changed_by, changed_at
    ) VALUES (
        'CONTROLS', v_record_id, v_action,
        v_old_data, v_new_data, v_changed,
        SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'),
        SYSTIMESTAMP
    );
END;
/

-- ============================================================
-- 2. CONTROL_VERSIONS — maker/checker workflow audit trigger
-- ============================================================
-- Tracks: version_id, control_id (nullable), change_type,
--         review_status, submitted_by, reviewed_by (nullable)
-- Skips:  proposed_data (CLOB), review_comments (CLOB),
--         submitted_at, reviewed_at
CREATE OR REPLACE TRIGGER trg_control_versions_audit
AFTER INSERT OR UPDATE OR DELETE ON control_versions
FOR EACH ROW
DECLARE
    v_action    VARCHAR2(10);
    v_record_id NUMBER;
    v_old_data  CLOB := NULL;
    v_new_data  CLOB := NULL;
    v_changed   CLOB := NULL;
    v_sep       VARCHAR2(1) := '';
BEGIN
    IF INSERTING THEN
        v_action    := 'INSERT';
        v_record_id := :NEW.version_id;
    ELSIF UPDATING THEN
        v_action    := 'UPDATE';
        v_record_id := :NEW.version_id;
    ELSIF DELETING THEN
        v_action    := 'DELETE';
        v_record_id := :OLD.version_id;
    END IF;

    -- Build old_data JSON
    -- NVL handles nullable fields: outputs the value or JSON null
    IF UPDATING OR DELETING THEN
        v_old_data := '{'
            || '"version_id":'    || :OLD.version_id
            || ',"control_id":'   || NVL(TO_CHAR(:OLD.control_id), 'null')
            || ',"change_type":"' || :OLD.change_type || '"'
            || ',"review_status":"' || :OLD.review_status || '"'
            || ',"submitted_by":' || :OLD.submitted_by
            || ',"reviewed_by":'  || NVL(TO_CHAR(:OLD.reviewed_by), 'null')
            || '}';
    END IF;

    -- Build new_data JSON
    IF INSERTING OR UPDATING THEN
        v_new_data := '{'
            || '"version_id":'    || :NEW.version_id
            || ',"control_id":'   || NVL(TO_CHAR(:NEW.control_id), 'null')
            || ',"change_type":"' || :NEW.change_type || '"'
            || ',"review_status":"' || :NEW.review_status || '"'
            || ',"submitted_by":' || :NEW.submitted_by
            || ',"reviewed_by":'  || NVL(TO_CHAR(:NEW.reviewed_by), 'null')
            || '}';
    END IF;

    -- Build changed_fields delta
    -- Nullable fields use NVL for safe comparison
    IF UPDATING THEN
        v_changed := '{';

        IF NVL(TO_CHAR(:OLD.control_id), 'NULL') 
            != NVL(TO_CHAR(:NEW.control_id), 'NULL') THEN
            v_changed := v_changed || v_sep
                || '"control_id":{"old":' || NVL(TO_CHAR(:OLD.control_id), 'null')
                || ',"new":' || NVL(TO_CHAR(:NEW.control_id), 'null') || '}';
            v_sep := ',';
        END IF;

        IF :OLD.change_type != :NEW.change_type THEN
            v_changed := v_changed || v_sep
                || '"change_type":{"old":"' || :OLD.change_type
                || '","new":"' || :NEW.change_type || '"}';
            v_sep := ',';
        END IF;

        IF :OLD.review_status != :NEW.review_status THEN
            v_changed := v_changed || v_sep
                || '"review_status":{"old":"' || :OLD.review_status
                || '","new":"' || :NEW.review_status || '"}';
            v_sep := ',';
        END IF;

        IF :OLD.submitted_by != :NEW.submitted_by THEN
            v_changed := v_changed || v_sep
                || '"submitted_by":{"old":' || :OLD.submitted_by
                || ',"new":' || :NEW.submitted_by || '}';
            v_sep := ',';
        END IF;

        IF NVL(TO_CHAR(:OLD.reviewed_by), 'NULL') 
            != NVL(TO_CHAR(:NEW.reviewed_by), 'NULL') THEN
            v_changed := v_changed || v_sep
                || '"reviewed_by":{"old":' || NVL(TO_CHAR(:OLD.reviewed_by), 'null')
                || ',"new":' || NVL(TO_CHAR(:NEW.reviewed_by), 'null') || '}';
            v_sep := ',';
        END IF;

        v_changed := v_changed || '}';
    END IF;

    INSERT INTO audit_log (
        table_name, record_id, action,
        old_data, new_data, changed_fields,
        changed_by, changed_at
    ) VALUES (
        'CONTROL_VERSIONS', v_record_id, v_action,
        v_old_data, v_new_data, v_changed,
        SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'),
        SYSTIMESTAMP
    );
END;
/

-- ============================================================
-- 3. CONTROL_BUSINESS_ENTITIES — junction table audit trigger
-- ============================================================
-- INSERT and DELETE only — junction rows are not updated.
-- Tracks: control_entity_id, control_id, entity_id
-- All fields are NOT NULL so no NVL handling needed.
CREATE OR REPLACE TRIGGER trg_cbe_audit
AFTER INSERT OR DELETE ON control_business_entities
FOR EACH ROW
DECLARE
    v_action    VARCHAR2(10);
    v_record_id NUMBER;
    v_old_data  CLOB := NULL;
    v_new_data  CLOB := NULL;
BEGIN
    IF INSERTING THEN
        v_action    := 'INSERT';
        v_record_id := :NEW.control_entity_id;

        v_new_data := '{'
            || '"control_entity_id":' || :NEW.control_entity_id
            || ',"control_id":'       || :NEW.control_id
            || ',"entity_id":'        || :NEW.entity_id
            || '}';

    ELSIF DELETING THEN
        v_action    := 'DELETE';
        v_record_id := :OLD.control_entity_id;

        v_old_data := '{'
            || '"control_entity_id":' || :OLD.control_entity_id
            || ',"control_id":'       || :OLD.control_id
            || ',"entity_id":'        || :OLD.entity_id
            || '}';
    END IF;

    -- No changed_fields — junction rows are never updated
    INSERT INTO audit_log (
        table_name, record_id, action,
        old_data, new_data, changed_fields,
        changed_by, changed_at
    ) VALUES (
        'CONTROL_BUSINESS_ENTITIES', v_record_id, v_action,
        v_old_data, v_new_data, NULL,
        SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'),
        SYSTIMESTAMP
    );
END;
/