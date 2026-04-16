-- P1-10: PL/SQL practice blocks
-- Five exercises covering the core patterns needed for triggers.
-- Run via SQL Scripts. Each block is independent.
-- Nothing here modifies the schema — purely read-only practice.

-- ============================================================
-- 1. Simple output — confirm PL/SQL blocks execute
-- ============================================================
-- DBMS_OUTPUT.PUT_LINE writes text to the output buffer.
-- In APEX SQL Scripts, output appears in the Detail view.
BEGIN
    DBMS_OUTPUT.PUT_LINE('Block 1: Hello from PL/SQL');
    DBMS_OUTPUT.PUT_LINE('Current time: ' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS'));
END;
/

-- ============================================================
-- 2. Variables and SELECT INTO
-- ============================================================
-- DECLARE creates variables. SELECT INTO populates them from a query.
-- This is how triggers will read values from the database.
DECLARE
    v_table_count   NUMBER;
    v_schema_name   VARCHAR2(100);
BEGIN
    -- Count how many tables exist in the schema
    SELECT COUNT(*) INTO v_table_count FROM user_tables;
    
    -- Get the current schema name
    SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') 
    INTO v_schema_name 
    FROM dual;
    
    DBMS_OUTPUT.PUT_LINE('Block 2: Schema ' || v_schema_name 
        || ' has ' || v_table_count || ' tables');
END;
/

-- ============================================================
-- 3. IF / THEN / ELSE — conditional logic
-- ============================================================
-- Triggers use IF statements constantly: "if the new value differs
-- from the old value, then do something."
DECLARE
    v_table_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_table_count FROM user_tables;
    
    IF v_table_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Block 3: Schema is empty — no tables yet');
    ELSIF v_table_count < 5 THEN
        DBMS_OUTPUT.PUT_LINE('Block 3: Found ' || v_table_count 
            || ' tables — getting started');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Block 3: Found ' || v_table_count 
            || ' tables — schema is taking shape');
    END IF;
END;
/

-- ============================================================
-- 4. Looping with a cursor — iterate over query results
-- ============================================================
-- A cursor FOR loop runs a query and processes each row one at a time.
-- This pattern is useful for bulk operations and reporting.
-- Here we loop through all 9 tables and print their names.
DECLARE
    v_counter NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Block 4: Tables in the schema:');
    
    FOR rec IN (SELECT table_name FROM user_tables ORDER BY table_name) LOOP
        v_counter := v_counter + 1;
        DBMS_OUTPUT.PUT_LINE('  ' || v_counter || '. ' || rec.table_name);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_counter || ' tables');
END;
/

-- ============================================================
-- 5. RAISE_APPLICATION_ERROR — throw a custom error
-- ============================================================
-- This is how you block forbidden actions in a trigger.
-- Error codes must be in the range -20000 to -20999.
-- We'll use this in P1-14 to make audit_log immutable.
--
-- This block deliberately causes an error — that's the point.
-- SQL Scripts will show it as a failed statement. That's expected.
BEGIN
    DBMS_OUTPUT.PUT_LINE('Block 5: About to raise a custom error...');
    RAISE_APPLICATION_ERROR(-20001, 'This is a test error — audit_log is immutable');
END;
/