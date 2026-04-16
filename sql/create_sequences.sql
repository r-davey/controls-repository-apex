-- P1-06: Create sequences for all tables with auto-incrementing PKs
-- Each sequence feeds one table's primary key column.
-- Wiring (via BEFORE INSERT triggers) happens in P1-11.
--
-- Convention: [table_name]_seq
-- Exception:  cbe_seq (short for control_business_entities_seq — kept 
--             brief because Oracle has a 30-character object name limit)

-- Lookup tables
CREATE SEQUENCE roles_seq             START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE control_types_seq     START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE risk_categories_seq   START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE business_entities_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Core tables
CREATE SEQUENCE users_seq             START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE controls_seq          START WITH 1 INCREMENT BY 1 NOCACHE;

-- Junction table
CREATE SEQUENCE cbe_seq               START WITH 1 INCREMENT BY 1 NOCACHE;

-- Workflow and audit tables
CREATE SEQUENCE control_versions_seq  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE audit_log_seq         START WITH 1 INCREMENT BY 1 NOCACHE;