INSERT OR IGNORE INTO department(department_id,department_code,department_name,office_location) VALUES
(1,'CS','Computer Science','Engineering Building 2'),
(2,'MATH','Mathematics','Science Building 1'),
(3,'BUS','Business Administration','Business Building');
INSERT OR IGNORE INTO person(person_id,first_name,last_name,email,phone) VALUES
(1,'Aylin','Demir','aylin.demir@example.edu','555-0101'),
(2,'Mert','Yilmaz','mert.yilmaz@example.edu','555-0102'),
(3,'Deniz','Kaya','deniz.kaya@example.edu','555-0103'),
(4,'Selin','Arslan','selin.arslan@example.edu','555-0104'),
(5,'Can','Aydin','can.aydin@example.edu','555-0105'),
(6,'Dr. Ece','Aksoy','ece.aksoy@example.edu','555-0201'),
(7,'Dr. Bora','Celik','bora.celik@example.edu','555-0202');
INSERT OR IGNORE INTO student(student_id,person_id,student_number,department_id,program,level,admission_date) VALUES
(1,1,'2024001',1,'BSc Computer Science',2,'2024-09-01'),
(2,2,'2024002',1,'BSc Computer Science',2,'2024-09-01'),
(3,3,'2023001',2,'BSc Mathematics',3,'2023-09-01'),
(4,4,'2025001',1,'BSc Computer Science',1,'2025-09-01'),
(5,5,'2023002',3,'BBA',3,'2023-09-01');
INSERT OR IGNORE INTO instructor(instructor_id,person_id,department_id,academic_rank,hire_date) VALUES
(1,6,1,'ASSISTANT_PROFESSOR','2020-09-01'),
(2,7,2,'ASSOCIATE_PROFESSOR','2018-02-01');
INSERT OR IGNORE INTO academic_term(term_id,term_name,start_date,end_date,registration_start,registration_end) VALUES
(1,'2026-2027 Fall','2026-09-21','2027-01-15','2026-08-15','2026-09-20'),
(2,'2026-2027 Spring','2027-02-08','2027-06-18','2027-01-05','2027-02-07');
INSERT OR IGNORE INTO course(course_id,department_id,course_code,title,description,credits) VALUES
(1,1,'CS101','Introduction to Programming','Programming fundamentals',4),
(2,1,'CS201','Data Structures','Core data structures and algorithms',4),
(3,1,'CS301','Fundamentals of Database Systems','Data modeling, relational databases and SQL',4),
(4,2,'MATH101','Calculus I','Differential and integral calculus',5),
(5,3,'BUS101','Introduction to Management','Management principles',3);
INSERT OR IGNORE INTO classroom(classroom_id,building,room_number,capacity) VALUES
(1,'Engineering','E-101',40),(2,'Science','S-205',35),(3,'Business','B-110',50);
INSERT OR IGNORE INTO section(section_id,course_id,term_id,instructor_id,classroom_id,section_number,capacity,status) VALUES
(1,1,1,1,1,'A',30,'OPEN'),(2,2,1,1,1,'A',25,'OPEN'),(3,3,1,1,1,'A',25,'OPEN'),
(4,4,1,2,2,'A',30,'OPEN'),(5,5,1,NULL,3,'A',40,'OPEN');
INSERT OR IGNORE INTO course_prerequisite(course_id,prerequisite_course_id,minimum_grade) VALUES
(2,1,'C'),(3,2,'C');
INSERT OR IGNORE INTO course_schedule(schedule_id,section_id,day_of_week,start_time,end_time) VALUES
(1,1,1,'09:00','10:30'),(2,1,3,'09:00','10:30'),
(3,2,2,'11:00','12:30'),(4,2,4,'11:00','12:30'),
(5,3,1,'13:00','14:30'),(6,3,3,'13:00','14:30');
INSERT OR IGNORE INTO enrollment(enrollment_id,student_id,section_id,enrollment_date,status) VALUES
(1,1,1,'2026-09-10','ENROLLED'),(2,2,1,'2026-09-10','ENROLLED'),
(3,3,4,'2026-09-11','ENROLLED'),(4,4,1,'2026-09-12','ENROLLED'),
(5,1,3,'2026-09-12','ENROLLED');
INSERT OR IGNORE INTO grade(grade_id,enrollment_id,assessment_name,score,max_score) VALUES
(1,1,'Midterm',82,100),(2,1,'Assignment 1',18,20),(3,2,'Midterm',74,100),(4,3,'Midterm',91,100);
