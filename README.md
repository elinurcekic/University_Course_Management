# University Course Management System (UCMS)

A university course-management database project built with Python, Flask, SQLite, Jinja and SQL.

**Academic reference:** *Fundamentals of Database Systems*, 7th Edition — Ramez Elmasri and Shamkant B. Navathe. This is an independent student implementation.

## Features
- Department, person, student, instructor, course, term, classroom and section data
- Student enrollments, schedules and assessment grades
- Relational schema with primary/foreign keys, UNIQUE and CHECK constraints
- SQL views, indexes and triggers for capacity, timetable and grade-status rules
- Flask pages for dashboard, students, courses, sections, enrollments and grades
- ER/EER modeling, relational mapping and 1NF–3NF documentation
- SQL examples with joins, aggregation, subqueries, CTEs and DML
- Test plan, database validator, Flask route tests and GitHub Actions workflow

## Local setup
```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python scripts/reset_database.py
python app.py
```
Open http://127.0.0.1:5000.

## Validation
```bash
python scripts/validate_database.py
python -m pytest -q
```
The commands above are the required checks. Record their actual outputs in `docs/test_results.md`; do not infer test success from the presence of the test scripts. GitHub Actions runs the database validator and Flask route suite on pushes and pull requests to `main`.

## Main project artifacts
- `app.py` — Flask application
- `database/schema.sql` — canonical database schema, views, indexes and triggers
- `database/sample_data.sql` — fictional demonstration records
- `database/queries.sql` and `database/advanced_queries.sql` — SQL examples
- `docs/technical_report.md` — technical report
- `docs/normalization.md` — normalization analysis
- `docs/er_eer_diagram.md` and `docs/diagrams/er_eer_model.mmd` — conceptual diagram and Mermaid source
- `docs/requirements_traceability.md` — mapping to course requirements
- `docs/test_plan.md` and `docs/test_results.md` — testing documentation
- `docs/presentation.md` — slide-ready presentation outline
- `docs/submission_checklist.md` — final hand-in checklist
- `scripts/validate_database.py` — database validation
- `tests/` — Flask route tests

## Limitations and security
This is an educational prototype, not a production student information system. It does not include authentication, role-based authorization or CSRF protection. Prerequisite relationships are modeled but prerequisite eligibility is not yet enforced in the registration route. Do not publish real student data or secrets.

See `docs/advanced_database_concepts.md` for the distinction between implemented features and future extensions.


## Expanded demonstration dataset and reporting queries

- `database/expanded_sample_data.sql` adds 30 fictional students, 18 courses, 6 instructors, 18 sections, 90 enrollments and 90 grade records.
- `database/query_examples_extra.sql` provides 25 additional roster, enrollment, grade, schedule and department reports.
- `database/EXPANDED_DATA_GUIDE.md` explains load order and query usage.

Load the expanded dataset only after the original schema and sample data have been loaded. See the guide for the exact command.
