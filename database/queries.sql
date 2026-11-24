-- UCMS SQL examples: joins, aggregation, subqueries, CTEs and DML.
-- Run against a database initialized with schema.sql and sample_data.sql.

-- 1. Active student directory
SELECT st.student_number,p.first_name,p.last_name,d.department_name
FROM student st JOIN person p ON p.person_id=st.person_id
JOIN department d ON d.department_id=st.department_id
WHERE st.status='ACTIVE';

-- 2. Course section counts
SELECT c.course_code,c.title,COUNT(s.section_id) AS section_count
FROM course c LEFT JOIN section s ON s.course_id=c.course_id
GROUP BY c.course_id;

-- 3. Current section roster view
SELECT * FROM v_section_roster ORDER BY course_code,student_number;

-- 4. Students with more than one active enrollment
SELECT st.student_number,COUNT(*) AS enrollment_count
FROM student st JOIN enrollment e ON e.student_id=st.student_id
WHERE e.status='ENROLLED'
GROUP BY st.student_id HAVING COUNT(*)>1;

-- 5. Courses without a prerequisite
SELECT c.course_code,c.title FROM course c
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisite cp WHERE cp.course_id=c.course_id);

-- 6. Section seat availability
SELECT s.section_id,c.course_code,s.section_number,s.capacity,
       COUNT(e.enrollment_id) AS enrolled,
       s.capacity-COUNT(e.enrollment_id) AS seats_remaining
FROM section s JOIN course c ON c.course_id=s.course_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY s.section_id;

-- 7. Department student totals
SELECT d.department_name,COUNT(st.student_id) AS student_count
FROM department d LEFT JOIN student st ON st.department_id=d.department_id
GROUP BY d.department_id;

-- 8. Student transcript view
SELECT * FROM v_student_transcript ORDER BY student_number,term_name,course_code;

-- 9. Average assessment percentage by course
SELECT c.course_code,ROUND(AVG(100.0*g.score/g.max_score),2) AS average_percentage
FROM grade g JOIN enrollment e ON e.enrollment_id=g.enrollment_id
JOIN section s ON s.section_id=e.section_id
JOIN course c ON c.course_id=s.course_id
GROUP BY c.course_id;

-- 10. Students without active enrollments
SELECT st.student_number,p.first_name,p.last_name
FROM student st JOIN person p ON p.person_id=st.person_id
WHERE NOT EXISTS (SELECT 1 FROM enrollment e
                  WHERE e.student_id=st.student_id AND e.status='ENROLLED');

-- 11. Instructor teaching workload
SELECT i.instructor_id,p.first_name,p.last_name,COUNT(s.section_id) AS section_count
FROM instructor i JOIN person p ON p.person_id=i.person_id
LEFT JOIN section s ON s.instructor_id=i.instructor_id
GROUP BY i.instructor_id;

-- 12. Courses offered in a selected term
SELECT t.term_name,c.course_code,c.title,s.section_number
FROM section s JOIN course c ON c.course_id=s.course_id
JOIN academic_term t ON t.term_id=s.term_id
WHERE t.term_id=1;

-- 13. Students taking courses outside their department
SELECT DISTINCT st.student_number,c.course_code
FROM enrollment e JOIN student st ON st.student_id=e.student_id
JOIN section s ON s.section_id=e.section_id
JOIN course c ON c.course_id=s.course_id
WHERE st.department_id<>c.department_id;

-- 14. Top-performing students by average percentage
SELECT st.student_number,p.first_name,p.last_name,
       ROUND(AVG(100.0*g.score/g.max_score),2) AS average_percentage
FROM student st JOIN person p ON p.person_id=st.person_id
JOIN enrollment e ON e.student_id=st.student_id
JOIN grade g ON g.enrollment_id=e.enrollment_id
GROUP BY st.student_id ORDER BY average_percentage DESC LIMIT 10;

-- 15. Course demand using a CTE
WITH demand AS (
 SELECT s.course_id,COUNT(e.enrollment_id) AS enrolled_count
 FROM section s LEFT JOIN enrollment e
 ON e.section_id=s.section_id AND e.status='ENROLLED'
 GROUP BY s.course_id
)
SELECT c.course_code,c.title,d.enrolled_count
FROM demand d JOIN course c ON c.course_id=d.course_id
ORDER BY d.enrolled_count DESC;

-- 16. Parameterized update example (replace ? in application code)
UPDATE person SET phone='555-0199' WHERE person_id=1;

-- 17. Preserve enrollment history by changing status
UPDATE enrollment SET status='DROPPED' WHERE enrollment_id=2;

-- 18. Add a prerequisite relationship
INSERT INTO course_prerequisite(course_id,prerequisite_course_id,minimum_grade)
VALUES (3,1,'C');

-- 19. Remove a prerequisite relationship
DELETE FROM course_prerequisite
WHERE course_id=3 AND prerequisite_course_id=1;

-- 20. Find timetable for a selected student
SELECT st.student_number,c.course_code,cs.day_of_week,cs.start_time,cs.end_time
FROM student st JOIN enrollment e ON e.student_id=st.student_id
JOIN section s ON s.section_id=e.section_id
JOIN course c ON c.course_id=s.course_id
JOIN course_schedule cs ON cs.section_id=s.section_id
WHERE st.student_number='2024001' AND e.status='ENROLLED'
ORDER BY cs.day_of_week,cs.start_time;
