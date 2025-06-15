---1 создаем временную таблицу для Users
CREATE TABLE temp_users (
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE
);


---- 2 создаем временную таблицу Categories и Course
CREATE TABLE temp_categories_and_courses (
    course_name VARCHAR(100),
    category_name VARCHAR(100),
    has_certificate BOOLEAN,
    price DECIMAL(10,2)
);

---3 создаем временную таблицу Categories и Course
CREATE TABLE temp_records_and_ratings (
    email VARCHAR(100),
    course_name VARCHAR(100),
    records_date DATE,
    status VARCHAR(50),
    rating INTEGER
);




----- 4 создаем временную таблицу Certificate и Payment
CREATE TABLE temp_cert_pay (
    email VARCHAR(100),
    course_name VARCHAR(100),
    issue_date DATE,
    total_amount DECIMAL(10,2),
    payment_date DATE
);



-----5 создаем временную таблицу Instructors и Course_Instructors

DROP TABLE IF EXISTS temp_instructors;

CREATE TABLE temp_instructors (
  course_name VARCHAR(100),
  instructor_name VARCHAR(100)
   
);




---1 Загрузка данных из таблицы temp_users
INSERT INTO Users (name, email, registration_date)
SELECT name, email, registration_date
FROM temp_users
ON CONFLICT (email) DO NOTHING;


---2 Загрузка данных из таблицы temp_categories_and_courses 
INSERT INTO Categories (category_name)
SELECT DISTINCT category_name
FROM temp_categories_and_courses
ON CONFLICT (category_name) DO NOTHING;


---3 Загрузка данных из таблицы temp_categories_and_courses 
INSERT INTO Course (course_name, category_id, has_certificate, price)
SELECT 
    t.course_name,
    c.category_id,
    t.has_certificate,
    t.price
FROM temp_categories_and_courses t
JOIN Categories c ON c.category_name = t.category_name
ON CONFLICT DO NOTHING;


----4 Загрузка данных из таблицы temp_records_and_ratings
INSERT INTO Records (user_id, course_id, records_date, status)
SELECT 
    u.user_id,
    c.course_id,
    t.records_date,
    t.status
FROM temp_records_and_ratings t
JOIN Users u ON u.email = t.email
JOIN Course c ON c.course_name = t.course_name
ON CONFLICT DO NOTHING;


---5 Загрузка данных из таблицы temp_records_and_ratings 
INSERT INTO Rating (user_id, course_id, rating)
SELECT 
    u.user_id,
    c.course_id,
    t.rating
FROM temp_records_and_ratings t
JOIN Users u ON u.email = t.email
JOIN Course c ON c.course_name = t.course_name
WHERE t.rating IS NOT NULL
ON CONFLICT DO NOTHING;


--- 6 Загрузка данных из таблицы temp_cert_pay
INSERT INTO Certificate (user_id, course_id, issue_date)
SELECT 
    u.user_id,
    c.course_id,
    t.issue_date
FROM temp_cert_pay t
JOIN Users u ON u.email = t.email
JOIN Course c ON c.course_name = t.course_name
WHERE t.issue_date IS NOT NULL;


----7 Загрузка данных из таблицы temp_cert_pay
INSERT INTO Payment (user_id, course_id, total_amount, payment_date)
SELECT 
    u.user_id,
    c.course_id,
    t.total_amount,
    t.payment_date
FROM temp_cert_pay t
JOIN Users u ON u.email = t.email
JOIN Course c ON c.course_name = t.course_name;


-----8 Загрузка данных из таблицы temp_instructors
INSERT INTO Instructors (instructor_name)
SELECT DISTINCT instructor_name
FROM temp_instructors
ON CONFLICT (instructor_name) DO NOTHING;


-----9 Загрузка данных из таблицы temp_instructors
INSERT INTO Course_Instructors (course_id, instructor_id)
SELECT
    c.course_id,
    i.instructor_id
FROM temp_instructors t
JOIN Course c ON c.course_name = t.course_name
JOIN Instructors i ON i.instructor_name = t.instructor_name
order by instructor_id
ON CONFLICT DO NOTHING;

