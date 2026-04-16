# SQL Scripts

All handwritten DDL, seed data, and PL/SQL for the Controls Repository 
Oracle schema. Run in the order listed below to build from scratch.

## Build order

| Order | File | Description |
|-------|------|-------------|
| 1 | `create_sequences.sql` | 9 sequences for auto-increment PKs |
| 2 | `create_lookup_tables.sql` | roles, control_types, risk_categories, business_entities |
| 3 | `create_core_tables.sql` | users, controls, control_business_entities |
| 4 | `create_workflow_tables.sql` | control_versions, audit_log |
| 5 | `create_autoincrement_triggers.sql` | 9 BEFORE INSERT triggers |
| 6 | `create_updated_at_triggers.sql` | 6 BEFORE UPDATE triggers |
| 7 | `create_audit_triggers.sql` | 3 AFTER INSERT/UPDATE/DELETE audit triggers |
| 8 | `protect_audit_log.sql` | Immutability trigger on audit_log |
| 9 | `seed_data.sql` | Realistic seed data (96 rows + 67 auto-generated audit rows) |
| 10 | `create_views.sql` | 7 reporting views |

## Verification and practice scripts

| File | Description |
|------|-------------|
| `p1_05_verification.sql` | Oracle syntax verification (P1-05) |
| `p1_10_plsql_practice.sql` | PL/SQL fundamentals practice (P1-10) |
| `p1_17_verification.sql` | Full schema verification (P1-17) |
| `build_schema.sql` | Master build script — documented run order |