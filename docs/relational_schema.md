# Relational Schema and Key Design

- DEPARTMENT(**department_id**, department_code UQ, department_name UQ, office_location)
- PERSON(**person_id**, first_name, last_name, email UQ, phone, date_of_birth)
- STUDENT(**student_id**, person_id FK/UQ, student_number UQ, department_id FK, program, level, admission_date, status)
- INSTRUCTOR(**instructor_id**, person_id FK/UQ, department_id FK, academic_rank, hire_date)
- ACADEMIC_TERM(**term_id**, term_name UQ, start_date, end_date, registration_start, registration_end)
- COURSE(**course_id**, department_id FK, course_code UQ, title, description, credits, is_active)
- CLASSROOM(**classroom_id**, building, room_number, capacity, UQ(building, room_number))
- SECTION(**section_id**, course_id FK, term_id FK, instructor_id FK nullable, classroom_id FK nullable, section_number, capacity, status)
- COURSE_PREREQUISITE(**course_id** FK, **prerequisite_course_id** FK, minimum_grade), composite primary key
- COURSE_SCHEDULE(**schedule_id**, section_id FK, day_of_week, start_time, end_time)
- ENROLLMENT(**enrollment_id**, student_id FK, section_id FK, enrollment_date, status, UQ(student_id, section_id))
- GRADE(**grade_id**, enrollment_id FK, assessment_name, score, max_score, recorded_at, UQ(enrollment_id, assessment_name))

## Constraints
Primary keys identify rows; foreign keys preserve referential integrity; UNIQUE constraints enforce candidate identifiers and registration uniqueness; CHECK constraints validate statuses, levels, credits, capacities, date/time values and scores. Triggers enforce enrollment capacity, timetable collision and grade eligibility rules.
