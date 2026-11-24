# Normalization Analysis (1NF–3NF)

## First Normal Form (1NF)
A relation is in 1NF when each attribute value is atomic and repeating groups are not stored in a single field. UCMS stores each meeting in a COURSE_SCHEDULE row, each registration in an ENROLLMENT row and each assessment in a GRADE row. It does not store multiple schedules or assessment scores in repeating columns.

## Second Normal Form (2NF)
A relation is in 2NF when it is in 1NF and every non-prime attribute is fully functionally dependent on every candidate key. Most relations use a single-column surrogate key, so partial dependency on a proper subset of the primary key does not arise. The composite-key relation COURSE_PREREQUISITE(course_id, prerequisite_course_id, minimum_grade) stores a minimum grade for the specific course/prerequisite pair; minimum_grade depends on the complete pair.

## Third Normal Form (3NF)
A relation is in 3NF when it is in 2NF and non-key attributes do not depend transitively on a candidate key through another non-key attribute. Department facts are stored in DEPARTMENT; PERSON stores shared personal attributes; STUDENT and INSTRUCTOR store subtype-specific facts; COURSE stores catalog facts; SECTION stores term-specific offering facts; ENROLLMENT stores registration facts; GRADE stores assessment facts. This separation avoids repeating descriptive facts in dependent relations.

## Representative functional dependencies
- department_id → department_code, department_name, office_location
- person_id → first_name, last_name, email, phone, date_of_birth
- student_id → person_id, student_number, department_id, program, level, admission_date, status
- course_id → department_id, course_code, title, description, credits, is_active
- enrollment_id → student_id, section_id, enrollment_date, status
- (enrollment_id, assessment_name) → score, max_score, recorded_at
- (course_id, prerequisite_course_id) → minimum_grade

## Constraints and limitations
Primary keys identify rows; foreign keys preserve references; UNIQUE constraints enforce candidate identifiers and relationship uniqueness; CHECK constraints validate domains. The schema models prerequisite relationships but the Flask enrollment route does not yet enforce prerequisite completion. A formal grade scale and explicit institutional policies should be defined before production use.