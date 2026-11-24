PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS department (
 department_id INTEGER PRIMARY KEY,
 department_code TEXT NOT NULL UNIQUE,
 department_name TEXT NOT NULL UNIQUE,
 office_location TEXT
);
CREATE TABLE IF NOT EXISTS person (
 person_id INTEGER PRIMARY KEY,
 first_name TEXT NOT NULL,
 last_name TEXT NOT NULL,
 email TEXT NOT NULL UNIQUE COLLATE NOCASE,
 phone TEXT,
 date_of_birth TEXT,
 CHECK(date_of_birth IS NULL OR date(date_of_birth) IS NOT NULL)
);
CREATE TABLE IF NOT EXISTS student (
 student_id INTEGER PRIMARY KEY,
 person_id INTEGER NOT NULL UNIQUE,
 student_number TEXT NOT NULL UNIQUE,
 department_id INTEGER NOT NULL,
 program TEXT NOT NULL,
 level INTEGER NOT NULL CHECK(level BETWEEN 1 AND 8),
 admission_date TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','GRADUATED','SUSPENDED','WITHDRAWN')),
 FOREIGN KEY(person_id) REFERENCES person(person_id) ON DELETE CASCADE,
 FOREIGN KEY(department_id) REFERENCES department(department_id)
);
CREATE TABLE IF NOT EXISTS instructor (
 instructor_id INTEGER PRIMARY KEY,
 person_id INTEGER NOT NULL UNIQUE,
 department_id INTEGER NOT NULL,
 academic_rank TEXT NOT NULL CHECK(academic_rank IN ('LECTURER','ASSISTANT_PROFESSOR','ASSOCIATE_PROFESSOR','PROFESSOR')),
 hire_date TEXT NOT NULL,
 FOREIGN KEY(person_id) REFERENCES person(person_id) ON DELETE CASCADE,
 FOREIGN KEY(department_id) REFERENCES department(department_id)
);
CREATE TABLE IF NOT EXISTS academic_term (
 term_id INTEGER PRIMARY KEY,
 term_name TEXT NOT NULL UNIQUE,
 start_date TEXT NOT NULL,
 end_date TEXT NOT NULL,
 registration_start TEXT NOT NULL,
 registration_end TEXT NOT NULL,
 CHECK(date(start_date) < date(end_date)),
 CHECK(date(registration_start) <= date(registration_end))
);
CREATE TABLE IF NOT EXISTS course (
 course_id INTEGER PRIMARY KEY,
 department_id INTEGER NOT NULL,
 course_code TEXT NOT NULL UNIQUE,
 title TEXT NOT NULL,
 description TEXT,
 credits INTEGER NOT NULL CHECK(credits BETWEEN 1 AND 12),
 is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1)),
 FOREIGN KEY(department_id) REFERENCES department(department_id)
);
CREATE TABLE IF NOT EXISTS classroom (
 classroom_id INTEGER PRIMARY KEY,
 building TEXT NOT NULL,
 room_number TEXT NOT NULL,
 capacity INTEGER NOT NULL CHECK(capacity > 0),
 UNIQUE(building,room_number)
);
CREATE TABLE IF NOT EXISTS section (
 section_id INTEGER PRIMARY KEY,
 course_id INTEGER NOT NULL,
 term_id INTEGER NOT NULL,
 instructor_id INTEGER,
 classroom_id INTEGER,
 section_number TEXT NOT NULL,
 capacity INTEGER NOT NULL CHECK(capacity > 0),
 status TEXT NOT NULL DEFAULT 'OPEN' CHECK(status IN ('OPEN','CLOSED','CANCELLED')),
 FOREIGN KEY(course_id) REFERENCES course(course_id),
 FOREIGN KEY(term_id) REFERENCES academic_term(term_id),
 FOREIGN KEY(instructor_id) REFERENCES instructor(instructor_id),
 FOREIGN KEY(classroom_id) REFERENCES classroom(classroom_id),
 UNIQUE(course_id,term_id,section_number)
);
CREATE TABLE IF NOT EXISTS course_prerequisite (
 course_id INTEGER NOT NULL,
 prerequisite_course_id INTEGER NOT NULL,
 minimum_grade TEXT DEFAULT 'D',
 PRIMARY KEY(course_id,prerequisite_course_id),
 CHECK(course_id <> prerequisite_course_id),
 FOREIGN KEY(course_id) REFERENCES course(course_id) ON DELETE CASCADE,
 FOREIGN KEY(prerequisite_course_id) REFERENCES course(course_id)
);
CREATE TABLE IF NOT EXISTS course_schedule (
 schedule_id INTEGER PRIMARY KEY,
 section_id INTEGER NOT NULL,
 day_of_week INTEGER NOT NULL CHECK(day_of_week BETWEEN 1 AND 7),
 start_time TEXT NOT NULL,
 end_time TEXT NOT NULL,
 FOREIGN KEY(section_id) REFERENCES section(section_id) ON DELETE CASCADE,
 CHECK(time(start_time) < time(end_time)),
 UNIQUE(section_id,day_of_week,start_time)
);
CREATE TABLE IF NOT EXISTS enrollment (
 enrollment_id INTEGER PRIMARY KEY,
 student_id INTEGER NOT NULL,
 section_id INTEGER NOT NULL,
 enrollment_date TEXT NOT NULL DEFAULT (date('now')),
 status TEXT NOT NULL DEFAULT 'ENROLLED' CHECK(status IN ('ENROLLED','DROPPED','COMPLETED','WAITLISTED')),
 UNIQUE(student_id,section_id),
 FOREIGN KEY(student_id) REFERENCES student(student_id),
 FOREIGN KEY(section_id) REFERENCES section(section_id)
);
CREATE TABLE IF NOT EXISTS grade (
 grade_id INTEGER PRIMARY KEY,
 enrollment_id INTEGER NOT NULL,
 assessment_name TEXT NOT NULL,
 score REAL NOT NULL CHECK(score >= 0),
 max_score REAL NOT NULL CHECK(max_score > 0 AND score <= max_score),
 recorded_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE(enrollment_id,assessment_name),
 FOREIGN KEY(enrollment_id) REFERENCES enrollment(enrollment_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_student_department ON student(department_id);
CREATE INDEX IF NOT EXISTS idx_course_department ON course(department_id);
CREATE INDEX IF NOT EXISTS idx_section_term ON section(term_id);
CREATE INDEX IF NOT EXISTS idx_enrollment_student ON enrollment(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollment_section ON enrollment(section_id);
CREATE INDEX IF NOT EXISTS idx_grade_enrollment ON grade(enrollment_id);

CREATE VIEW IF NOT EXISTS v_section_roster AS
SELECT s.section_id,c.course_code,c.title,s.section_number,t.term_name,
 st.student_number,p.first_name,p.last_name,e.status AS enrollment_status
FROM section s JOIN course c ON c.course_id=s.course_id
JOIN academic_term t ON t.term_id=s.term_id
JOIN enrollment e ON e.section_id=s.section_id
JOIN student st ON st.student_id=e.student_id
JOIN person p ON p.person_id=st.person_id
WHERE e.status='ENROLLED';

CREATE VIEW IF NOT EXISTS v_student_transcript AS
SELECT st.student_number,p.first_name,p.last_name,c.course_code,c.title,
 t.term_name,g.assessment_name,g.score,g.max_score,
 ROUND(100.0*g.score/g.max_score,2) AS percentage
FROM student st JOIN person p ON p.person_id=st.person_id
JOIN enrollment e ON e.student_id=st.student_id
JOIN section s ON s.section_id=e.section_id
JOIN course c ON c.course_id=s.course_id
JOIN academic_term t ON t.term_id=s.term_id
LEFT JOIN grade g ON g.enrollment_id=e.enrollment_id;

CREATE TRIGGER IF NOT EXISTS trg_enrollment_capacity
BEFORE INSERT ON enrollment WHEN NEW.status='ENROLLED'
BEGIN
 SELECT CASE
 WHEN (SELECT status FROM section WHERE section_id=NEW.section_id)<>'OPEN'
 THEN RAISE(ABORT,'Section is not open')
 WHEN (SELECT COUNT(*) FROM enrollment WHERE section_id=NEW.section_id AND status='ENROLLED')
 >= (SELECT capacity FROM section WHERE section_id=NEW.section_id)
 THEN RAISE(ABORT,'Section capacity reached')
 END;
END;
CREATE TRIGGER IF NOT EXISTS trg_enrollment_capacity_update
BEFORE UPDATE OF section_id,status ON enrollment WHEN NEW.status='ENROLLED'
BEGIN
 SELECT CASE
 WHEN (SELECT status FROM section WHERE section_id=NEW.section_id)<>'OPEN'
 THEN RAISE(ABORT,'Section is not open')
 WHEN (SELECT COUNT(*) FROM enrollment WHERE section_id=NEW.section_id AND status='ENROLLED' AND enrollment_id<>NEW.enrollment_id)
 >= (SELECT capacity FROM section WHERE section_id=NEW.section_id)
 THEN RAISE(ABORT,'Section capacity reached')
 END;
END;
CREATE TRIGGER IF NOT EXISTS trg_section_capacity_update
BEFORE UPDATE OF capacity ON section
WHEN NEW.capacity < (SELECT COUNT(*) FROM enrollment WHERE section_id=OLD.section_id AND status='ENROLLED')
BEGIN SELECT RAISE(ABORT,'New capacity is below current enrollment'); END;
CREATE TRIGGER IF NOT EXISTS trg_grade_enrollment_status
BEFORE INSERT ON grade
WHEN (SELECT status FROM enrollment WHERE enrollment_id=NEW.enrollment_id)<>'ENROLLED'
BEGIN SELECT RAISE(ABORT,'Grades can only be recorded for enrolled students'); END;
CREATE TRIGGER IF NOT EXISTS trg_grade_enrollment_status_update
BEFORE UPDATE OF enrollment_id,score,max_score ON grade
WHEN (SELECT status FROM enrollment WHERE enrollment_id=NEW.enrollment_id)<>'ENROLLED'
BEGIN SELECT RAISE(ABORT,'Grades can only be recorded for enrolled students'); END;

CREATE TRIGGER IF NOT EXISTS trg_prevent_student_schedule_conflict
BEFORE INSERT ON enrollment WHEN NEW.status='ENROLLED'
BEGIN
 SELECT CASE WHEN EXISTS (
 SELECT 1 FROM enrollment e
 JOIN section old_s ON old_s.section_id=e.section_id
 JOIN section new_s ON new_s.section_id=NEW.section_id
 JOIN course_schedule old_cs ON old_cs.section_id=old_s.section_id
 JOIN course_schedule new_cs ON new_cs.section_id=new_s.section_id
 WHERE e.student_id=NEW.student_id AND e.status='ENROLLED'
 AND old_s.term_id=new_s.term_id
 AND old_cs.day_of_week=new_cs.day_of_week
 AND old_cs.start_time<new_cs.end_time
 AND new_cs.start_time<old_cs.end_time
 ) THEN RAISE(ABORT,'Schedule conflict: student already has a class at this time') END;
END;
CREATE TRIGGER IF NOT EXISTS trg_prevent_student_schedule_conflict_update
BEFORE UPDATE OF student_id,section_id,status ON enrollment WHEN NEW.status='ENROLLED'
BEGIN
 SELECT CASE WHEN EXISTS (
 SELECT 1 FROM enrollment e
 JOIN section old_s ON old_s.section_id=e.section_id
 JOIN section new_s ON new_s.section_id=NEW.section_id
 JOIN course_schedule old_cs ON old_cs.section_id=old_s.section_id
 JOIN course_schedule new_cs ON new_cs.section_id=new_s.section_id
 WHERE e.student_id=NEW.student_id AND e.status='ENROLLED'
 AND e.enrollment_id<>NEW.enrollment_id
 AND old_s.term_id=new_s.term_id
 AND old_cs.day_of_week=new_cs.day_of_week
 AND old_cs.start_time<new_cs.end_time
 AND new_cs.start_time<old_cs.end_time
 ) THEN RAISE(ABORT,'Schedule conflict: student already has a class at this time') END;
END;
