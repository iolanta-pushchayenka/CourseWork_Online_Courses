
---1 Пользователи, которые еще не завершили курс
SELECT u.name,  COUNT(*) AS active_courses, r.status
FROM Users u
JOIN Records r ON r.user_id = u.user_id
WHERE r.status IN ('in_progress', 'enrolled')
GROUP BY u.name, r.status;



---2 Курсы — где средний рейтинг выше 4
SELECT  c.category_name,  co.course_name,  ROUND(AVG(r.rating)::numeric, 2) AS avg_rating
FROM Categories c
JOIN Course co ON c.category_id = co.category_id
JOIN Rating r ON co.course_id = r.course_id
GROUP BY c.category_name, co.course_name
HAVING AVG(r.rating) > 4;


--- 3 Курсы которые еще не разу не купили 
SELECT
    co.course_name,
    cat.category_name,
    instr.instructor_name
FROM Course co
JOIN Categories cat ON co.category_id = cat.category_id
LEFT JOIN Course_Instructors ci ON co.course_id = ci.course_id
LEFT JOIN Instructors instr ON ci.instructor_id = instr.instructor_id
WHERE co.course_id NOT IN (SELECT course_id FROM Records)
ORDER BY co.course_name; 


