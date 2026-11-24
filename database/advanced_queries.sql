-- Additional UCMS SQL examples.
-- 1. Sections with enrollment above the average section enrollment.
WITH section_counts AS (
 SELECT section_id,COUNT(*) AS total
 FROM enrollment WHERE status='ENROLLED' GROUP BY section_id
)
SELECT c.course_code,c.title,sc.total
FROM section_counts sc JOIN section s ON s.section_id=sc.section_id
JOIN course c ON c.course_id=s.course_id
WHERE sc.total>(SELECT AVG(total) FROM section_counts);

-- 2. Students who have completed all prerequisites for course 3.
SELECT st.student_number
FROM student st
WHERE NOT EXISTS (
 SELECT 1 FROM course_prerequisite cp
 WHERE cp.course_id=3 AND NOT EXISTS (
  SELECT 1 FROM enrollment e JOIN section s ON s.section_id=e.section_id
  WHERE e.student_id=st.student_id
    AND s.course_id=cp.prerequisite_course_id AND e.status='COMPLETED'
 )
);

-- 3. Average percentage by student.
SELECT st.student_number,
 ROUND(AVG(100.0*g.score/g.max_score),2) AS average_percentage
FROM student st JOIN enrollment e ON e.student_id=st.student_id
JOIN grade g ON g.enrollment_id=e.enrollment_id
GROUP BY st.student_id;

-- 4. Find sections with no assigned instructor.
SELECT c.course_code,c.title,s.section_number
FROM section s JOIN course c ON c.course_id=s.course_id
WHERE s.instructor_id IS NULL;

-- 5. Detect duplicate registration pairs (should return no rows).
SELECT student_id,section_id,COUNT(*) AS duplicate_count
FROM enrollment GROUP BY student_id,section_id HAVING COUNT(*)>1;

-- 6. Course and department summary.
SELECT d.department_name,COUNT(c.course_id) AS course_count,
       COALESCE(AVG(c.credits),0) AS average_credits
FROM department d LEFT JOIN course c ON c.department_id=d.department_id
GROUP BY d.department_id;

-- 7. Enrollment count by term.
SELECT t.term_name,COUNT(e.enrollment_id) AS enrollment_count
FROM academic_term t JOIN section s ON s.term_id=t.term_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY t.term_id;

-- 8. Assessments for one student.
SELECT st.student_number,c.course_code,g.assessment_name,g.score,g.max_score
FROM grade g JOIN enrollment e ON e.enrollment_id=g.enrollment_id
JOIN student st ON st.student_id=e.student_id
JOIN section s ON s.section_id=e.section_id
JOIN course c ON c.course_id=s.course_id
WHERE st.student_number='2024001';

-- 9. Query plan inspection example.
EXPLAIN QUERY PLAN
SELECT * FROM enrollment WHERE student_id=1 AND status='ENROLLED';

-- 10. Transaction example (run as a unit in a database client).
-- BEGIN;
-- INSERT INTO enrollment(student_id,section_id) VALUES(5,5);
-- COMMIT;
-- ROLLBACK; -- use instead if validation fails.
