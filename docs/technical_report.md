# University Course Management System (UCMS)
## Detailed Technical Project Report

**Academic reference:** Elmasri, R. and Navathe, S. B., *Fundamentals of Database Systems*, 7th Edition, Pearson.  
**Student / Team:** [Complete before submission]  
**Course / Code:** [Complete before submission]  
**Instructor:** [Complete before submission]  
**Institution:** [Complete before submission]  
**Submission date:** [Complete before submission]

---

## Abstract

The University Course Management System (UCMS) is a relational database application prototype designed to organize academic information associated with departments, people, students, instructors, courses, academic terms, course sections, classrooms, meeting schedules, enrollments and assessment grades. The project follows a database-development workflow: requirements analysis, conceptual ER/EER modeling, relational mapping, key and constraint design, normalization, SQL implementation, application integration and testing.

The implementation uses SQLite as the persistent data store and Python with Flask as the web application layer. Jinja templates and CSS provide the browser interface. The database schema contains twelve core relations, primary and foreign keys, uniqueness and domain constraints, indexes, two reporting views and triggers for selected registration and grading rules. SQL example files demonstrate joins, aggregation, subqueries, common table expressions and data modification.

This report describes the implemented system and distinguishes verified functionality from limitations and future work. UCMS is an educational prototype rather than a production student information system. Automated verification is documented through the repository's GitHub Actions workflow; the test record should be associated with the exact commit and run linked in [test_results.md](test_results.md).

## Executive Summary

| Area | Project result |
|---|---|
| Conceptual design | ER/EER model with PERSON supertype and STUDENT / INSTRUCTOR subtypes |
| Relational design | 12 core relations with primary keys, foreign keys, UNIQUE and CHECK constraints |
| Normalization | Design rationale documented through 1NF, 2NF and 3NF |
| SQL | Schema DDL, fictional sample data, query examples, views, indexes and triggers |
| Application | Flask pages for dashboard, students, courses, sections, enrollments and grades |
| Verification | Database smoke validation and Flask route tests run in CI; see [test_results.md](test_results.md) |
| Known gaps | No authentication or role authorization; prerequisite eligibility is modeled but not enforced by enrollment route |

## 1. Introduction

Universities manage data that is naturally connected. A course belongs to a department; a section is an offering of a course in an academic term; a section may be assigned an instructor, room and schedule; students register in sections; and grades are recorded for student enrollments. A relational database is suitable for representing these relationships because it supports structured relations, keys, constraints and multi-table queries.

UCMS was developed as a teaching project to demonstrate the principles presented in *Fundamentals of Database Systems*. It is not intended to replace a university's official student information system. Its purpose is to show how a coherent database design can be translated into SQL and integrated with a small web application.

## 2. Problem Definition and Objectives

### 2.1 Problem definition

If academic records are stored in disconnected files or spreadsheets, the same facts may be entered repeatedly. Repeated data can become inconsistent when a student's department, a course description or a section's capacity changes. Registration rules may also be applied inconsistently if they are enforced only by user convention. Reporting becomes harder when related information is scattered across files.

UCMS addresses this educational scenario by centralizing core academic records in a relational schema and enforcing selected rules in the database. The system also provides a simple interface to demonstrate common operations.

### 2.2 Project objectives

1. Identify the data requirements of a small university course-management domain.
2. Create an ER/EER model showing entities, relationships, cardinalities and specialization.
3. Map the conceptual design to relational tables and identify primary and foreign keys.
4. Apply normalization principles through Third Normal Form (3NF).
5. Implement SQL DDL, sample DML, complex SELECT statements, views, indexes and triggers.
6. Develop a Flask application that reads and modifies the database through parameterized SQL.
7. Verify database integrity and application routes with repeatable automated checks.

## 3. Requirements Analysis

### 3.1 Functional requirements

| ID | Requirement | Implementation evidence |
|---|---|---|
| FR-01 | Maintain departments and shared person records | `department` and `person` relations |
| FR-02 | Represent students and instructors as specialized person records | `student` and `instructor` with unique person_id foreign keys |
| FR-03 | Maintain course catalog entries and credit values | `course` relation; `/courses` |
| FR-04 | Create academic terms and term-specific course sections | `academic_term` and `section`; `/sections` |
| FR-05 | Associate sections with instructor, classroom and meeting schedule | Optional section references and `course_schedule` |
| FR-06 | Register students in sections and preserve registration status | `enrollment`; `/enrollments` |
| FR-07 | Prevent duplicate registration of a student in a section | UNIQUE(student_id, section_id) |
| FR-08 | Record assessment grades for enrolled students | `grade`; `/grades`; grade eligibility trigger |
| FR-09 | Display student, course, section, enrollment and grade information | Flask routes and Jinja templates |
| FR-10 | Provide roster and transcript-oriented reporting | `v_section_roster` and `v_student_transcript` |

### 3.2 Non-functional requirements

- **Integrity:** Primary keys, foreign keys, UNIQUE and CHECK constraints protect stored data.
- **Maintainability:** Application, templates, CSS, SQL, scripts, tests and documentation are separated.
- **Repeatability:** Schema and fictional sample data are stored as SQL scripts.
- **Usability:** Browser-based pages expose common academic records and operations.
- **Portability:** SQLite avoids requiring a separate database server for the local demonstration.
- **Privacy:** Use fictional records only; the prototype is not approved for real student data.

## 4. Scope, Assumptions and Constraints

### 4.1 Included scope

- Department, person, student, instructor and course catalog data.
- Academic terms, sections, optional instructor and classroom assignment, and section schedules.
- Student enrollment records with status values.
- Assessment grades associated with enrollment records.
- Basic web views, SQL reports, database constraints and automated checks.

### 4.2 Explicitly excluded or incomplete scope

- Authentication, role-based access control, password management and user account administration.
- CSRF protection, production-grade session management, audit logging and backup/restore operations.
- Enforcement of course prerequisite completion during the Flask enrollment workflow.
- A complete institutional grading policy, letter-grade conversion and GPA calculation.
- Distributed database deployment, NoSQL storage, data warehouse/OLAP, Big Data processing and data mining.

### 4.3 Assumptions

A person can be represented independently from a student or instructor role. A person may have a student subtype row, an instructor subtype row, both, or neither; this is a partial and potentially overlapping specialization. A course can have multiple sections across terms. Each enrollment belongs to one student and one section. A grade belongs to one enrollment and one named assessment.

## 5. System Architecture

| Layer | Technology / responsibility |
|---|---|
| Presentation | HTML templates rendered by Jinja; CSS stylesheet |
| Application | Python Flask routes process requests, execute parameterized SQL, commit or roll back transactions and render templates |
| Data access | Python sqlite3 module; row factory provides named column access; foreign-key enforcement is enabled on connections |
| Database | SQLite database built from `database/schema.sql` and populated from `database/sample_data.sql` |
| Verification | `scripts/validate_database.py`, `tests/test_app.py` and GitHub Actions workflow |

The application follows a simple request-response pattern. A browser requests a route. Flask opens a database connection, retrieves or modifies rows, then passes query results to a Jinja template. For form submissions, the route attempts the SQL operation, commits on success, rolls back on integrity errors and redirects to the relevant page with a flash message.

The application's database path is resolved relative to the project directory. When run directly, the app creates the database and loads the schema and sample data if the database file does not yet exist. The reset script is a separate convenience for rebuilding a local demonstration database; it should only be used when the user intends to reset local data.

## 6. Conceptual ER/EER Design

### 6.1 Entity descriptions

| Entity | Purpose |
|---|---|
| DEPARTMENT | Academic organizational unit associated with students, instructors and courses |
| PERSON | Shared personal attributes such as first name, last name, email, phone and date of birth |
| STUDENT | Student-specific identifiers, program, level, admission date, department and status |
| INSTRUCTOR | Instructor-specific department, academic rank and hire date |
| ACADEMIC_TERM | Term name, teaching dates and registration period |
| COURSE | Catalog-level course code, title, description, credit count and active flag |
| CLASSROOM | Building, room number and room capacity |
| SECTION | Term-specific offering of a course, with section number, capacity, status and optional assignments |
| COURSE_PREREQUISITE | Associative relation connecting a course to a prerequisite course and minimum-grade label |
| COURSE_SCHEDULE | Meeting day, start time and end time for a section |
| ENROLLMENT | Associative entity recording a student's registration in a section and its status |
| GRADE | Assessment name, achieved score, maximum score and timestamp for an enrollment |

### 6.2 Relationships and cardinalities

| Relationship | Cardinality / interpretation |
|---|---|
| DEPARTMENT–STUDENT | One department can be associated with many students; each student references one department |
| DEPARTMENT–INSTRUCTOR | One department can be associated with many instructors; each instructor references one department |
| DEPARTMENT–COURSE | One department can own many courses; each course references one department |
| PERSON–STUDENT | A person may have zero or one student subtype row; each student row references one person |
| PERSON–INSTRUCTOR | A person may have zero or one instructor subtype row; each instructor row references one person |
| COURSE–SECTION | A course can be offered through multiple sections; each section references one course |
| ACADEMIC_TERM–SECTION | A term can contain multiple sections; each section references one term |
| SECTION–COURSE_SCHEDULE | A section can have multiple schedule rows; each schedule row references one section |
| STUDENT–SECTION | Many-to-many relationship resolved by ENROLLMENT; duplicate student-section pairs are prevented |
| ENROLLMENT–GRADE | An enrollment can have multiple grades; each grade references one enrollment |
| COURSE–COURSE | Recursive many-to-many prerequisite relationship resolved by COURSE_PREREQUISITE |

### 6.3 EER specialization

PERSON is the supertype. STUDENT and INSTRUCTOR are subtypes represented as separate relations. The person_id column in each subtype is both a foreign key to PERSON and UNIQUE, so one PERSON cannot have multiple STUDENT rows or multiple INSTRUCTOR rows. The schema allows a person to occur in both subtype tables and does not require every PERSON to belong to a subtype. Therefore the modeled specialization is **partial and overlapping**, not total and disjoint.

The Mermaid diagram source is stored in [er_eer_diagram.md](er_eer_diagram.md) and `docs/diagrams/er_eer_model.mmd`. It can be rendered by a Mermaid-compatible viewer.

## 7. Relational Schema and Data Dictionary

The schema defines twelve core relations. Surrogate integer primary keys are used for most entities. Natural or candidate identifiers are protected with UNIQUE constraints where appropriate. The associative COURSE_PREREQUISITE relation uses a composite primary key.

| Relation | Primary key | Important attributes / constraints |
|---|---|---|
| department | department_id | department_code UNIQUE; department_name UNIQUE; office_location optional |
| person | person_id | first_name, last_name, email UNIQUE (case-insensitive); optional phone/date_of_birth |
| student | student_id | person_id UNIQUE FK; student_number UNIQUE; department_id FK; level 1–8; status domain |
| instructor | instructor_id | person_id UNIQUE FK; department_id FK; academic_rank domain; hire_date |
| academic_term | term_id | term_name UNIQUE; start_date before end_date; registration_start <= registration_end |
| course | course_id | department_id FK; course_code UNIQUE; credits 1–12; is_active 0/1 |
| classroom | classroom_id | building + room_number UNIQUE; capacity > 0 |
| section | section_id | course_id and term_id FKs; optional instructor_id/classroom_id; unique course/term/section number; capacity > 0 |
| course_prerequisite | (course_id, prerequisite_course_id) | Both columns reference course; self-prerequisite disallowed; minimum_grade label |
| course_schedule | schedule_id | section_id FK; day 1–7; start_time < end_time; unique section/day/start time |
| enrollment | enrollment_id | student_id and section_id FKs; UNIQUE(student_id, section_id); status domain |
| grade | grade_id | enrollment_id FK; UNIQUE(enrollment_id, assessment_name); score >= 0; max_score > 0 and score <= max_score |

### 7.1 Key design rationale

Surrogate keys provide stable references even if a natural identifier such as a course code or student number changes. UNIQUE constraints preserve the uniqueness of natural identifiers. Foreign keys ensure that a student cannot reference a nonexistent department and an enrollment cannot reference a nonexistent student or section. The composite primary key of COURSE_PREREQUISITE ensures that a course/prerequisite pair is stored only once.

## 8. Integrity Constraints and Business Rules

| Rule | Database mechanism | Effect |
|---|---|---|
| Unique department, person, student, course and term identifiers | UNIQUE constraints | Rejects duplicate candidate identifiers |
| Valid student level and status | CHECK constraints | Restricts values to declared ranges/domains |
| Valid course credits | CHECK credits BETWEEN 1 AND 12 | Prevents out-of-range credit values |
| Valid room/section capacity | CHECK capacity > 0 | Requires positive capacity |
| Valid term and meeting intervals | CHECK date/time comparisons | Prevents invalid interval ordering |
| No duplicate student registration in one section | UNIQUE(student_id, section_id) | Prevents duplicate registration rows |
| Section must be open and have capacity | Enrollment insert/update triggers | Rejects enrollment into non-open or full sections |
| Capacity cannot be lowered below active enrollment | Section capacity update trigger | Rejects an invalid capacity reduction |
| No overlapping classes for a student in the same term | Schedule conflict triggers | Checks intersecting meeting intervals during enrollment insert/update |
| Grades only for active enrollment | Grade insert/update triggers | Rejects grade recording when enrollment status is not ENROLLED |
| Grade score cannot exceed maximum | CHECK constraints | Requires score >= 0, max_score > 0 and score <= max_score |

The student timetable conflict trigger compares day-of-week and time overlap within the same academic term. The enrollment capacity trigger applies to rows whose new status is ENROLLED. The grade-status trigger is defined for grade insertion and updates of enrollment_id, score or max_score. The project does not claim that every possible institutional registration policy is implemented.

## 9. Normalization Analysis

### 9.1 First Normal Form (1NF)

A relation is in First Normal Form when each attribute contains an atomic value and repeating groups are not represented as multiple values in one cell. UCMS stores each section meeting as an individual COURSE_SCHEDULE row, each student-section registration as an ENROLLMENT row and each assessment result as a GRADE row. It does not use repeating columns such as Monday_schedule, Tuesday_schedule or grade_1, grade_2.

### 9.2 Second Normal Form (2NF)

A relation is in Second Normal Form when it is in 1NF and each non-prime attribute is fully functionally dependent on every candidate key. Most UCMS relations use a single-column surrogate primary key, so a partial dependency on a proper subset of a composite primary key does not arise. COURSE_PREREQUISITE has the composite key (course_id, prerequisite_course_id). Its minimum_grade attribute describes the specific course/prerequisite pair and depends on the complete pair.

### 9.3 Third Normal Form (3NF)

A relation is in Third Normal Form when it is in 2NF and non-key attributes do not depend transitively on a candidate key through another non-key attribute. Department descriptive facts are stored in DEPARTMENT rather than repeated in STUDENT, INSTRUCTOR and COURSE. Shared personal facts are stored in PERSON, while role-specific facts are stored in STUDENT and INSTRUCTOR. Catalog facts are stored in COURSE, term offering facts in SECTION, registration facts in ENROLLMENT and assessment facts in GRADE.

### 9.4 Representative functional dependencies

| Relation | Representative functional dependency |
|---|---|
| DEPARTMENT | department_id → department_code, department_name, office_location |
| PERSON | person_id → first_name, last_name, email, phone, date_of_birth |
| STUDENT | student_id → person_id, student_number, department_id, program, level, admission_date, status |
| COURSE | course_id → department_id, course_code, title, description, credits, is_active |
| ENROLLMENT | enrollment_id → student_id, section_id, enrollment_date, status |
| GRADE | (enrollment_id, assessment_name) → score, max_score, recorded_at |
| COURSE_PREREQUISITE | (course_id, prerequisite_course_id) → minimum_grade |

Normalization is a property of the logical schema and its functional dependencies, not merely the presence of primary keys. The dependencies above are representative design assumptions. Before production use, the institution's full business rules and candidate keys should be formally confirmed. The extended discussion is in [normalization.md](normalization.md).

## 10. SQL Implementation and Query Design

### 10.1 DDL

`database/schema.sql` enables SQLite foreign-key enforcement and creates the twelve core relations. It also defines indexes, reporting views and triggers. CREATE TABLE IF NOT EXISTS and CREATE INDEX IF NOT EXISTS make the schema script suitable for repeatable initialization in the project's setup workflow.

### 10.2 Sample data and DML

`database/sample_data.sql` provides fictional records for demonstration. The query files include examples of INSERT, UPDATE and DELETE statements as well as SELECT statements. Enrollment history is preserved in one example by changing an enrollment status to DROPPED rather than deleting the row. Sample values in query examples are illustrative and may need adjustment to the current sample database identifiers.

### 10.3 Query categories

| SQL pattern | Example purpose in UCMS |
|---|---|
| JOIN | Combine student, person, department, enrollment, section and course information |
| LEFT JOIN | Retain departments or sections even when related records are absent |
| GROUP BY / COUNT | Count enrollments by section, students by department or sections by term |
| HAVING | Find students with multiple active registrations or groups above a threshold |
| Subquery / NOT EXISTS | Find courses without prerequisites or students missing a required completed course |
| CTE | Calculate course demand or section enrollment totals before a summary query |
| View query | Read the section roster or transcript-style assessment rows |
| EXPLAIN QUERY PLAN | Inspect the strategy SQLite chooses for a representative lookup |
| DML | Illustrate status updates, prerequisite maintenance and record changes |

### 10.4 Views

`v_section_roster` joins sections to courses, terms, enrollments, students and people, and returns active enrollment rows. It supports a roster-oriented report without repeating the join logic in every query.

`v_student_transcript` joins students, people, enrollments, sections, courses and terms, and left-joins grade records. It calculates an assessment percentage as 100 × score / max_score. It is assessment-oriented; it does not calculate a final course letter grade or GPA.

### 10.5 Indexes

The schema defines indexes on student.department_id, course.department_id, section.term_id, enrollment.student_id, enrollment.section_id and grade.enrollment_id. These columns are used in common filtering and join paths. Indexes can improve lookup and join performance but consume storage and add work to inserts and updates. Their benefit should be measured against realistic workloads.

## 11. Application Implementation

| Route | Method(s) | Purpose |
|---|---|---|
| `/` | GET | Dashboard counts for active students, active courses, sections and active enrollments, plus recent enrollment rows |
| `/students` | GET | Student directory with optional search over student number, first name, last name and email |
| `/courses` | GET | List active courses with course code, title, credits and department |
| `/sections` | GET | List sections with course, term, capacity, enrollment count and optional instructor name |
| `/enrollments` | GET, POST | Display students, open sections and registrations; create a registration |
| `/grades` | GET, POST | Display eligible active enrollments and existing grades; insert or update an assessment grade |

### 11.1 Grade entry behavior

The grade form accepts an enrollment identifier, assessment name, score and maximum score. The SQL uses an UPSERT on the unique pair (enrollment_id, assessment_name). If the assessment for that enrollment already exists, the route updates score, max_score and recorded_at; otherwise it inserts a new row. Database CHECK constraints and the grade-status trigger provide an additional integrity layer.

### 11.2 Error handling and database access

The application uses parameter placeholders for values in SQL statements. Enrollment and grade form handlers catch SQLite integrity errors, roll back the failed transaction and provide user feedback through Flask flash messages. The connection enables PRAGMA foreign_keys = ON. This is suitable for a local educational prototype; production use would require stronger validation, structured logging and security controls.

## 12. Transactions, Indexing and Query Processing

SQLite transactions ensure that a group of database changes is committed as a unit or rolled back when an operation fails. In the application, successful form operations call commit; integrity failures call rollback. The SQL query examples include a transaction illustration with BEGIN, COMMIT and ROLLBACK comments.

Query processing is demonstrated through joins, filtering, grouping, subqueries and CTEs. The advanced query file includes EXPLAIN QUERY PLAN for an enrollment lookup. The project does not include a benchmark suite or claim measured performance improvements. Actual performance depends on data volume, indexes, query shape and SQLite's chosen plan.

## 13. Testing and Verification

### 13.1 Verification approach

The repository contains `scripts/validate_database.py` for database smoke validation and `tests/test_app.py` for Flask route tests. The GitHub Actions workflow installs requirements, runs the database validator and executes pytest on pushes and pull requests to main. The test plan is maintained in [test_plan.md](test_plan.md).

### 13.2 Coverage

| Test area | What is checked |
|---|---|
| SQLite integrity | PRAGMA integrity_check and foreign-key check output |
| Schema/data readiness | Required tables, sample records and roster view behavior |
| Uniqueness | Duplicate student-section registration is rejected |
| Grade domain | Invalid score range is rejected |
| Application routes | Dashboard and management routes return expected successful responses |
| Enrollment form | Duplicate enrollment produces error feedback |
| Grade form | Grade creation and display are exercised by route tests |

### 13.3 CI evidence and interpretation

The repository's [test_results.md](test_results.md) records a successful GitHub Actions run for the reviewed main commit and links to the run. That CI result is evidence for the exact repository revision executed by that workflow. It does not automatically prove that a separate local project folder is identical, that screenshots have been captured, or that every possible business rule has been tested.

Capacity and schedule-conflict triggers exist in the schema. The current test-results document explicitly does not claim that dedicated automated test cases for those trigger paths are included in the smoke validator. The report therefore distinguishes implemented trigger logic from independently covered test cases.

## 14. Security, Privacy and Limitations

### 14.1 Security controls present

- Parameterized SQL is used for application query values.
- Foreign keys and database constraints protect relational integrity.
- Fictional demonstration data is used in the repository.
- The development server is configured for local use rather than public production hosting.

### 14.2 Security controls not implemented

- No authentication or user identity verification.
- No role-based authorization separating student, instructor and administrator privileges.
- No CSRF token protection for state-changing forms.
- The development fallback secret key must be replaced with a secure environment secret before any deployment.
- No audit trail, formal backup policy, monitoring or privacy compliance process.

### 14.3 Functional limitations

- Course prerequisite relationships are stored and queried, but the Flask enrollment route does not enforce prerequisite completion.
- The database does not encode a complete institutional grading scale or GPA rules.
- The application is a simple prototype and has no advanced pagination, administrative workflow or reporting dashboard.
- No deployment architecture for multiple concurrent application servers is provided.

## 15. Future Enhancements

1. Add authentication and role-based permissions for administrators, instructors and students.
2. Add CSRF protection, server-side validation, secure configuration, audit logs and database backup procedures.
3. Enforce prerequisite completion and registration date windows in the enrollment workflow.
4. Define institutional grading rules and implement letter-grade and GPA calculations if required.
5. Add course and section filters, grade editing/deletion policies, class-level analytics and exportable reports.
6. Evaluate PostgreSQL if concurrent multi-user deployment or operational requirements exceed SQLite's intended use.
7. Create a separate de-identified analytical data mart for OLAP reporting if reporting needs justify it.
8. Consider NoSQL or distributed processing only for requirements that justify their additional complexity; these are not part of the current implementation.

## 16. Conclusion

UCMS demonstrates the principal stages of a relational database project: requirements analysis, ER/EER modeling, relational mapping, key and constraint design, normalization, SQL implementation, application integration and automated verification. The schema represents the core academic entities and relationships, while constraints and triggers enforce selected integrity and registration rules. The Flask application provides an educational interface for browsing students, courses and sections and for recording enrollments and assessment grades.

The project is intentionally scoped as a prototype. This report identifies its security and functional limitations rather than presenting unimplemented features as complete. Before submission, complete the student/course/instructor fields on the cover page, compare the report with the instructor's rubric, attach genuine application screenshots if required and retain the linked CI evidence.

## References

1. Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of Database Systems* (7th ed.). Pearson.
2. SQLite Documentation. SQL Language Reference and PRAGMA documentation. https://www.sqlite.org/docs.html
3. Flask Documentation. https://flask.palletsprojects.com/
4. Python Documentation. sqlite3 — DB-API 2.0 interface for SQLite databases. https://docs.python.org/3/library/sqlite3.html
5. UCMS project source repository. https://github.com/elinurcekic/University_Course_Management

## Appendix A: Repository Structure

| Path | Purpose |
|---|---|
| `app.py` | Flask application routes and database access |
| `database/schema.sql` | Canonical SQLite schema, constraints, indexes, views and triggers |
| `database/sample_data.sql` | Fictional demonstration records |
| `database/queries.sql` | Core SQL examples and DML |
| `database/advanced_queries.sql` | Additional complex query examples and query-plan illustration |
| `templates/` | Jinja templates for dashboard and management pages |
| `static/css/style.css` | Application stylesheet |
| `scripts/reset_database.py` | Local database rebuild helper |
| `scripts/validate_database.py` | Database smoke validation |
| `tests/test_app.py` | Flask route tests |
| `.github/workflows/tests.yml` | Continuous integration workflow |
| `docs/` | Technical report, ER/EER model, relational schema, normalization, test plan and project notes |

## Appendix B: Demonstration Procedure

1. Create and activate a Python virtual environment.
2. Install dependencies with `python -m pip install -r requirements.txt`.
3. Initialize or reset the local database using the documented setup script, understanding that reset may overwrite local demo data.
4. Start the Flask application with `python app.py`.
5. Open the dashboard at `http://127.0.0.1:5000/`.
6. Demonstrate student search at `/students` and inspect courses at `/courses`.
7. Inspect section offerings at `/sections`.
8. Demonstrate a registration at `/enrollments` using a valid fictional student and open section.
9. Demonstrate grade entry at `/grades` using an active enrollment; repeat the same assessment name to show UPSERT update behavior.
10. Run `python scripts/validate_database.py` and `python -m pytest -q` when a fresh test execution is required.
11. Capture genuine screenshots of the actual local application and attach them only if requested by the instructor.
