-- Active: 1669057481227@@127.0.0.1@5555@rk2@public

--- (1)
-- Создание базы RK2
CREATE DATABASE rk2;

-- Создание таблиц базы данных
CREATE TABlE IF NOT EXISTS departments(
    id INT PRIMARY KEY,
    name TEXT not null,
    phone TEXT not null,
    head INT
);

CREATE TABLE IF NOT EXISTS medications(
    id INT PRIMARY KEY,
    name TEXT not null,
    manual TEXT not null,
    price numeric
);

CREATE TABLE IF NOT EXISTS employees(
    id INT PRIMARY KEY,
    department INT,
    position TEXT not null,
    FIO TEXT not null,
    salary numeric,
    FOREIGN KEY(department) REFERENCES departments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS responsibilities(
    id INT PRIMARY KEY,
    employeeId INT,
    medicationId INT,
    FOREIGN KEY (medicationId) REFERENCES medications(id) ON DELETE CASCADE,
    FOREIGN KEY (employeeId) REFERENCES employees(id) ON DELETE CASCADE
);

-- Добавляем это ограничение после заполнение данными Сотрудников и Отдел
ALTER table departments
    ADD CONSTRAINT fk_head foreign key(head) references employees(id) ON DELETE SET NULL;

ALTER TABLE departments
   DROP CONSTRAINT fk_head;
-- Заполнение данными таблиц

-- Отдел
INSERT INTO departments VALUES(1, 'Departmant 1', '89990202888', 1),
                              (2, 'Departmant 2', '89990202889', 10),
                              (3, 'Departmant 3', '89990202879', 22),
                              (4, 'Departmant 4', '89990202869', 15),
                              (5, 'Departmant 5', '89990202859', 16),
                              (6, 'Departmant 6', '89990202849', 17),
                              (7, 'Departmant 7', '89990202839', 18),
                              (8, 'Departmant 8', '89990202829', 19),
                              (9, 'Departmant 9', '89990202819', 20),
                              (10, 'Departmant 10', '89990202809', 21);

-- Сотрудники

-- Отдел 1
INSERT INTO employees VALUES(1, 1, 'Заведующий', 'fio 1', 50000),
                            (2, 1, 'МедБрат', 'fio 2', 10000),
                            (3, 1, 'МедСестра', 'fio 3', 8000),
                            (4, 1, 'Терапевт', 'fio 4', 15000),
                            (5, 1, 'Интерн', 'fio 5', 5000),
                            (6, 1, 'Интерн', 'fio 6', 5000),
                            (7, 1, 'Санитар', 'fio 7', 15000),
                            (8, 1, 'Медсестра', 'fio 8', 15000),
                            (9, 1, 'Санитар', 'fio 9', 15000);

-- Отдел 2
INSERT INTO employees VALUES(10, 2, 'Заведующий', 'fio 10', 50000),
                            (11, 2, 'МедБрат', 'fio 11', 10000),
                            (12, 2, 'МедСестра', 'fio 12', 8000),
                            (13, 2, 'Терапевт', 'fio 13', 15000),
                            (14, 2, 'Интерн', 'fio 14', 5000);

-- Заведующие других отделов
INSERT INTO employees VALUES
                            (22, 3, 'Заведующий', 'fio 22', 450000),
                            (15, 4, 'Заведующий', 'fio 15', 50000),
                            (16, 5, 'Заведующий', 'fio 16', 150000),
                            (17, 6, 'Заведующий', 'fio 17', 350000),
                            (18, 7, 'Заведующий', 'fio 18', 250000),
                            (19, 8, 'Заведующий', 'fio 19', 50000),
                            (20, 9, 'Заведующий', 'fio 20', 150000),
                            (21, 10, 'Заведующий', 'fio 21', 50000);

-- Медикаменты
INSERT INTO medications VALUES(1, 'Medisions 1', 'manual', 50.9),
                              (2, 'Medisions 2', 'manual', 10.9),
                              (3, 'Medisions 3', 'manual', 150.9),
                              (4, 'Medisions 4', 'manual', 530.129),
                              (5, 'Medisions 5', 'manual', 5230.9),
                              (6, 'Medisions 6', 'manual', 510.9),
                              (7, 'Medisions 7', 'manual', 10.9),
                              (8, 'Medisions 8', 'manual', 30.9),
                              (9, 'Medisions 9', 'manual', 523.9),
                              (10, 'Medisions 10', 'manual', 53.9);

-- Отвественность

INSERT INTO responsibilities VALUES (1, 2, 1),
                                    (2, 1, 2),
                                    (3, 3, 10),
                                    (4, 21, 7),
                                    (5, 19, 9),
                                    (6, 19, 3),
                                    (7, 12, 4),
                                    (8, 8, 5),
                                    (9, 3, 3),
                                    (10, 6, 6);

-- (2)

-- Запрос Select с CASE
-- Вывести Медикамент и его отвественного, если нет отвественного, то написать "Отсутвует"
Select m.name,
       CASE 
            WHEN e.fio is NULL THEN 'Отсутвует'
            ELSE e.fio
        END     
from medications as m
left outer join responsibilities as r on m.id = r.medicationid
left outer join employees as e on e.id = r.employeeid;

-- Запрос используя оконные функции
-- Вывести максимальные зп по должностям
Select * from (
Select position,
       MAX(salary) OVER(PARTITION BY position) as max_salary
from employees) as dt
GROUP BY position, max_salary;

-- Запрос  Select с Group BY и Having
-- Вывести средную зарплату по должности если она больше общей средней зп
Select position, avg(salary)
from employees
GROUP BY position
HAVING avg(salary) > (Select avg(salary)
                      from employees);

-- (3) Создать хранимую процедуру с двумя входными параметрами
--     имя базы данных данных и имя таблицы, которая выводит сведения об индексах
--     указанной таблицу в указанной базе данных (скорее всего не база данных, а схема)
select * from pg_catalog.pg_tables;

DROP PROCEDURE get_index_table_in_schema;
CREATE or REPLACE PROCEDURE get_index_table_in_schema(schema TEXT, table_name TEXT)
AS $$
DECLARE 
    indexdata RECORD;
BEGIN
    for indexdata in 
        SELECT indexname, indexdef FROM pg_indexes as pg
        WHERE pg.tablename = table_name
        and pg.schemaname = schema
        LOOP
        raise notice 'Index name: %; indexdef: %',
                      indexdata.indexname, indexdata.indexdef;
    end loop;    
END;
$$ LANGUAGE PLPGSQL;

CALL get_index_table_in_schema('public', 'employees');