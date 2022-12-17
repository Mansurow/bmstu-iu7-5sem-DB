-- Active: 1669129963113@@127.0.0.1@5555@rk2@public
-- Мансуров Владсилав Михайлович
-- Группа ИУ7-56б
-- Варинат 1

CREATE DATABASE rk2;

-- Задание 1


-- Создание таблиц
CREATE TABLE IF NOT EXISTS animals(
    id INT PRIMARY KEY,
    type TEXT NOT NULL,
    breed TEXT NOT NULL,
    nick TEXT
);

CREATE TABLE IF NOT EXISTS owners(
    id INT PRIMARY KEY,
    fio TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS owner_animals(
    ownerId INT,
    animalId INT,
    FOREIGN KEY(ownerId) REFERENCES owners(id) ON DELETE CASCADE,
    FOREIGN KEY(animalId) REFERENCES animals(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS diseases(
    id INT PRIMARY KEY,
    name TEXT NOT NULL,
    symptom TEXT,
    analiz TEXT
);

CREATE TABLE IF NOT EXISTS disease_animals(
    animalId INT,
    diseaseId INT,
    FOREIGN KEY(diseaseId) REFERENCES diseases(id) ON DELETE CASCADE,
    FOREIGN KEY(animalId) REFERENCES animals(id) ON DELETE CASCADE
);

-- Заполнение таблиц данными
-------- ANYMALS
-- Заполнение данными Животных
INSERT INTO animals VALUES (1, 'cat', 'ordinary', 'kotya'),
                           (2, 'dog', 'buldog', 'good'),
                           (3, 'dog', 'ordinary', 'vasya'),
                           (4, 'rabbit', 'mq', 'run'),
                           (5, 'dog', 'long', 'persik'),
                           (6, 'snake', 'case', 'Petr'),
                           (7, 'beer', 'russian', 'glass'),
                           (8, 'fish', 'shuka', 'elena'),
                           (9, 'cat-dog', 'catdog', 'COTAPES'),
                           (10, 'horse', 'hound', 'luka');

INSERT INTO animals VALUES(12, 'dog', 'baddog', 'bad');

-- Посмотреть что в animals
-- Select * from animals;

--- OWNERS
INSERT INTO owners VALUES (1, 'Строганов Дмитрий Владимирович', 'какой-то адреесс', '+7 (993) 155-83-46'),
                          (2, 'Гаврилова Юлия Михайловна', 'какой-то адреесс', '=7 982 122-31-12'),
                          (3, 'Воронов Карл Эльдарович', 'какой-то адреесс', '+7 (991) 832-32-47'),
                          (4, 'Калашников Терентий Александрович', 'какой-то адреесс','+7 (967) 366-23-74'),
                          (5, 'Шаров Оскар Русланович', 'какой-то адреесс', '+7 (937) 357-14-81'),
                          (6, 'Щукина Наталья Михаиловна', 'какой-то адреесс', '+7 (926) 111-70-78'),
                          (7, 'Пестова Каролина Владленовна','какой-то адреесс', '+7 (900) 249-72-85'),
                          (8, 'Исаева Светлана Витальевна', 'какой-то адреесс', '+7 (898) 918-20-62'),
                          (9, 'Строганов Юрий Владимирович', 'какой-то адреесс','+7 433 918-20-62'),
                          (10, 'Волкова Лилия Равилевна', 'какой-то адреесс', '+7 232 42-67-34');

INSERT INTO owners VALUES(11, 'Служба спасения', 'какой-то адреесс', '911');

-- Посмотреть что в owners
-- SELECT * FROM owners;

--- OWNER_ANIMALS

INSERT INTO owner_animals
VALUES (8, 2),
       (2, 3),
       (9, 4),
       (3, 1),
       (6, 5),
       (10, 9),
       (5, 3),
       (7, 6),
       (6, 9),
       (2, 1),
       (3, 6);

--- DISEASES

INSERT INTO diseases VALUES (1, 'Ранение', 'Кровотечение', 'Анализ 1'),
                            (2, 'Аллергия', 'Кровяное давление ', 'Анализ 2'),
                            (3, 'Ангина', 'заложенность носа', 'Анализ 3'),
                            (4, 'Перелом', 'Боль', 'Анализ 4'),
                            (5, 'Восполение легких', 'Кашель', 'Анализ 5'),
                            (6, 'Дабет', 'Слабость', 'Анализ 6'),
                            (7, 'Восполение', 'Зуд', 'Анализ 7'),
                            (8, 'Грипп', 'Кашель и температура', 'Анализ 8'),
                            (9, 'Неизвестная болезнь', 'Диарея', 'Анализ 9'),
                            (10, 'Гастрит', 'Вздутие', 'Анализ 10');

-- SELECT * FROM diseases;

-- DISEASE_ANYMALS

INSERT INTO disease_animals
VALUES (1, 2),
       (2, 4),
       (9, 4),
       (3, 7),
       (6, 5),
       (10, 9),
       (8, 3),
       (7, 1),
       (6, 9),
       (10, 1),
       (3, 6);
       
-- SELECT * FROM disease_animals;   

----------------------------------------------------------------------
-- Задание 2

-- 1) Инструкцию SELECT, использующую простое выражение CASE
-- Вывести список ник, порода и болна ли 
-- отсортировать по нику животного и убрать дублирование, если таково имеется
Select a.nick,
       a.type,
       CASE
         WHEN diseaseid is NULL THEN False
         ELSE TRUE
       END as is_disease
from animals as a
left outer join disease_animals as da 
           on a.id = da.animalid
group by nick, type, is_disease
order by a.nick;

-- 2) Инструкцию, использующую оконную функцию

-- Вывод нумерации по типу животных, отсортировать по типу

SELECT id,
       type,
       breed,
       row_number() over(PARTITION BY type) as real_num
FROM animals
order by type;   

-- 3) Инструкцию SELECT, консолидирующую данные с помощью GROUP BY and HAVING
-- Вывести количество пород тех животных, которых в строке атрибута породы есть подстрока 'a'
SELECT breed, count(*) as count
FROM animals
GROUP BY breed
having breed like '%a%';

----------------------------------------------------------------------
-- Задание 3

-- Создание триггеров для тестирования

CREATE OR REPLACE FUNCTION insert_test()
RETURNS TRIGGER
AS $$
BEGIN
    RAISE NOTICE 'Information has been added in table';
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

-- AFTER
CREATE TRIGGER insert_test_trigger 
AFTER INSERT ON animals
FOR EACH ROW
EXECUTE FUNCTION insert_test();
-- BEFORE
CREATE TRIGGER insert_test_trigge_b 
BEFORE INSERT ON animals
FOR EACH ROW
EXECUTE FUNCTION insert_test();

-- SELECT * FROM information_schema.triggers  WHERE trigger_schema = 'public';

-- Процедура ...
DROP PROCEDURE delete_ddl_trigger(count INOUT int);
CREATE OR REPLACE PROCEDURE delete_ddl_trigger(count INOUT int)  
AS $$
DECLARE
    tgName RECORD;
BEGIN
    count = 0;
    FOR tgName IN 
        SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE 
        trigger_schema = 'public' and 
    LOOP
        EXECUTE 'DROP TRIGGER ' || tgName.trigger_name || ' ON ' || tgName.event_object_table;
        count = count + 1;
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;

-- Функция вызывающая процедуру с выходным параметром  delete_ddl_trigger(count INOUT int)
CREATE FUNCTION call_procedure()
RETURNS int AS $$
DECLARE 
    count_ddl_del INT;
BEGIN
    CALL delete_ddl_trigger(count_ddl_del);
    RETURN count_ddl_del;
END;
$$ LANGUAGE plpgsql;

SELECT * from call_procedure();