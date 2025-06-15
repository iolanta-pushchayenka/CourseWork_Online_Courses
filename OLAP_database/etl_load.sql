----------------------------------------------------------------------------------------

INSERT INTO dwh_Dim_Time (date, day, month, quarter, year)
SELECT DISTINCT 
    payment_date,
    EXTRACT(DAY FROM payment_date)::INT,
    EXTRACT(MONTH FROM payment_date)::INT,
    EXTRACT(QUARTER FROM payment_date)::INT,
    EXTRACT(YEAR FROM payment_date)::INT
FROM payment
WHERE payment_date IS NOT NULL
  AND payment_date NOT IN (SELECT date FROM dwh_Dim_Time);

-----------------------------------------------------2

INSERT INTO dwh_Dim_Category (category_name)
SELECT DISTINCT category_name
FROM Categories
WHERE category_name NOT IN (
    SELECT category_name FROM dwh_Dim_Category
);

------------------------------------------------------------3

INSERT INTO dwh_Dim_Course (course_name, category_id, has_certificate)
SELECT c.course_name, dc.category_id, c.has_certificate
FROM Course c
JOIN Categories cat ON cat.category_id = c.category_id
JOIN dwh_Dim_Category dc ON dc.category_name = cat.category_name
WHERE c.course_name NOT IN (
    SELECT course_name FROM dwh_Dim_Course
);

------------------------------------------------------------------4

WITH source_data AS (
  SELECT * FROM users
),
changed_data AS (
  SELECT s.*
  FROM source_data s
  LEFT JOIN dwh_Dim_User d
    ON d.user_id = s.user_id AND d.is_current = true
  WHERE d.user_id IS NULL OR d.name <> s.name OR d.email <> s.email
),
updated AS (
  UPDATE dwh_Dim_User
  SET end_date = CURRENT_DATE, is_current = false
  WHERE user_id IN (SELECT user_id FROM changed_data)
    AND is_current = true
  RETURNING *
)
INSERT INTO dwh_Dim_User (user_id, name, email, registration_date, start_date, end_date, is_current)
SELECT user_id, name, email, registration_date, CURRENT_DATE, NULL, true
FROM changed_data;

--------------------------------------------5

INSERT INTO dwh_Dim_Instructor (instructor_name)
SELECT DISTINCT instructor_name
FROM Instructors
WHERE instructor_name NOT IN (
    SELECT instructor_name FROM dwh_Dim_Instructor
);

-----------------------------------------------------6

INSERT INTO dwh_Bridge_Instructor_Course (instructor_id, course_id)
SELECT di.instructor_id, dc.course_id
FROM temp_instructors ti
JOIN dwh_Dim_Instructor di ON di.instructor_name = ti.instructor_name
JOIN dwh_Dim_Course dc ON dc.course_name = ti.course_name
WHERE NOT EXISTS (
    SELECT 1 FROM dwh_Bridge_Instructor_Course b
    WHERE b.instructor_id = di.instructor_id AND b.course_id = dc.course_id
);

-------------------------------------------------7

INSERT INTO dwh_Fact_Rating (user_sk, course_id, rating)
SELECT
    du.user_sk,
    dc.course_id,
    r.rating
FROM Rating r
JOIN dwh_Dim_User du ON du.user_id = r.user_id AND du.is_current = true
JOIN dwh_Dim_Course dc ON dc.course_id = r.course_id
WHERE NOT EXISTS (
    SELECT 1 FROM dwh_Fact_Rating fr
    WHERE fr.user_sk = du.user_sk AND fr.course_id = dc.course_id
);

-------------------------------------------------8

INSERT INTO dwh_Fact_Enrollment (user_sk, course_id, time_id, status)
SELECT
    du.user_sk,
    dc.course_id,
    dt.time_id,
    r.status
FROM Records r
JOIN dwh_Dim_User du ON du.user_id = r.user_id AND du.is_current = true
JOIN dwh_Dim_Course dc ON dc.course_id = r.course_id
JOIN dwh_Dim_Time dt ON dt.date = r.records_date
WHERE NOT EXISTS (
    SELECT 1 FROM dwh_Fact_Enrollment fe
    WHERE fe.user_sk = du.user_sk AND fe.course_id = dc.course_id AND fe.time_id = dt.time_id
);

--------------------------------------------------------------------------------------------9

INSERT INTO dwh_Fact_Payment (user_sk, course_id, time_id, total_amount)
SELECT
    du.user_sk,
    dc.course_id,
    dt.time_id,
    p.total_amount
FROM Payment p
JOIN dwh_Dim_User du ON du.user_id = p.user_id AND du.is_current = true
JOIN dwh_Dim_Course dc ON dc.course_id = p.course_id
JOIN dwh_Dim_Time dt ON dt.date = p.payment_date
WHERE NOT EXISTS (
    SELECT 1 FROM dwh_Fact_Payment fp
    WHERE fp.user_sk = du.user_sk AND fp.course_id = dc.course_id AND fp.time_id = dt.time_id
);







-- Временное измерение
SELECT * FROM dwh_Dim_Time ORDER BY time_id;

-- Категории
SELECT * FROM dwh_Dim_Category ORDER BY category_id;

-- Курсы
SELECT * FROM dwh_Dim_Course ORDER BY course_id;

-- Пользователи
SELECT * FROM dwh_Dim_User ORDER BY user_sk;

-- Инструкторы
SELECT * FROM dwh_Dim_Instructor ORDER BY instructor_id;

-- Связь инструктор-курс
SELECT * FROM dwh_Bridge_Instructor_Course ORDER BY instructor_id, course_id;




-- Рейтинги
SELECT * FROM dwh_Fact_Rating;

-- Записи на курсы (Enrollment)
SELECT * FROM dwh_Fact_Enrollment ORDER BY user_sk, course_id, time_id;

-- Платежи
SELECT * FROM dwh_Fact_Payment ORDER BY user_sk, course_id, time_id;



