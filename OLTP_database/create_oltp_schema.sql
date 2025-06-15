--- 1 таблица Users
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE
);


---- 2 таблица Categories
DROP TABLE IF EXISTS Categories;
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE 
);



--- 3 таблица Course
DROP TABLE IF EXISTS Course;
CREATE TABLE Course (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) UNIQUE,
    category_id INTEGER REFERENCES Categories(category_id),
    has_certificate BOOLEAN,
    price DECIMAL(10,2)
);



--- 4 таблица Records
DROP TABLE IF EXISTS Records;
CREATE TABLE Records (
    user_id INTEGER REFERENCES Users(user_id),
    course_id INTEGER REFERENCES Course(course_id),
    records_date DATE,
    status VARCHAR(50),
    PRIMARY KEY (user_id, course_id)
);



--- 5 таблица Rating
DROP TABLE IF EXISTS Rating;
CREATE TABLE Rating (
    user_id INTEGER REFERENCES Users(user_id),
    course_id INTEGER REFERENCES Course(course_id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    PRIMARY KEY (user_id, course_id)
);



--- 6 таблица Certificate
DROP TABLE IF EXISTS Certificate;
CREATE TABLE Certificate (
    certificate_id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES Course(course_id),
    user_id INTEGER REFERENCES Users(user_id),
    issue_date DATE
);


--- 7 таблица Payment
DROP TABLE IF EXISTS Payment;
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(user_id),
    course_id INTEGER REFERENCES Course(course_id),
    total_amount DECIMAL(10,2),
    payment_date DATE
);




--- 8 таблица Instructors
DROP TABLE IF EXISTS Instructors;
CREATE TABLE Instructors (
    instructor_id SERIAL PRIMARY KEY,
    instructor_name VARCHAR(100) UNIQUE
);


DROP TABLE IF EXISTS Course_Instructors;
CREATE TABLE Course_Instructors (
    course_id INTEGER REFERENCES Course(course_id) ON DELETE CASCADE,
    instructor_id INTEGER REFERENCES Instructors(instructor_id) ON DELETE CASCADE,
    PRIMARY KEY (course_id, instructor_id)
);






