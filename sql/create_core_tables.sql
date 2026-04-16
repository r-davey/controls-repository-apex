-- P1-08: Create core tables
-- Three tables that hold the main business data.
-- All reference the lookup tables created in P1-07 via foreign keys.
--
-- Tables: users, controls, control_business_entities
-- Depends on: roles, control_types, risk_categories, business_entities

-- ============================================================
-- 1. USERS — application users with role assignment
-- ============================================================
CREATE TABLE users (
    -- Primary key — populated by trg_users_id trigger (P1-11)
    user_id             NUMBER          NOT NULL,
    -- Core fields
    employee_id         VARCHAR2(20)    NOT NULL,
    first_name          VARCHAR2(50)    NOT NULL,
    last_name           VARCHAR2(50)    NOT NULL,
    email               VARCHAR2(100)   NOT NULL,
    role_id             NUMBER          NOT NULL,
    is_active           NUMBER(1)       DEFAULT 1 NOT NULL,
    -- Audit columns
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE,
    created_by          VARCHAR2(100),
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT pk_users              PRIMARY KEY (user_id),
    CONSTRAINT uq_users_employee_id  UNIQUE (employee_id),
    CONSTRAINT uq_users_email        UNIQUE (email),
    CONSTRAINT ck_users_is_active    CHECK (is_active IN (0, 1)),
    CONSTRAINT fk_users_roles        FOREIGN KEY (role_id)
                                     REFERENCES roles (role_id)
);

-- ============================================================
-- 2. CONTROLS — the control register
-- ============================================================
CREATE TABLE controls (
    -- Primary key
    control_id          NUMBER          NOT NULL,
    -- Core fields
    control_reference   VARCHAR2(20)    NOT NULL,
    control_name        VARCHAR2(200)   NOT NULL,
    control_description CLOB,
    control_owner_id    NUMBER          NOT NULL,
    control_type_id     NUMBER          NOT NULL,
    risk_category_id    NUMBER          NOT NULL,
    control_frequency   VARCHAR2(20)    NOT NULL,
    status              VARCHAR2(20)    DEFAULT 'Active' NOT NULL,
    -- Audit columns
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE,
    created_by          VARCHAR2(100),
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT pk_controls              PRIMARY KEY (control_id),
    CONSTRAINT uq_controls_ref          UNIQUE (control_reference),
    CONSTRAINT ck_controls_frequency    CHECK (control_frequency IN (
        'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Annual', 'Ad-Hoc'
    )),
    CONSTRAINT ck_controls_status       CHECK (status IN ('Active', 'Retired')),
    CONSTRAINT fk_controls_owner        FOREIGN KEY (control_owner_id)
                                        REFERENCES users (user_id),
    CONSTRAINT fk_controls_type         FOREIGN KEY (control_type_id)
                                        REFERENCES control_types (control_type_id),
    CONSTRAINT fk_controls_risk         FOREIGN KEY (risk_category_id)
                                        REFERENCES risk_categories (risk_category_id)
);

-- ============================================================
-- 3. CONTROL_BUSINESS_ENTITIES — many-to-many junction table
-- ============================================================
CREATE TABLE control_business_entities (
    -- Primary key
    control_entity_id   NUMBER          NOT NULL,
    -- Foreign keys — the two sides of the relationship
    control_id          NUMBER          NOT NULL,
    entity_id           NUMBER          NOT NULL,
    -- Audit columns (lighter — no updated_at as junction rows are 
    -- created/deleted, not updated)
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    created_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT pk_cbe                   PRIMARY KEY (control_entity_id),
    CONSTRAINT fk_cbe_controls          FOREIGN KEY (control_id)
                                        REFERENCES controls (control_id),
    CONSTRAINT fk_cbe_entities          FOREIGN KEY (entity_id)
                                        REFERENCES business_entities (entity_id)
);