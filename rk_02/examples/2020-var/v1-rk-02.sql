-- Active: 1669057481227@@127.0.0.1@5555@rk2

--- (1) Создать базу данных RK2. Создать в ней структуру, 
-- соответствующую указанной на ER-диаграмме. 
-- Заполнить таблицы тестовыми значениями (не менее 10 в каждой таблице)
CREATE DATABASE rk2;

CREATE TABLE IF NOT EXISTS anymals(
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

CREATE TABLE IF NOT EXISTS owner_anymal(
    ownerId INT,
    anymalId INT,
    FOREIGN KEY(ownerId) REFERENCES owners(id) ON DELETE CASCADE,
    FOREIGN KEY(anymalId) REFERENCES anymals(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS diseases(
    id INT PRIMARY KEY,
    name TEXT NOT NULL,
    symptom TEXT,
    analiz TEXT
);

CREATE TABLE IF NOT EXISTS anymal_disease(
    anymalId INT,
    diseaseId INT,
    FOREIGN KEY(diseaseId) REFERENCES diseases(id) ON DELETE CASCADE,
    FOREIGN KEY(anymalId) REFERENCES anymals(id) ON DELETE CASCADE
);

-- Заполнение таблиц текущей базы данных

INSERT INTO anymals VALUES (1, 'cat', 'ordinary', 'barsik'),
                           (2, 'dog', 'buldog', 'lapa'),
                           (3, 'elephant', 'ordinary', 'vasya'),
                           (4, 'rabbit', 'mq', 'queue'),
                           (5, 'cat', 'scottish', 'persik'),
                           (6, 'snake', 'case', 'Petr'),
                           (7, 'beer', 'russian', 'glass'),
                           (8, 'fish', 'shuka', 'elena'),
                           (9, 'monkey', 'belarusian', 'potatos'),
                           (10, 'horse', 'hound', 'lika');

INSERT INTO diseases VALUES (1, 'AIDS', 'Кровотечение', 'жаропонижающие'),
                            (2, 'Allergy', 'Кровяное давление ', 'Анальгетики, болеутоляющие'),
                            (3, 'Angina', 'заложенность носа', 'Побочные эффекты'),
                            (4, 'Break', 'Жар, лихорадка', 'Антибиотики'),
                            (5, 'Bronchitis', 'Мочеиспускание', 'Антигистаминные средства'),
                            (6, 'Burn', 'Слабость', 'Антисептики'),
                            (7, 'Cancer', 'Сыпь, покраснение', 'Сердечные препараты'),
                            (8, 'Diabetes', 'Дефекация, «стул»', 'Противопоказания'),
                            (9, 'Dysentery', 'Диарея', 'Транквилизаторы'),
                            (10, 'Gastritis', 'Вздутый (живот)', 'Дозировка');

INSERT INTO owners VALUES (1, 'Носков Севастьян Германнович', 'Омская область, город Видное, проезд Ломоносова, 37', '+7 (993) 155-83-46'),
                        (2, 'Дмитриев Федор Рудольфович', 'Россия, г. Ессентуки, Новый пер., д. 12 кв.185', '+7 (940) 731-48-43'),
                        (3, 'Воронов Карл Эльдарович', 'Россия, г. Батайск, Комсомольская ул., д. 21 кв.192', '+7 (991) 832-32-47'),
                        (4, 'Калашников Терентий Александрович', 'Россия, г. Челябинск, Максима Горького ул., д. 1 кв.152',
                            '+7 (967) 366-23-74'),
                        (5, 'Шаров Оскар Русланович', 'Россия, г. Киров, Трудовая ул., д. 18 кв.179', '+7 (937) 357-14-81'),
                        (6, 'Щукина Наталья Михаиловна', 'Россия, г. Чебоксары, Центральная ул., д. 11 кв.45', '+7 (976) 110-70-78'),
                        (7, 'Пестова Каролина Владленовна', 'Россия, г. Армавир, Севернаяул., д. 9 кв.80', '+7 (980) 249-72-85'),
                        (8, 'Исаева Светлана Витальевна', 'Россия, г. Улан-Удэ, Железнодорожная ул., д. 20 кв.170', '+7 (912) 918-20-62'),
                        (9, 'Гордеева Александрина Иосифовна', 'Россия, г. Камышин, Красноармейская ул., д. 15 кв.23',
                            '+7 (912) 918-20-62'),
                        (10, 'Смирнова Лигия Якововна', 'Россия, г. Стерлитамак, Социалистическая ул., д. 11 кв.33', '+7 (919) 589-67-34');

insert into anymal_disease
values (1, 2),
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

insert into owner_anymal
values (8, 2),
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

--- (2)
-- Написать к разработанной базе данных 3 запроса, в комментарии указать, что
-- этот запрос делает:
-- 1) Инструкцию SELECT, использующую простое выражение CASE

-- Вывести список животных с пометкой - дворняга он или нет. Если порода -- ordinary, то есть он
-- беспородный, то в столбце true, иначе false. Сортируем по этому столбцу - сначала трушные, потом нет.
select type, 
       (case 
       when breed = 'ordinary' then true 
       else false 
       end) is_ord_anymal, nick
from anymals order by is_ord_anymal desc;

-- 2) Инструкцию, использующую оконную функцию
-- Вывод нумерации строк, если id был бы не с 1, 
-- то можно было бы делать некоторые вычисления
-- на основе номера реальных строк.

SELECT id,
       type,
       breed,
       row_number() over() as real_num
FROM anymals;       

-- 3) Инструкцию SELECT, консолидирующую данные с помощью
-- Вывести количество пород тех животных, которых в таблице больше 2.
SELECT breed, count(*) as count
FROM anymals
GROUP BY breed
having count(*) > 1;

-- (3) Создать хранимую процедуру с выходным параметром, которая уничтожает
-- все SQL DDL триггеры (триггеры типа 'TR') в текущей базе данных.
-- Выходной параметр возвращает количество уничтоженных триггеров.
-- Созданную хранимую процедуру протестировать.

DROP FUNCTION delete_all_ddl_triggers;

CREATE OR REPLACE FUNCTION delete_all_ddl_triggers()
RETURNS INT
AS $$
DECLARE
    tgName RECORD;
    tgTable RECORD;
    count INT;
BEGIN
    count = 0;
    for tgName in 
        Select distinct(trigger_name) from information_schema.triggers
        where trigger_schema = 'public'
    LOOP
       for tgTable in
            Select distinct(event_object_table) from information_schema.triggers
            where trigger_name = tgName.trigger_name 
        LOOP
           execute 'drop trigger ' || tgName.trigger_name || ' on ' || tgTable.event_object_table || ';';
           count = count + 1;
        END LOOP;
    END LOOP;
    return count;
END;
$$ LANGUAGE PLPGSQL;

SELECT delete_all_ddl_triggers();