# Phase 1 Retrospective — Oracle Cloud & Schema Setup

Completed: 16 April 2026  
Tasks: P1-01 through P1-19 (19 tasks)  
Project: Controls Repository — Oracle APEX Edition

---

## What this phase delivered

- Oracle Cloud Free Tier account (UK South / London region)
- Always Free APEX Service with CONTROLS workspace
- 9 tables with full constraint coverage (PK, FK, UNIQUE, CHECK)
- 9 sequences for auto-incrementing primary keys
- 19 triggers (auto-increment, updated_at, audit trail, immutability)
- 7 reporting views joining across the full schema
- Realistic seed data: 96 manually inserted rows + 67 auto-generated 
  audit log entries
- Full schema verification (P1-17) with 0 unexpected failures
- Version-controlled repository with documented build order

## What transferred easily from PostgreSQL

**CREATE TABLE, constraints, and foreign keys** were the smoothest 
transfer. The structure is almost identical between PostgreSQL and 
Oracle — the concepts of primary keys, foreign keys, CHECK constraints, 
UNIQUE constraints, and NOT NULL are the same. The only real difference 
is spelling: VARCHAR2 instead of VARCHAR, NUMBER(1) instead of BOOLEAN, 
CLOB instead of TEXT. Once those substitutions became habit, writing 
table definitions felt familiar.

## What was genuinely new

**JSON building via string concatenation in the audit triggers** was 
the hardest part of Phase 1. In PostgreSQL, row_to_json(NEW) captured 
an entire row in one line. In Oracle, every field has to be manually 
concatenated into a JSON string with correct quoting, null handling 
(NVL), and comma placement (the v_sep pattern). The logic is 
straightforward but the verbosity makes it easy to miss a quote or a 
comma. This is the area I'd want more practice on before writing 
similar triggers independently.

## Confidence assessment

| Area | Confidence |
|------|------------|
| Oracle SQL (CREATE TABLE, constraints, INSERT) | Shaky — understand it but couldn't write it cold without my reference doc |
| Triggers (BEFORE INSERT, BEFORE UPDATE) | Comfortable with the pattern — the shape is repetitive and predictable |
| Audit trail triggers (JSON building) | Least confident area — would need to reference P1-13 heavily |
| Views and JOINs | Comfortable — transferred cleanly from PostgreSQL |
| VS Code → SQL Scripts → Object Browser → Git workflow | Second nature — no hesitation on the tooling loop |
| APEX workspace navigation | Comfortable — know where everything lives |

## What I'd do differently

- **Read the APEX SQL Commands vs SQL Scripts distinction earlier.** 
  I hit the SET SERVEROUTPUT ON error in P1-05 because I pasted a 
  multi-statement script into SQL Commands (single-statement tool) 
  instead of SQL Scripts (multi-statement tool). Knowing the right 
  tool upfront would have saved time.
- **Check column names against the schema before writing triggers.** 
  The P1-12 error (updated_at triggers on tables that don't have 
  updated_at) was caught quickly but could have been avoided by 
  checking the schema workbook first.

## What I'm taking into Phase 2

- The workflow loop (VS Code → SQL Scripts → verify → commit) is 
  locked in and won't slow me down
- My oracle_vs_postgresql.md reference doc covers the syntax 
  differences I'll need for any future Oracle SQL
- The schema is fully built, seeded, and verified — Phase 2 starts 
  with a working database, not an empty one

## What I'm most looking forward to

Building the APEX UI — forms, reports, and pages. Phase 1 was all 
backend work. Phase 2 is where the application becomes something 
you can actually see and interact with in a browser.