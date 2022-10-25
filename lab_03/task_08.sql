-- Хранимые процедуры.
-- Хранимая процедура доступа к метаданным.

-- Получить название столбцов (атрибуты) и их типы.

-- Cоздание процедуры доступа к метадданым
CREATE OR REPLACE PROCEDURE tp.get_metadata(my_table text)
AS $$
DECLARE
    data RECORD;
    cur_data cursor FOR
        SELECT *
        FROM information_schema.columns
        WHERE table_name = my_table;
BEGIN
    OPEN cur_data;
    LOOP
        FETCH cur_data INTO data;
        
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%, %', 
            data.column_name, data.data_type;

    END LOOP;
    CLOSE cur_data;
END;
$$ LANGUAGE PLPGSQL;

-- Вызов процедуры
CALL tp.get_metadata('companies');
