# UCMS Project Presentation

> Slide-ready outline. Replace the student, course, instructor and date placeholders before presenting.

## Slide 1 — Title
**University Course Management System (UCMS)**
- Database Systems Project
- Student / Team: [Add names]
- Course / Instructor: [Add details]
- Submission date: [Add date]

## Slide 2 — Problem and Motivation
- Academic information is related across students, courses, sections, schedules and grades.
- Disconnected records can create duplication and inconsistent registration data.
- UCMS demonstrates how a relational database can centralize these records and enforce integrity.

## Slide 3 — Project Objectives and Scope
- Design an ER/EER model and map it to relations.
- Implement keys, constraints, indexes, views and triggers.
- Normalize the schema to 3NF.
- Demonstrate SQL queries and a Flask interface.
- Scope: educational prototype using SQLite and fictional data.

## Slide 4 — System Architecture
- User interface: HTML templates and CSS.
- Application layer: Python and Flask routes.
- Data layer: SQLite database.
- SQL artifacts: schema, sample data, query examples and validation script.

## Slide 5 — ER/EER Model
- PERSON is the supertype.
- STUDENT and INSTRUCTOR are partial, potentially overlapping subtypes.
- ENROLLMENT resolves the many-to-many relationship between STUDENT and SECTION.
- COURSE_PREREQUISITE models a recursive course relationship.
- Refer to `docs/er_eer_diagram.md` for the diagram.

## Slide 6 — Relational Schema and Keys
- 12 core relations.
- Primary keys identify each row.
- Foreign keys maintain referential integrity.
- UNIQUE constraints prevent duplicate identifiers, registrations and assessment names.
- CHECK constraints validate domain values.

## Slide 7 — Normalization
- 1NF: attributes are atomic; repeating schedule and assessment facts use separate rows.
- 2NF: no partial dependency on a subset of a composite key.
- 3NF: non-key facts are stored with their owning entity/relation.
- See `docs/normalization.md` for relation-level reasoning.

## Slide 8 — SQL Features
- DDL and fictional DML sample records.
- JOINs, grouping, HAVING, subqueries and CTEs.
- Views: section roster and student transcript.
- Indexes for common joins and filters.
- Triggers for section capacity, schedule conflicts and grade eligibility.

## Slide 9 — Application Demonstration
Show genuine screenshots of:
1. Dashboard
2. Student search
3. Course and section lists
4. Enrollment workflow
5. Grade entry and grade list

## Slide 10 — Testing
- Database smoke validation script.
- Flask route tests using pytest.
- GitHub Actions workflow runs validation and route tests.
- Report only observed test results; include terminal or Actions evidence.

## Slide 11 — Limitations and Future Work
- Prototype has no authentication, role-based authorization or CSRF protection.
- Prerequisite completion is modeled but not enforced in enrollment.
- Future work: PostgreSQL, security controls, audit logs, waitlists and analytics.
- Distributed databases, NoSQL, warehousing, Big Data and data mining are not implemented.

## Slide 12 — Conclusion and References
- UCMS demonstrates the workflow from conceptual modeling to a working relational prototype.
- Reference: Elmasri, R. and Navathe, S. B., *Fundamentals of Database Systems*, 7th edition, Pearson.
- Questions
