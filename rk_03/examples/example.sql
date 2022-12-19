-- Active: 1671298760703@@0.0.0.0@5555@rk3@public
CREATE DATABASE rk3;

--------------------------------------------------------------
-- Задание 1
CREATE TABLE IF NOT EXISTS staff
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

-- Написать функцию, возвращающую количетво поздавщих сотрудников. Дата опоздания передается в качестве праметра.
CREATE OR REPLACE FUNCTION get_count_late_staff(date_late DATE)
RETURNS TABLE(count bigint)
AS $$
BEGIN
    RETURN QUERY
    Select count(*) from (Select idstaff from staff_track
                        where idstaff not in (SELECT idstaff from staff_track
                                            where time <= '8:30' and type = 1)
                        and type = 1 and date = date_late
                        group by idstaff) as tmp;

END            
$$ LANGUAGE PLPGSQL;

Select t.date, get_count_late_staff(t.date) as count_late from staff_track as t;

--------------------------------------------------------------
-- Задание 2

-------- Найти отделы, в которых хоть один сотрудник опаздывает больше 3-х раз в неделю ---------------

-------- Найти средний возраст сотрудников, ненаходящихся на рабочем месте 8 часов в день ---------------

-- Дату рождение к возрасту
Select id, fio, 
       date_part('year', current_date) - date_part('year', birthday) as age 
from staff;

SELECT * from staff_track;

-- Сотрудник, день, часов работы
with dtr(id, date, all_t, in_t, out_t) as (
    with tracking(idstaff, date, time_in, time_out, hours_work, type) as (
        -- Привести данные к виду тракинга времени нахождение сотрудника по дате
        Select s1.idstaff, s1.date, 
            s1.time as time_in, 
            s2.time as time_out, 
            (s2.time - s1.time)::time as hours_work,
            CASE
                WHEN s1.type = 1 and s2.type = 2 THEn 'in' -- в офиссе
                WHEN s1.type = 2 and s2.type = 1 THEn 'out' -- снаружи (вышел покурить, обед, или что-то другое)
            END as type 
        from staff_track as s1
        join staff_track s2 on s1.idstaff = s2.idstaff and s1.time < s2.time
            and (s1.type = 1 and s2.type = 2 or s1.type = 2 and s2.type = 1) 
            and s1.date = s2.date
    )
    SELECT
        t.idstaff as id, 
        t.date, 
        MAX(hours_work) as all_t, -- время между первым входом и последним выходом за день
        CASE 
            when s.in is NULL THEN MAX(hours_work) -- время проведения в офиссе
            ELSE s.in
        END as in_t,
        CASE 
            when s.in is NULL THEN '0:00'      -- время проведеннее снаружи
            ELSE (MAX(hours_work) - s.in)::time
        END as out_t
    FROM tracking as t
    left join (
        Select idstaff as id, date as dt, SUM(hours_work)::time as in from tracking
        where type = 'in' and hours_work != (Select MAX(hours_work) 
                                        from tracking)
        GROUP BY idstaff, date                         
    ) as s on s.id = t.idstaff and s.dt = t.date
    GROUP BY idstaff, date, s.in
)

Select AVG(age) from (
    Select id, fio, 
       date_part('year', current_date) - date_part('year', birthday) as age 
    from staff
) as st
where id in (
    Select s.id from dtr
    join staff as s on s.id = dtr.id 
    and dtr.in_t > dtr.out_t and dtr.in_t < '8:00');

-------- Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю учета -------------------
with dtl(id, date_late) as(
    -- ID Сотрудника и дата опоздания
    Select idstaff as id, 
           date as date_late 
    from staff_track as dtl
    where idstaff not in (select idstaff from staff_track
                        where date = dtl.date and time <= '9:00)')
    GROUP BY idstaff, date  
)
Select department, count(*) 
from
    -- Департамент,ID Сотрудника, ФИО, количество опозданий 
    (Select s.department, s.id, s.fio, count(*) as count_late 
    from dtl
    join staff as s on s.id = dtl.id
    GROUP BY s.department, s.id, s.fio) as dfl
GROUP BY department;