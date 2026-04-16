-- P1-15: Insert seed data
-- Realistic seed data for a CIB controls repository.
-- Insert order follows foreign key dependencies.
--
-- Counts: 3 roles, 3 control types, 6 risk categories,
--         10 business entities, 7 users, 15 controls,
--         45 entity mappings, 7 control versions
--
-- Explicit IDs are provided — auto-increment triggers respect these
-- (they only assign from the sequence when the ID is NULL).
-- Sequences are reset at the end to avoid future PK conflicts.

-- ============================================================
-- STEP 0: Clean up test data from P1-14
-- ============================================================
-- The audit_log immutability trigger must be temporarily disabled
-- to delete the test row inserted during P1-14 verification.
ALTER TRIGGER trg_audit_log_immutable DISABLE;

DELETE FROM audit_log WHERE table_name = 'TEST';

ALTER TRIGGER trg_audit_log_immutable ENABLE;

-- ============================================================
-- STEP 1: ROLES (3 rows)
-- ============================================================
INSERT INTO roles (role_id, role_name, role_description)
VALUES (1, 'Read Only', 'View-only access to controls, reports, and dashboards');

INSERT INTO roles (role_id, role_name, role_description)
VALUES (2, 'Write', 'Can propose control changes — maker role in the four-eyes workflow');

INSERT INTO roles (role_id, role_name, role_description)
VALUES (3, 'Validate', 'Can approve or reject proposed changes — checker role in the four-eyes workflow');

-- ============================================================
-- STEP 2: CONTROL_TYPES (3 rows)
-- ============================================================
INSERT INTO control_types (control_type_id, type_name, type_description)
VALUES (1, 'Preventive', 'Prevents risk events from occurring before they happen');

INSERT INTO control_types (control_type_id, type_name, type_description)
VALUES (2, 'Detective', 'Identifies and flags risk events after they have occurred');

INSERT INTO control_types (control_type_id, type_name, type_description)
VALUES (3, 'Corrective', 'Remedies or mitigates risk events after detection');

-- ============================================================
-- STEP 3: RISK_CATEGORIES (6 rows)
-- ============================================================
INSERT INTO risk_categories (risk_category_id, category_name, category_description)
VALUES (1, 'Market Risk', 'Risk of losses from movements in market prices — rates, FX, equities, commodities');

INSERT INTO risk_categories (risk_category_id, category_name, category_description)
VALUES (2, 'Credit Risk', 'Risk of loss from counterparty failure to meet contractual obligations');

INSERT INTO risk_categories (risk_category_id, category_name, category_description)
VALUES (3, 'Operational Risk', 'Risk of loss from failed internal processes, people, systems, or external events');

INSERT INTO risk_categories (risk_category_id, category_name, category_description)
VALUES (4, 'Liquidity Risk', 'Risk of inability to meet short-term financial obligations without significant loss');

INSERT INTO risk_categories (risk_category_id, category_name, category_description)
VALUES (5, 'Compliance Risk', 'Risk of regulatory sanctions or financial loss from failure to comply with laws and regulations');

INSERT INTO risk_categories (risk_category_id, category_name, category_description)
VALUES (6, 'Conduct Risk', 'Risk of inappropriate behaviour or business practices harming clients or market integrity');

-- ============================================================
-- STEP 4: BUSINESS_ENTITIES (10 rows)
-- ============================================================
INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (1, 'Global Markets', 'Division', 'EMEA');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (2, 'Corporate Banking', 'Division', 'EMEA');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (3, 'Securities Services', 'Division', 'Global');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (4, 'Equity Derivatives', 'Desk', 'EMEA');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (5, 'Fixed Income', 'Desk', 'EMEA');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (6, 'FX Trading', 'Desk', 'Global');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (7, 'Prime Brokerage', 'Desk', 'APAC');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (8, 'EMEA Region', 'Region', 'EMEA');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (9, 'APAC Region', 'Region', 'APAC');

INSERT INTO business_entities (entity_id, entity_name, entity_type, region)
VALUES (10, 'Americas Region', 'Region', 'Americas');

-- ============================================================
-- STEP 5: USERS (7 rows)
-- role_id references: 1=Read Only, 2=Write, 3=Validate
-- ============================================================
INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (1, 'EMP001', 'Alice', 'Martin', 'alice.martin@bnp-demo.com', 2);

INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (2, 'EMP002', 'Bob', 'Chen', 'bob.chen@bnp-demo.com', 3);

INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (3, 'EMP003', 'Claire', 'Dubois', 'claire.dubois@bnp-demo.com', 2);

INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (4, 'EMP004', 'David', 'Okafor', 'david.okafor@bnp-demo.com', 1);

INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (5, 'EMP005', 'Emma', 'Wilson', 'emma.wilson@bnp-demo.com', 3);

INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (6, 'EMP006', 'Farid', 'Hassan', 'farid.hassan@bnp-demo.com', 2);

INSERT INTO users (user_id, employee_id, first_name, last_name, email, role_id)
VALUES (7, 'EMP007', 'Grace', 'Kim', 'grace.kim@bnp-demo.com', 1);

-- ============================================================
-- STEP 6: CONTROLS (15 rows)
-- These inserts WILL fire trg_controls_audit → audit_log rows
-- control_owner_id references users: 1=Alice, 3=Claire, 6=Farid
-- control_type_id: 1=Preventive, 2=Detective, 3=Corrective
-- risk_category_id: 1=Market, 2=Credit, 3=Operational,
--                   4=Liquidity, 5=Compliance, 6=Conduct
-- ============================================================
INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (1, 'CTRL-001', 'Daily P&L Reconciliation', 1, 1, 1, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (2, 'CTRL-002', 'Trade Confirmation Matching', 1, 2, 3, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (3, 'CTRL-003', 'Credit Limit Monitoring', 3, 1, 2, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (4, 'CTRL-004', 'KYC Periodic Review', 6, 1, 5, 'Quarterly', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (5, 'CTRL-005', 'Unauthorised Trading Detection', 1, 2, 6, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (6, 'CTRL-006', 'Liquidity Coverage Ratio Check', 3, 1, 4, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (7, 'CTRL-007', 'Market Risk Limit Breach Escalation', 6, 3, 1, 'Ad-Hoc', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (8, 'CTRL-008', 'Client Money Segregation', 1, 1, 5, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (9, 'CTRL-009', 'Failed Trade Monitoring', 3, 2, 3, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (10, 'CTRL-010', 'Sanctions Screening', 6, 1, 5, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (11, 'CTRL-011', 'Model Validation Review', 1, 2, 1, 'Annual', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (12, 'CTRL-012', 'Collateral Margin Call', 3, 1, 2, 'Daily', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (13, 'CTRL-013', 'Best Execution Monitoring', 6, 2, 6, 'Monthly', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (14, 'CTRL-014', 'Operational Incident Reporting', 1, 3, 3, 'Ad-Hoc', 'Active');

INSERT INTO controls (control_id, control_reference, control_name, control_owner_id, control_type_id, risk_category_id, control_frequency, status)
VALUES (15, 'CTRL-015', 'Regulatory Reporting Submission', 3, 1, 5, 'Monthly', 'Active');

-- ============================================================
-- STEP 7: CONTROL_BUSINESS_ENTITIES (45 rows — 3 per control)
-- These inserts WILL fire trg_cbe_audit → audit_log rows
-- entity_id: 1=Global Markets, 2=Corp Banking, 3=Sec Services,
--            4=Eq Deriv, 5=Fixed Income, 6=FX Trading,
--            7=Prime Brokerage, 8=EMEA, 9=APAC, 10=Americas
-- ============================================================
-- CTRL-001: Global Markets, Equity Derivatives, EMEA
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (1, 1, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (2, 1, 4);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (3, 1, 8);
-- CTRL-002: Global Markets, Fixed Income, EMEA
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (4, 2, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (5, 2, 5);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (6, 2, 8);
-- CTRL-003: Corporate Banking, Fixed Income, EMEA
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (7, 3, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (8, 3, 5);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (9, 3, 8);
-- CTRL-004: Corporate Banking, Securities Services, Global Markets
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (10, 4, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (11, 4, 3);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (12, 4, 1);
-- CTRL-005: Global Markets, Equity Derivatives, FX Trading
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (13, 5, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (14, 5, 4);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (15, 5, 6);
-- CTRL-006: Global Markets, Corporate Banking, EMEA
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (16, 6, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (17, 6, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (18, 6, 8);
-- CTRL-007: Global Markets, Equity Derivatives, Fixed Income
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (19, 7, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (20, 7, 4);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (21, 7, 5);
-- CTRL-008: Securities Services, Prime Brokerage, APAC
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (22, 8, 3);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (23, 8, 7);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (24, 8, 9);
-- CTRL-009: Global Markets, Fixed Income, FX Trading
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (25, 9, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (26, 9, 5);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (27, 9, 6);
-- CTRL-010: Corporate Banking, Securities Services, Americas
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (28, 10, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (29, 10, 3);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (30, 10, 10);
-- CTRL-011: Global Markets, Equity Derivatives, EMEA
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (31, 11, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (32, 11, 4);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (33, 11, 8);
-- CTRL-012: Global Markets, Corporate Banking, Fixed Income
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (34, 12, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (35, 12, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (36, 12, 5);
-- CTRL-013: Global Markets, FX Trading, Prime Brokerage
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (37, 13, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (38, 13, 6);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (39, 13, 7);
-- CTRL-014: Global Markets, Corporate Banking, Securities Services
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (40, 14, 1);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (41, 14, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (42, 14, 3);
-- CTRL-015: Corporate Banking, EMEA, Americas
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (43, 15, 2);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (44, 15, 8);
INSERT INTO control_business_entities (control_entity_id, control_id, entity_id) VALUES (45, 15, 10);

-- ============================================================
-- STEP 8: CONTROL_VERSIONS (7 rows)
-- These inserts WILL fire trg_control_versions_audit → audit_log rows
-- Mix of Create/Update/Retire in Pending/Approved/Rejected states
-- submitted_by/reviewed_by reference users by user_id
-- control_id is NULL for Create flows (control doesn't exist yet)
-- ============================================================

-- 1. Create a new control — Pending (not yet reviewed)
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by)
VALUES (1, NULL, 'Create',
    '{"control_reference":"CTRL-016","control_name":"Insider Trading Surveillance","control_type_id":2,"risk_category_id":6,"control_frequency":"Daily","status":"Active"}',
    'Pending', 1);

-- 2. Update CTRL-001 frequency — Approved
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by, reviewed_by, reviewed_at, review_comments)
VALUES (2, 1, 'Update',
    '{"control_frequency":"Weekly"}',
    'Approved', 3, 2, SYSTIMESTAMP - INTERVAL '2' DAY,
    'Frequency change approved per risk committee decision');

-- 3. Update CTRL-005 name — Rejected
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by, reviewed_by, reviewed_at, review_comments)
VALUES (3, 5, 'Update',
    '{"control_name":"Enhanced Trading Surveillance"}',
    'Rejected', 6, 5, SYSTIMESTAMP - INTERVAL '1' DAY,
    'Name change rejected — current name aligns with regulatory terminology');

-- 4. Retire CTRL-007 — Pending
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by)
VALUES (4, 7, 'Retire',
    '{"status":"Retired"}',
    'Pending', 1);

-- 5. Create another new control — Approved
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by, reviewed_by, reviewed_at, review_comments)
VALUES (5, NULL, 'Create',
    '{"control_reference":"CTRL-017","control_name":"Conflict of Interest Disclosure","control_type_id":1,"risk_category_id":6,"control_frequency":"Annual","status":"Active"}',
    'Approved', 3, 2, SYSTIMESTAMP - INTERVAL '5' DAY,
    'New conduct control approved — mandatory for all front office staff');

-- 6. Update CTRL-010 risk category — Pending
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by)
VALUES (6, 10, 'Update',
    '{"risk_category_id":6}',
    'Pending', 6);

-- 7. Retire CTRL-011 — Rejected
INSERT INTO control_versions (version_id, control_id, change_type, proposed_data, review_status, submitted_by, reviewed_by, reviewed_at, review_comments)
VALUES (7, 11, 'Retire',
    '{"status":"Retired"}',
    'Rejected', 1, 5, SYSTIMESTAMP - INTERVAL '3' DAY,
    'Retirement rejected — annual model validation is a regulatory requirement');

-- ============================================================
-- STEP 9: Reset sequences past the highest seeded IDs
-- Without this, the next auto-increment insert would collide
-- with existing PKs.
-- ============================================================
ALTER SEQUENCE roles_seq             RESTART START WITH 4;
ALTER SEQUENCE control_types_seq     RESTART START WITH 4;
ALTER SEQUENCE risk_categories_seq   RESTART START WITH 7;
ALTER SEQUENCE business_entities_seq RESTART START WITH 11;
ALTER SEQUENCE users_seq             RESTART START WITH 8;
ALTER SEQUENCE controls_seq          RESTART START WITH 16;
ALTER SEQUENCE cbe_seq               RESTART START WITH 46;
ALTER SEQUENCE control_versions_seq  RESTART START WITH 8;