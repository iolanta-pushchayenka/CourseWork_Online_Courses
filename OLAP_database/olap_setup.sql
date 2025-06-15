DROP SERVER IF EXISTS oltp_server CASCADE;
DROP EXTENSION IF EXISTS postgres_fdw CASCADE;



CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER oltp_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (
        host 'localhost',
        dbname 'OLTP_OnlineCourses_database',
        port '5432'
    );

CREATE USER MAPPING FOR CURRENT_USER
    SERVER oltp_server
    OPTIONS (
        user 'postgres',
        password '01052006'
    );


IMPORT FOREIGN SCHEMA public
    LIMIT TO ( rating, payment, categories, course, users, instructors, temp_instructors, records)
    FROM SERVER oltp_server
    INTO public;

