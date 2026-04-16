# Controls Repository — Oracle APEX Edition

A full-stack data management application for housing, managing, and 
reporting on regulatory controls in an investment banking context.

This repository is the Oracle APEX re-platform of the 
[PostgreSQL + Python original](https://github.com/r-davey/controls-repository).
Same business logic, same schema design, re-implemented in Oracle's 
ecosystem as a personal upskilling project.

## Tech stack

- **Database:** Oracle Autonomous Database (Always Free, London region)
- **Application layer:** Oracle APEX
- **Business logic:** PL/SQL (triggers, procedures)
- **Reporting:** Power BI (planned, Phase 3)
- **Version control:** Git + GitHub

## Project phases

1. **Phase 1 — Oracle Cloud & Schema Setup** *(in progress)*  
   Cloud provisioning, schema recreation in Oracle SQL, PL/SQL triggers, 
   seed data, reporting views
2. **Phase 2 — APEX Application Development**  
   Interactive Reports, forms, maker/checker validation, RBAC, dashboard
3. **Phase 3 — Power BI Reporting**  
   Connect Power BI to Oracle; dashboards, DAX measures, KPIs
4. **Phase 4 — Documentation & Marketing Website**
5. **Phase 5 — AI Extension** *(future)*

## Repository structure

- `/sql` — Handwritten DDL, seed data, and PL/SQL scripts
- `/apex` — APEX application exports (generated from App Builder)
- `/docs` — Technical documentation and notes