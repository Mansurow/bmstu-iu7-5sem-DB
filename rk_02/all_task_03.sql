-- Условия все здесь: 
-- https://studopedia.su/16_78780_bazi-dannih-zadachi-na-moduli-SQL.html

-------------------------------------------------------------------------------
-- 1.  Создать хранимую процедуру с двумя входными параметрами
--     имя базы данных данных и имя таблицы, которая выводит сведения об индексах
--     указанной таблицу в указанной базе данных (скорее всего не база данных, а схема)

-- Если мало информации об индексах
SELECT *
        -- В каталоге pg_index содержится часть информации об индексах.
        -- Остальная информация в основном находится в pg_class.
        FROM pg_index
        --  В каталоге pg_class описываются таблицы и практически всё,
        --  что имеет столбцы или каким-то образом подобно таблице.
        --  Сюда входят индексы.
        JOIN pg_class ON pg_index.indrelid = pg_class.oid
        WHERE relname = 'employees';

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

-- Используя курсор

CREATE OR REPLACE PROCEDURE get_index_table_in_schema_cur(schema TEXT, table_name TEXT)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT pind.indexname, pind.indexdef FROM pg_indexes pind 
        WHERE pind.schemaname = schema AND pind.tablename = table_name
        ORDER BY pind.indexname;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'TABLE: %, INDEX: %s, DEFINITION: %', table_name, rec.indexname, rec.indexdef;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE PLPGSQL;

CALL get_index_table_in_schema_cur('public', 'employees');

-------------------------------------------------------------------------------
-- 2. Создать хранимую процедуру с выходным параметром, которая уничтожает
-- все SQL DDL триггеры (триггеры типа 'TR') в текущей базе данных.
-- Выходной параметр возвращает количество уничтоженных триггеров.
-- Созданную хранимую процедуру протестировать.

-- Создание тестируемого триггеров

CREATE OR REPLACE FUNCTION insert_test()
RETURNS TRIGGER
AS $$
BEGIN
    RAISE NOTICE 'Information has been added in table';
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER insert_test_trigger 
AFTER INSERT ON anymals
FOR EACH ROW
EXECUTE FUNCTION insert_test();

-- Информация о триггерах
Select * from information_schema.triggers;

DELETE PROCEDURE delete_all_ddl_triggers;

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

Select delete_all_ddl_triggers();

-------------------------------------------------------------------------------
--- 3. Создать хранимую процедуру без параметров, в которой для экземпляра 
-- SQL Server создаются резервные копии всех пользовательских баз данных. 
-- Имя файла резервной копии должно состоять из имени базы данных и даты 
-- создания резервной копии, разделенных символом нижнего подчеркивания. 
-- Дата создания резервной копии должна быть представлена в формате YYYYDDMM. 
-- Созданную хранимую процедуру протестировать.


-------------------------------------------------------------------------------
--- 4. Создать хранимую процедуру, которая, не уничтожая базу данных, 
-- уничтожает все те таблицы текущей базы данных в схеме 'dbo', имена 
-- которых начинаются с фразы 'TableName'. Созданную хранимую процедуру 
-- протестировать.

-- Метаданные таблицы
SELECT * FROM pg_catalog.pg_tables pcat
WHERE pcat.schemaname = 'public' AND pcat.tablename LIKE 'a%'

CREATE OR REPLACE PROCEDURE delete_table_by_startstr(schema TEXT, startstr TEXT)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT pcat.tablename FROM pg_catalog.pg_tables pcat
        WHERE pcat.schemaname = schema AND pcat.tablename LIKE startstr || '%';
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        EXECUTE 'DROP TABLE ' || rec.tablename || ';';
        RAISE NOTICE 'DROP TABLE called << % >> from SCHEMA << % >>',
            rec.tablename, schema;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE PLPGSQL;

CALL delete_table_by_startstr('public', 'res');

-------------------------------------------------------------------------------
--- 5.
-- Создать хранимую процедуру с входным параметром, которая выводит имена и 
-- описания типа объектов  (только хранимых процедур и скалярных функций), 
-- в тексте которых на языке SQL встречается строка, задаваемая параметром 
-- процедуры. Созданную хранимую процедуру протестировать.

-- Вся информация про метаданные 
-- https://www.postgresql.org/docs/current/catalogs.html

-- Выводи все функции в базе данных и системные
SELECT proc.proname, 
       type.typname  
from pg_catalog.pg_proc proc
join pg_catalog.pg_type type 
     on proc.prorettype = type.oid
where proname like '%delete%';

-- Вывод пользовательсик фунции
SELECT
    *
FROM
    information_schema.routines 
WHERE
    specific_schema LIKE 'public';

DROP PROCEDURE get_proc_info;
CREATE OR REPLACE PROCEDURE get_proc_info(substr TEXT)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
    SELECT
        routine_name as name,
        routine_type as type,
        CASE 
            WHEN data_type is NULL THEN False
            ELSE True
        END as is_tg_function    
    FROM
        information_schema.routines 
    WHERE
        specific_schema LIKE 'public';
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        IF (not rec.is_tg_function) THEN
            RAISE NOTICE 'NAME_OBJECT: %; TYPE_OBJECT: % END...',
                    rec.name, rec.type;
        END IF;            
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE PLPGSQL;         

CALL get_proc_info('get');

-------------------------------------------------------------------------------
--- 6.
--- Создать хранимую процедуру с входным параметром – имя таблицы, которая удаляет 
--- дубликаты записей из указанной таблицы в текущей базе данных. 
--- Созданную хранимую процедуру протестировать.