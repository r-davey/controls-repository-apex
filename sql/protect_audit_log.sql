-- P1-14: Protect audit_log from modification
-- This trigger fires BEFORE any UPDATE or DELETE on audit_log and
-- immediately raises an error, blocking the operation.
-- The audit trail is immutable — rows can only be inserted, never
-- modified or removed.
--
-- Uses error code -20001 from Oracle's user-defined range (-20000 to -20999).

CREATE OR REPLACE TRIGGER trg_audit_log_immutable
BEFORE UPDATE OR DELETE ON audit_log
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(
        -20001,
        'audit_log is immutable — UPDATE and DELETE are not permitted'
    );
END;
/