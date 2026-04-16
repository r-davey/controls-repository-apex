-- P1-05 Verification Script
-- Purpose: exercise several of the Oracle-vs-PostgreSQL differences
-- documented in docs/oracle_vs_postgresql.md against the live database,
-- so they stick in memory as real behaviour rather than written notes.
--
-- Nothing here creates or modifies any objects — it's all read-only.
--
-- How to run in APEX SQL Commands:
--   APEX SQL Commands runs one statement at a time. For each of the four
--   blocks below, highlight the block (from its opening comment down to
--   its terminating semicolon or the lone '/'), then click Run.
--   From P1-06 onwards we'll use SQL Scripts for multi-statement files.

-- 1. DUAL + SYSTIMESTAMP + USER + string concatenation with ||
SELECT 
    SYSTIMESTAMP                             AS current_timestamp,
    USER                                     AS connected_as,
    'Hello from ' || USER || '@' || 'Oracle' AS greeting
FROM dual;

-- 2. Data dictionary lookup — confirm schema is still empty.
-- USER_TABLES is an Oracle built-in view listing tables in YOUR schema.
-- Should return zero rows at this stage — we haven't created any tables yet.
SELECT table_name 
FROM user_tables
ORDER BY table_name;

-- 3. NVL vs COALESCE — both work, both return 'fallback value' here
SELECT 
    NVL(NULL, 'fallback value')       AS nvl_result,
    COALESCE(NULL, 'fallback value')  AS coalesce_result
FROM dual;

-- 4. An anonymous PL/SQL block — declares a variable, runs a query,
--    prints the result. Proves DECLARE/BEGIN/END; + / works as expected.
DECLARE
    v_table_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_table_count FROM user_tables;
    DBMS_OUTPUT.PUT_LINE('Tables in my schema: ' || v_table_count);
    DBMS_OUTPUT.PUT_LINE('Schema name:         ' || USER);
END;
/