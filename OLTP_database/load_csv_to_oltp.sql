---1 создаем таблицу пользователей, дальше создаем временную таблицу юзеров через импорт вставляем в временную таблицу  данные и дальше из вр таблицы вставляем в обычную таблицу 

CREATE TABLE temp_users (
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE
);


---- 2 временная таблица Categories
CREATE TABLE temp_categories_and_courses (
    course_name VARCHAR(100),
    category_name VARCHAR(100),
    has_certificate BOOLEAN,
    price DECIMAL(10,2)
);

---3 временная таблица
CREATE TABLE temp_records_and_ratings (
    email VARCHAR(100),
    course_name VARCHAR(100),
    records_date DATE,
    status VARCHAR(50),
    rating INTEGER
);




----- 4 временная таблица
CREATE TABLE temp_cert_pay (
    email VARCHAR(100),
    course_name VARCHAR(100),
    issue_date DATE,
    total_amount DECIMAL(10,2),
    payment_date DATE
);



-----5 временная таблица

DROP TABLE IF EXISTS temp_instructors;

CREATE TABLE temp_instructors (
  course_name VARCHAR(100),
  instructor_name VARCHAR(100)
   
);




---1 
INSERT INTO Users (name, email, registration_date)
SELECT name, email, registration_date
FROM temp_users
ON CONFLICT (email) DO NOTHING;


select * from Users;

---2 вставка категорий из таблицы  temp_categories_and_courses 
INSERT INTO Categories (category_name)
SELECT DISTINCT category_name
FROM temp_categories_and_courses
ON CONFLICT (category_name) DO NOTHING;


---3 вставка курсов из таблицы  temp_categories_and_courses 
INSERT INTO Course (course_name, category_id, has_certificate, price)
SELECT 
    t.course_name,
    c.category_id,
    t.has_certificate,
    t.price
FROM temp_categories_and_courses t
JOIN Categories c ON c.category_name = t.category_name
ON CONFLICT DO NOTHING;

select * from  Course;




----4 вставка записей на курс из временной таблицы 
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



select * from  Records;

---5 вставка рейтинга из временной таблицы 
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


SELECT * FROM Records ORDER BY user_id;
select * from  Rating ORDER BY user_id;



--- 6 вставка сертификатов 
INSERT INTO Certificate (user_id, course_id, issue_date)
SELECT 
    u.user_id,
    c.course_id,
    t.issue_date
FROM temp_cert_pay t
JOIN Users u ON u.email = t.email
JOIN Course c ON c.course_name = t.course_name
WHERE t.issue_date IS NOT NULL;

select * from  Certificate;



----7 вставка платежей 
INSERT INTO Payment (user_id, course_id, total_amount, payment_date)
SELECT 
    u.user_id,
    c.course_id,
    t.total_amount,
    t.payment_date
FROM temp_cert_pay t
JOIN Users u ON u.email = t.email
JOIN Course c ON c.course_name = t.course_name;




SELECT * FROM Certificate  ORDER BY certificate_id;
select * from  Payment ORDER BY user_id;



  
-----8 
INSERT INTO Instructors (instructor_name)
SELECT DISTINCT instructor_name
FROM temp_instructors
ON CONFLICT (instructor_name) DO NOTHING;

-----9 
INSERT INTO Course_Instructors (course_id, instructor_id)
SELECT
    c.course_id,
    i.instructor_id
FROM temp_instructors t
JOIN Course c ON c.course_name = t.course_name
JOIN Instructors i ON i.instructor_name = t.instructor_name
order by instructor_id
ON CONFLICT DO NOTHING;




select * from  temp_instructors;
select * from course ;
select * from  Instructors;
select * from  course_instructors;

 

