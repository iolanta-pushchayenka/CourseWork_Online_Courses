DROP MATERIALIZED VIEW IF EXISTS dwh_Agg_Monthly_Payments;
DROP MATERIALIZED VIEW IF EXISTS dwh_Agg_Course_Rating;

DROP TABLE IF EXISTS dwh_Fact_Payment;
DROP TABLE IF EXISTS dwh_Fact_Enrollment;
DROP TABLE IF EXISTS dwh_Fact_Rating;
DROP TABLE IF EXISTS dwh_Bridge_Instructor_Course;
DROP TABLE IF EXISTS dwh_Dim_Instructor;
DROP TABLE IF EXISTS dwh_Dim_User;
DROP TABLE IF EXISTS dwh_Dim_Course;
DROP TABLE IF EXISTS dwh_Dim_Category;
DROP TABLE IF EXISTS dwh_Dim_Time;




----- создаем dim tables 
CREATE TABLE IF NOT EXISTS dwh_Dim_Time (
    time_id SERIAL PRIMARY KEY,
    date DATE UNIQUE,
    day INT,
    month INT,
    quarter INT,
    year INT
);


CREATE TABLE dwh_Dim_Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100)
);


CREATE TABLE dwh_Dim_Course (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100),
    category_id INT REFERENCES dwh_Dim_Category(category_id),
    has_certificate BOOLEAN
);


CREATE TABLE dwh_Dim_User (
    user_sk SERIAL PRIMARY KEY,
    user_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE,
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN,
    UNIQUE (user_id, start_date)
);



CREATE TABLE dwh_Dim_Instructor (
    instructor_id SERIAL PRIMARY KEY,
    instructor_name VARCHAR(100)
); 




---- создаем Bridge  таблицу
CREATE TABLE dwh_Bridge_Instructor_Course (
    instructor_id INT REFERENCES dwh_Dim_Instructor(instructor_id),
    course_id INT REFERENCES dwh_Dim_Course(course_id),
    PRIMARY KEY (instructor_id, course_id)
);





--- создаем Fact таблицы 
CREATE TABLE dwh_Fact_Rating (
    user_sk INT REFERENCES dwh_Dim_User(user_sk),
    course_id INT REFERENCES dwh_Dim_Course(course_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    PRIMARY KEY (user_sk, course_id)
);


CREATE TABLE dwh_Fact_Enrollment (
    user_sk INT REFERENCES dwh_Dim_User(user_sk),
    course_id INT REFERENCES dwh_Dim_Course(course_id),
    time_id INT REFERENCES dwh_Dim_Time(time_id),
    status VARCHAR(50),
    PRIMARY KEY (user_sk, course_id, time_id)
);


CREATE TABLE dwh_Fact_Payment (
    user_sk INT REFERENCES dwh_Dim_User(user_sk),
    course_id INT REFERENCES dwh_Dim_Course(course_id),
    time_id INT REFERENCES dwh_Dim_Time(time_id),
    total_amount DECIMAL(10,2),
    PRIMARY KEY (user_sk, course_id, time_id)
);


CREATE MATERIALIZED VIEW IF NOT EXISTS dwh_Agg_Monthly_Payments AS
SELECT
    dt.year,
    TO_CHAR(TO_DATE(dt.month::text, 'MM'), 'Month') AS month,
    SUM(fp.total_amount) AS monthly_total,        
    COUNT(DISTINCT fp.user_sk) AS paying_users,    
    COUNT(DISTINCT fp.course_id) AS paid_courses  
FROM dwh_Fact_Payment fp
JOIN dwh_Dim_Time dt ON dt.time_id = fp.time_id
GROUP BY dt.year, dt.month
ORDER BY dt.year, dt.month;

  



CREATE MATERIALIZED VIEW IF NOT EXISTS dwh_Agg_Course_Rating AS
SELECT 
    dc.course_id,                         
    dc.course_name,                      
    AVG(fr.rating)::NUMERIC(3,2) AS avg_rating,
    COUNT(fr.rating) AS total_ratings    
FROM dwh_Fact_Rating fr
JOIN dwh_Dim_Course dc 
  ON dc.course_id = fr.course_id       
GROUP BY dc.course_id, dc.course_name    
ORDER BY avg_rating DESC;                

