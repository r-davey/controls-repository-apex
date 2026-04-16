-- P1-07: Create lookup tables
-- Four reference/lookup tables that hold controlled lists of valid values.
-- All other tables reference these via foreign keys.
--
-- Tables: roles, control_types, risk_categories, business_entities
-- Sequences: created in P1-06 (wired via triggers in P1-11)

-- ============================================================
-- 1. ROLES — access levels: Read Only, Write, Validate
-- ============================================================
CREATE TABLE roles (
    -- Primary key — populated by trg_roles_id trigger (P1-11)
    role_id             NUMBER          NOT NULL,
    -- Core fields
    role_name           VARCHAR2(50)    NOT NULL,
    role_description    CLOB,
    is_active           NUMBER(1)       DEFAULT 1 NOT NULL,
    -- Audit columns
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE,
    created_by          VARCHAR2(100),
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT pk_roles           PRIMARY KEY (role_id),
    CONSTRAINT uq_roles_role_name UNIQUE (role_name),
    CONSTRAINT ck_roles_is_active CHECK (is_active IN (0, 1))
);

-- ============================================================
-- 2. CONTROL_TYPES — Preventive, Detective, Corrective
-- ============================================================
CREATE TABLE control_types (
    control_type_id     NUMBER          NOT NULL,
    type_name           VARCHAR2(50)    NOT NULL,
    type_description    CLOB,
    is_active           NUMBER(1)       DEFAULT 1 NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE,
    created_by          VARCHAR2(100),
    updated_by          VARCHAR2(100),
    CONSTRAINT pk_control_types           PRIMARY KEY (control_type_id),
    CONSTRAINT uq_ct_type_name            UNIQUE (type_name),
    CONSTRAINT ck_ct_is_active            CHECK (is_active IN (0, 1))
);

-- ============================================================
-- 3. RISK_CATEGORIES — 6 CIB risk types
-- ============================================================
CREATE TABLE risk_categories (
    risk_category_id    NUMBER          NOT NULL,
    category_name       VARCHAR2(50)    NOT NULL,
    category_description CLOB,
    is_active           NUMBER(1)       DEFAULT 1 NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE,
    created_by          VARCHAR2(100),
    updated_by          VARCHAR2(100),
    CONSTRAINT pk_risk_categories         PRIMARY KEY (risk_category_id),
    CONSTRAINT uq_rc_category_name        UNIQUE (category_name),
    CONSTRAINT ck_rc_is_active            CHECK (is_active IN (0, 1))
);

-- ============================================================
-- 4. BUSINESS_ENTITIES — CIB divisions, desks, regions
-- ============================================================
CREATE TABLE business_entities (
    entity_id           NUMBER          NOT NULL,
    entity_name         VARCHAR2(100)   NOT NULL,
    entity_type         VARCHAR2(50)    NOT NULL,
    region              VARCHAR2(50),
    is_active           NUMBER(1)       DEFAULT 1 NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE,
    created_by          VARCHAR2(100),
    updated_by          VARCHAR2(100),
    CONSTRAINT pk_business_entities       PRIMARY KEY (entity_id),
    CONSTRAINT uq_be_entity_name          UNIQUE (entity_name),
    CONSTRAINT ck_be_is_active            CHECK (is_active IN (0, 1))
);