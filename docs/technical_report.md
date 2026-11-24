# Technical Project Report: University Course Management System

**Reference:** *Fundamentals of Database Systems*, 7th Edition — Ramez Elmasri and Shamkant B. Navathe  
**Project:** University Course Management System (UCMS)  
**Student / Team / Course / Instructor / Date:** Complete these fields before submission.

## Abstract
UCMS is an educational relational database application for managing departments, people, students, instructors, courses, academic terms, sections, classrooms, schedules, enrollments and assessment grades. It demonstrates requirements analysis, ER/EER modeling, relational mapping, normalization, SQL implementation, integrity constraints and integration with a Flask web interface. The implementation uses SQLite and fictional demonstration records.

## 1. Problem and objectives
University academic data is interconnected. Disconnected spreadsheets can lead to duplicated data, inconsistent identifiers, invalid registrations and difficult reporting. UCMS centralizes the records in a relational database and protects consistency through database constraints.

Objectives:
1. Model the course-management domain with ER/EER concepts.
2. Map entities and relationships to relations with primary and foreign keys.
3. Design a schema targeting Third Normal Form.
4. Demonstrate SQL DDL, DML, complex queries, views, indexes and triggers.
5. Provide a Flask interface for common academic workflows.
6. Validate database integrity and document test evidence.

## 2. Requirements and scope
Functional requirements include maintaining departments, students, instructors and courses; offering term-specific sections; associating sections with instructors, rooms and schedules; registering students; recording assessments; and querying rosters and performance.

Non-functional requirements include referential integrity, domain validation, parameterized SQL, repeatable setup, separation of application and database concerns, and fictional sample data.

## 3. Architecture
Flask handles routes, Jinja renders pages, CSS provides presentation, and Python's SQLite DB-API accesses the database. `database/schema.sql` is the canonical schema and `database/sample_data.sql` contains fictional records. The project is intended for local classroom demonstration, not production deployment.

## 4. ER/EER model
Core entities are DEPARTMENT, PERSON, STUDENT, INSTRUCTOR, ACADEMIC_TERM, COURSE, CLASSROOM, SECTION, COURSE_SCHEDULE, ENROLLMENT, GRADE and COURSE_PREREQUISITE. ENROLLMENT resolves the many-to-many relationship between STUDENT and SECTION. COURSE_PREREQUISITE models a recursive many-to-many course relationship.

PERSON is the EER supertype. STUDENT and INSTRUCTOR are partial, potentially overlapping subtypes: a person may have neither subtype row or both. Each subtype has a unique person_id foreign key. See `docs/er_eer_diagram.md`.

## 5. Relational design and constraints
Relations use primary keys and foreign keys. Candidate identifiers include department code/name, person email, student number, course code and term name. UNIQUE constraints prevent duplicate student-section registration and duplicate assessment names per enrollment. CHECK constraints restrict credits, levels, status values, capacities, dates, times and score ranges. Full relation/key listing: `docs/relational_schema.md`.

## 6. Normalization
The schema targets 3NF. 1NF is supported by atomic attributes and separate rows for schedules, registrations and assessments. 2NF is supported because single-column primary keys have no partial dependency; in COURSE_PREREQUISITE, minimum_grade depends on the complete composite key. 3NF is supported by storing department, person, course, section, enrollment and grade facts with their owning relations. Detailed discussion: `docs/normalization.md`.

## 7. SQL implementation
The schema creates 12 core relations, keys, constraints, indexes, views and triggers. The two query files demonstrate SELECT, JOIN, grouping, HAVING, subqueries, CTEs and DML. Views include v_section_roster and v_student_transcript. Triggers enforce section capacity, prevent timetable collisions and restrict grade entry to active enrollments.

## 8. Application interface
The Flask interface provides dashboard, student directory/search, course catalog, section list, enrollment management and grade entry. Application queries use parameterized SQL.

## 9. Transactions and indexing
SQLite provides transactional behavior. Successful route operations commit changes and relevant integrity errors roll back. Indexes support common joins and filters. Query plans can be inspected with SQLite EXPLAIN QUERY PLAN; index value depends on actual workload.

## 10. Testing and evidence
The standard-library database validation script checks SQLite integrity and foreign keys, schema objects, fictional seed records, duplicate registration, invalid grades, orphan foreign keys, capacity, timetable conflicts, grade eligibility and execution of the SQL example files. The Flask route suite must be run in an environment with Flask installed. See `docs/test_results.md`.

## 11. Limitations and security
This is an educational prototype. It does not include authentication, role-based authorization, CSRF protection, audit logging or production backup procedures. Prerequisite completion is modeled but is not enforced by the enrollment route. Only fictional sample records should be used in a public repository.

## 12. Future work and conclusion
Future work includes PostgreSQL deployment, authentication, authorization, CSRF protection, audit logs, waitlists, prerequisite enforcement, analytics and APIs. Distributed databases, NoSQL, data warehousing, Big Data and data mining are not implemented in this prototype and should be treated as future extensions. UCMS demonstrates a coherent path from conceptual modeling to relational implementation and application integration.

## References
Elmasri, R., & Navathe, S. B. *Fundamentals of Database Systems* (7th ed.). Pearson.