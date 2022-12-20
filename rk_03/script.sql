
CREATE DATABASE rk3;

--- Задание 1
REATE TABLE IF NOT EXISTS staff
(
    id SERIAL PRIMARY KEY,
    fio text not null,
    birthday date NOT NULL,
    department text
);

CREATE TABLE IF NOT EXISTS type_track
(
    id SERIAL PRIMARY KEY,
    name text not null
);

create type days as enum (
    'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    );

CREATE TABLE IF NOT EXISTS staff_track
(
    id SERIAL PRIMARY KEY,
    idstaff int references staff(id),
    date date NOT NULL DEFAULT CURRENT_DATE,
    dayofweek days not null,
    time time not null,
    type int references type_track(id)
);

INSERT INTO staff (fio, birthday, department)
            values ('Иванов Иван Иванович', to_timestamp('25-09-1990', 'DD-MM-YYYY'), 'ИТ'),
                   ('Петров Петр Петрович', to_timestamp('12-11-1987', 'DD-MM-YYYY'), 'Бухгалтерия');

INSERT into type_track (name)
    values ('пришел'), ('вышел');

INSERT INTO staff_track(idstaff, date, dayofweek, time, type)
values (1, to_timestamp('14-12-2018', 'DD-MM-YYYY'), 'Суббота', '9:00', 1),
       (1, to_timestamp('14-12-2018', 'DD-MM-YYYY'), 'Суббота', '9:20', 2),
       (1, to_timestamp('14-12-2018', 'DD-MM-YYYY'), 'Суббота', '9:25', 1),
       (2, to_timestamp('14-12-2018', 'DD-MM-YYYY'), 'Суббота', '9:05', 1);

-- 
CREATE OR REPLACE FUNCTION get_min_age_late_10()
RETURNS INTEGER
AS $$
    with late(id, fio, age, arrive) as (
        -- Вычисляю возраст и объединяю данные
        Select s.id, s.fio, 
            date_part('year', current_date) - date_part('year', birthday) as age,
            st.late_arrive::int
        from staff as s
        join (
            -- Получаю данные внезависимости от даты
            Select idstaff as id, date, 
                date_part('minute', MIN(time) - '9:00') + 
                date_part('hour', MIN(time) - '9:00') * 60 as late_arrive
            from staff_track
            where type = 1
            GROUP BY idstaff, date) as st on st.id = s.id
    )
    Select MIN(age) from late
    where arrive > 10;         
$$ LANGUAGE SQL;

Select * from get_min_age_late_10();