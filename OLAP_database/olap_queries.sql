---1) Топ-3 месяца по выручке
SELECT 
    dt.year,
    dt.month,
    SUM(fp.total_amount) AS total_revenue
FROM dwh_Fact_Payment fp
JOIN dwh_Dim_Time dt ON fp.time_id = dt.time_id
GROUP BY dt.year, dt.month
ORDER BY total_revenue DESC
LIMIT 3;


----2) Индекс популярности курсов
SELECT 
    dc.course_name,
    dt.year,
    ROUND(AVG(fr.rating)::NUMERIC, 2) AS avg_rating
FROM dwh_Fact_Rating fr
JOIN dwh_Dim_Course dc ON fr.course_id = dc.course_id
JOIN dwh_Fact_Enrollment fe ON fe.user_sk = fr.user_sk AND fe.course_id = fr.course_id
JOIN dwh_Dim_Time dt ON dt.time_id = fe.time_id
GROUP BY dc.course_name, dt.year
ORDER BY dc.course_name, dt.year;



----3) Вклад каждого инструктора в общую выручку
SELECT 
    di.instructor_name,
    ROUND(SUM(fp.total_amount)::NUMERIC, 2) AS total_revenue
FROM dwh_Bridge_Instructor_Course bic
JOIN dwh_Dim_Instructor di ON di.instructor_id = bic.instructor_id
JOIN dwh_Fact_Payment fp ON fp.course_id = bic.course_id
GROUP BY di.instructor_name
ORDER BY total_revenue DESC;




-----4) Платежеспособность пользователей по годам
SELECT 
    du.name,
    dt.year,
    SUM(fp.total_amount) AS yearly_spending
FROM dwh_Fact_Payment fp
JOIN dwh_Dim_User du ON du.user_sk = fp.user_sk
JOIN dwh_Dim_Time dt ON dt.time_id = fp.time_id
GROUP BY du.name, dt.year
ORDER BY du.name, dt.year;





------ 

