# PL/SQL Basics — Notes from P1-10

Personal reference for PL/SQL patterns I'll use in triggers and procedures.

---

## Block structure

```sql
DECLARE    -- optional: variables
BEGIN      -- mandatory: executable code
EXCEPTION  -- optional: error handling
END;
/          -- execute the block
```

## Key patterns

1. **DBMS_OUTPUT.PUT_LINE('msg')** — debug output (like RAISE NOTICE in PL/pgSQL)
2. **SELECT ... INTO v_variable** — pull a query result into a variable
3. **IF / ELSIF / ELSE / END IF** — conditional logic (note: ELSIF, not ELSEIF)
4. **FOR rec IN (SELECT ...) LOOP ... END LOOP** — cursor loop over query results
5. **RAISE_APPLICATION_ERROR(-20001, 'msg')** — throw a custom error (codes -20000 to -20999)

## Differences from PL/pgSQL

| Concept                | PL/pgSQL                    | PL/SQL                                    |
|------------------------|-----------------------------|--------------------------------------------|
| Block delimiters       | `$$ ... $$`                 | `BEGIN ... END; /`                         |
| Trigger row reference  | `NEW.col`, `OLD.col`        | `:NEW.col`, `:OLD.col` (colon prefix)      |
| Assignment             | `:=`                        | `:=` (same)                                |
| Debug output           | `RAISE NOTICE`              | `DBMS_OUTPUT.PUT_LINE`                     |
| Custom error           | `RAISE EXCEPTION`           | `RAISE_APPLICATION_ERROR(-20001, 'msg')`   |
| Format timestamp       | `to_char(now(), '...')`     | `TO_CHAR(SYSTIMESTAMP, '...')`             |
| Get schema name        | `current_schema`            | `SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')` |

## What I proved in the practice script

- Blocks 1-4 all ran successfully — basic output, variables, conditionals, loops
- Block 5 deliberately threw ORA-20001 — confirms RAISE_APPLICATION_ERROR works
- SYS_CONTEXT returns CONTROLS (the real schema), unlike USER which returns 
  ORDS_PLSQL_GATEWAY in APEX