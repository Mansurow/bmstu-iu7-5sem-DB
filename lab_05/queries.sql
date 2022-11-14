-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON.

-- Запись в json файл данных в виде массива данных
COPY (Select array_to_json(array_agg(row_to_json(g))) from tp.games g) 
to '/var/lib/postgresql/data/games.json';

COPY (Select array_to_json(array_agg(row_to_json(c))) from tp.companies c) 
to '/var/lib/postgresql/data/companies.json';
COPY (Select array_to_json(array_agg(row_to_json(tc))) from tp.typies_company tc)
to '/var/lib/postgresql/data/typies_company.json';

COPY (Select array_to_json(array_agg(row_to_json(c))) from tp.clients c) 
to '/var/lib/postgresql/data/clients.json';
COPY (Select array_to_json(array_agg(row_to_json(s))) from tp.sales s) 
to '/var/lib/postgresql/data/sales.json';

COPY (Select array_to_json(array_agg(row_to_json(g))) from tp.genres g) 
to '/var/lib/postgresql/data/genres.json';
COPY (Select array_to_json(array_agg(row_to_json(c))) from tp.categories c) 
to '/var/lib/postgresql/data/categories.json';

COPY (Select array_to_json(array_agg(row_to_json(p))) from tp.platforms p) 
to '/var/lib/postgresql/data/platforms.json';
COPY (Select array_to_json(array_agg(row_to_json(s))) from tp.supports s) 
to '/var/lib/postgresql/data/supports.json';

-- Построчный вывод кортежей данных таблиц
Select row_to_json(g) from tp.games g;

Select row_to_json(c) from tp.companies c;
Select row_to_json(tc) from tp.typies_company tc;

Select row_to_json(c) from tp.clients c;
Select row_to_json(s) from tp.sales s;

Select row_to_json(g) from tp.genres g;
Select row_to_json(c) from tp.categories c;

Select row_to_json(p) from tp.platforms p;
Select row_to_json(s) from tp.supports s;

-- 2. Выполнить загрузку и сохранение JSON файла в таблицу. 
-- Созданная таблица после всех манипуляций должна 
-- соответствовать таблице базы данных, созданной 
-- в первой лабораторной работе. 

-- Разделение массива структур данных json
-- cat games.json | jq -cr '.[]' | sed 's/\\[tn]//g' > games_output.json
-- 1) cat games.json - read the contents of the file
-- 2) | jq -cr '.[]' - pipe JSON into jq and split it onto every line
-- 3) | sed 's/\\[tn]//g' - [optional] remove tabs, newlines etc
-- 4) > games_output.json - output to a new file

DROP TABLE IF EXISTS tp.games_json;
CREATE TABLE IF NOT EXISTS tp.games_json (
    id int PRIMARY KEY,
    name text NOT NULL,
    type text NOT NULL,
    developer int,
    publisher int,
    req_age int,
    date_publish date,
    number_copies int,
    price numeric,
    CONSTRAINT positive_price CHECK(price >= 0),
    CONSTRAINT positive_copies CHECK(number_copies >= 0)
);

DROP TABLE IF EXISTS tp.json_table;
CREATE TABLE IF NOT EXISTS tp.json_table
(
    data JSONB
);

COPY tp.json_table(data) from '/var/lib/postgresql/data/games_output.json';

Select * from tp.json_table;

INSERT INTO tp.games_json
Select
    (data->>'id')::INT,
    data->>'name',
    data->>'type',
    (data->>'developer')::INT,
    (data->>'publisher')::INT,
    (data->>'req_age')::INT,
    (data->>'date_publish')::DATE,
    (data->>'number_copies')::INT,
    (data->>'price')::NUMERIC
from tp.json_table;

Select * from tp.games_json;

-- 3. Создать таблицу, в которой будет атрибут(ы) с типом JSON. 
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT/UPDATE.

DROP TABLE IF EXISTS tp.games_json_atr;
CREATE TABLE IF NOT EXISTS tp.games_json_atr
(
    id int PRIMARY KEY,
    name text NOT NULL,
    personal_data JSONB
);

INSERT INTO tp.games_json_atr VALUES
(1, 'Half-Life', '{"developer" : 378, "prices" : {"price" : 299.0, "copies" : 231241}}'),
(2, 'Half-Life Demo', '{"developer" : 378, "prices" : {"price" : 0.0, "copies" : 3}}');

UPDATE tp.games_json_atr
SET personal_data = '{"developer" : 378, "prices" : {"price" : 299.0, "copies" : 231241}}';

Select * from tp.games_json_atr;

-- 4. Выполнить следующие действия:

-- 1) Извлечь JSON фрагмент из JSON документа.

SELECT 
       name as game,
       personal_data->>'developer' AS devid,
       personal_data->'prices' AS data_about_price
FROM tp.games_json_atr;

-- 2) Извлечь значения конкретных узлов или атрибутов JSON документа.

SELECT 
       name as game,
       personal_data->>'developer' AS devid,
       personal_data->'prices'->>'price' AS price
FROM tp.games_json_atr;

-- 3) Выполнить проверку существования узла или атрибута

INSERT INTO tp.games_json_atr VALUES
(3, 'Portal', NULL),
(4, 'ARKS', '{"developer" : 378, "prices" : "NULL"}');

SELECT *
FROM tp.games_json_atr
where personal_data IS NOT NULL;


SELECT *
FROM tp.games_json_atr
where personal_data IS NOT NULL and personal_data->>'prices' != 'NULL';
-- 4) Изменить JSON документ

UPDATE tp.games_json_atr
SET personal_data = '{"developer" : 378, "prices": {"price" : 588, "copies" : 700}}' 
where personal_data is null;

-- 5) Разделить JSON документ на несколько строк по узлам
-- jsonb_array_elements - Разворачивает массив JSON в набор значений JSON.
DROP TABLE IF EXISTS tp.json_table;
CREATE TABLE IF NOT EXISTS tp.json_table
(
    data JSONB
);

COPY tp.json_table(data) from '/var/lib/postgresql/data/games.json';

SELECT jsonb_array_elements(data)
FROM tp.json_table;


-- Защита 
-- Записать данные в json Разработчик и кол-во игр

COPY (Select array_to_json(array_agg(row_to_json(ccg))) 
from (Select c.name as company, 
      count(c.id) as count_game
      from tp.companies as c
      join tp.games as g on g.developer = c.id
      group by c.id
      order by c.name
) ccg) 
to '/var/lib/postgresql/data/ccg.json';

COPY tp.json_table(data) from '/var/lib/postgresql/data/ccg.json';
Select d->>'company' as company, 
       (d->>'count_games')::INT as count_games
    from 
    (SELECT jsonb_array_elements(data) as d
    FROM tp.json_table) g;
