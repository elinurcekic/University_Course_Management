-- UCMS extended query library (20+ examples).
-- Run schema.sql, sample_data.sql and expanded_sample_data.sql before these queries.

-- 1. Who takes a particular course? Change the course code.
SELECT c.course_code,c.title,st.student_number,p.first_name || ' ' || p.last_name AS student_name,t.term_name
FROM course c JOIN section s ON s.course_id=c.course_id JOIN academic_term t ON t.term_id=s.term_id
JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
JOIN student st ON st.student_id=e.student_id JOIN person p ON p.person_id=st.person_id
WHERE c.course_code='MATH201' ORDER BY p.last_name,p.first_name;

-- 2. Students taking any course in the Mathematics department.
SELECT DISTINCT st.student_number,p.first_name || ' ' || p.last_name AS student_name,c.course_code,c.title
FROM department d JOIN course c ON c.department_id=d.department_id JOIN section s ON s.course_id=c.course_id
JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
JOIN student st ON st.student_id=e.student_id JOIN person p ON p.person_id=st.person_id
WHERE d.department_code='MATH' ORDER BY c.course_code,student_name;

-- 3. Full roster for every course and section.
SELECT c.course_code,c.title,s.section_number,st.student_number,p.first_name,p.last_name
FROM section s JOIN course c ON c.course_id=s.course_id JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
JOIN student st ON st.student_id=e.student_id JOIN person p ON p.person_id=st.person_id
ORDER BY c.course_code,s.section_number,p.last_name;

-- 4. Top 10 most popular courses.
SELECT c.course_code,c.title,COUNT(e.enrollment_id) AS active_students
FROM course c LEFT JOIN section s ON s.course_id=c.course_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY c.course_id ORDER BY active_students DESC LIMIT 10;

-- 5. Section occupancy and remaining seats.
SELECT c.course_code,s.section_number,s.capacity,COUNT(e.enrollment_id) AS enrolled,
s.capacity-COUNT(e.enrollment_id) AS seats_left,ROUND(100.0*COUNT(e.enrollment_id)/s.capacity,1) AS occupancy_percent
FROM section s JOIN course c ON c.course_id=s.course_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY s.section_id ORDER BY occupancy_percent DESC;

-- 6. Student course load by term.
SELECT st.student_number,p.first_name,p.last_name,COUNT(e.enrollment_id) AS course_count
FROM student st JOIN person p ON p.person_id=st.person_id
LEFT JOIN enrollment e ON e.student_id=st.student_id AND e.status='ENROLLED'
LEFT JOIN section s ON s.section_id=e.section_id AND s.term_id=1
GROUP BY st.student_id ORDER BY course_count DESC;

-- 7. Students without active enrollments.
SELECT st.student_number,p.first_name,p.last_name FROM student st JOIN person p ON p.person_id=st.person_id
WHERE NOT EXISTS (SELECT 1 FROM enrollment e WHERE e.student_id=st.student_id AND e.status='ENROLLED');

-- 8. Average grade percentage by course.
SELECT c.course_code,c.title,ROUND(AVG(100.0*g.score/g.max_score),2) AS avg_percent,COUNT(g.grade_id) AS assessments
FROM course c LEFT JOIN section s ON s.course_id=c.course_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
LEFT JOIN grade g ON g.enrollment_id=e.enrollment_id
GROUP BY c.course_id ORDER BY avg_percent DESC;

-- 9. Students with average grade above 85%.
SELECT st.student_number,p.first_name,p.last_name,ROUND(AVG(100.0*g.score/g.max_score),1) AS average_percent
FROM student st JOIN person p ON p.person_id=st.person_id JOIN enrollment e ON e.student_id=st.student_id
JOIN grade g ON g.enrollment_id=e.enrollment_id GROUP BY st.student_id
HAVING AVG(100.0*g.score/g.max_score)>85 ORDER BY average_percent DESC;

-- 10. Course count by department.
SELECT d.department_code,d.department_name,COUNT(c.course_id) AS courses
FROM department d LEFT JOIN course c ON c.department_id=d.department_id
GROUP BY d.department_id ORDER BY courses DESC;

-- 11. Instructors and their assigned sections.
SELECT p.first_name || ' ' || p.last_name AS instructor_name,c.course_code,c.title,s.section_number
FROM section s JOIN course c ON c.course_id=s.course_id
LEFT JOIN instructor i ON i.instructor_id=s.instructor_id LEFT JOIN person p ON p.person_id=i.person_id
ORDER BY instructor_name,c.course_code;

-- 12. Students enrolled in at least three courses.
SELECT st.student_number,p.first_name,p.last_name,COUNT(e.enrollment_id) AS course_count
FROM student st JOIN person p ON p.person_id=st.person_id
JOIN enrollment e ON e.student_id=st.student_id AND e.status='ENROLLED'
GROUP BY st.student_id HAVING COUNT(e.enrollment_id)>=3 ORDER BY course_count DESC;

-- 13. Courses with no active registrations.
SELECT c.course_code,c.title FROM course c
WHERE NOT EXISTS (SELECT 1 FROM section s JOIN enrollment e ON e.section_id=s.section_id
WHERE s.course_id=c.course_id AND e.status='ENROLLED');

-- 14. Detailed student transcript with grade percentage.
SELECT st.student_number,p.first_name,p.last_name,c.course_code,c.title,g.assessment_name,
g.score,g.max_score,ROUND(100.0*g.score/g.max_score,2) AS percentage
FROM grade g JOIN enrollment e ON e.enrollment_id=g.enrollment_id
JOIN student st ON st.student_id=e.student_id JOIN person p ON p.person_id=st.person_id
JOIN section s ON s.section_id=e.section_id JOIN course c ON c.course_id=s.course_id
ORDER BY st.student_number,c.course_code;

-- 15. Students taking a course but with no grade recorded.
SELECT DISTINCT st.student_number,p.first_name,p.last_name,c.course_code,c.title
FROM enrollment e JOIN student st ON st.student_id=e.student_id JOIN person p ON p.person_id=st.person_id
JOIN section s ON s.section_id=e.section_id JOIN course c ON c.course_id=s.course_id
LEFT JOIN grade g ON g.enrollment_id=e.enrollment_id
WHERE e.status='ENROLLED' AND g.grade_id IS NULL;

-- 16. Weekly schedule by day and time.
SELECT c.course_code,c.title,s.section_number,cs.day_of_week,cs.start_time,cs.end_time
FROM course_schedule cs JOIN section s ON s.section_id=cs.section_id JOIN course c ON c.course_id=s.course_id
ORDER BY cs.day_of_week,cs.start_time;

-- 17. Registration totals per academic term.
SELECT t.term_name,COUNT(e.enrollment_id) AS total_enrollments
FROM academic_term t JOIN section s ON s.term_id=t.term_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY t.term_id ORDER BY t.start_date;

-- 18. Courses with enrollment above the average course enrollment.
WITH course_counts AS (
 SELECT c.course_id,c.course_code,c.title,COUNT(e.enrollment_id) AS n
 FROM course c LEFT JOIN section s ON s.course_id=c.course_id
 LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
 GROUP BY c.course_id
)
SELECT course_code,title,n FROM course_counts WHERE n>(SELECT AVG(n) FROM course_counts) ORDER BY n DESC;

-- 19. Course prerequisite map.
SELECT c.course_code AS course,pr.course_code AS prerequisite,cp.minimum_grade
FROM course_prerequisite cp JOIN course c ON c.course_id=cp.course_id
JOIN course pr ON pr.course_id=cp.prerequisite_course_id ORDER BY c.course_code;

-- 20. Enrollment totals by department.
SELECT d.department_code,COUNT(DISTINCT e.enrollment_id) AS enrollments
FROM department d LEFT JOIN course c ON c.department_id=d.department_id
LEFT JOIN section s ON s.course_id=c.course_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY d.department_id ORDER BY enrollments DESC;

-- 21. Highest recorded score in each course.
SELECT c.course_code,c.title,MAX(100.0*g.score/g.max_score) AS highest_percentage
FROM course c JOIN section s ON s.course_id=c.course_id JOIN enrollment e ON e.section_id=s.section_id
JOIN grade g ON g.enrollment_id=e.enrollment_id GROUP BY c.course_id ORDER BY highest_percentage DESC;

-- 22. Courses with average assessment below 70%.
SELECT c.course_code,c.title,ROUND(AVG(100.0*g.score/g.max_score),1) AS average_percentage
FROM course c JOIN section s ON s.course_id=c.course_id JOIN enrollment e ON e.section_id=s.section_id
JOIN grade g ON g.enrollment_id=e.enrollment_id GROUP BY c.course_id
HAVING AVG(100.0*g.score/g.max_score)<70 ORDER BY average_percentage;

-- 23. Student count by department and academic level.
SELECT d.department_name,st.level,COUNT(*) AS student_count
FROM student st JOIN department d ON d.department_id=st.department_id
GROUP BY d.department_id,st.level ORDER BY d.department_name,st.level;

-- 24. Sections with fewer than 10 seats remaining.
SELECT c.course_code,s.section_number,s.capacity-COUNT(e.enrollment_id) AS seats_remaining
FROM section s JOIN course c ON c.course_id=s.course_id
LEFT JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED'
GROUP BY s.section_id HAVING seats_remaining<10 ORDER BY seats_remaining;

-- 25. Student list for a chosen course prefix (example: all MATH courses).
SELECT DISTINCT st.student_number,p.first_name,p.last_name,c.course_code,c.title
FROM course c JOIN section s ON s.course_id=c.course_id JOIN enrollment e ON e.section_id=s.section_id
JOIN student st ON st.student_id=e.student_id JOIN person p ON p.person_id=st.person_id
WHERE c.course_code LIKE 'MATH%' AND e.status='ENROLLED'
ORDER BY c.course_code,p.last_name;
