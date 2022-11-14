-- DML триггеры.
-- Триггер AFTER.

-- Триггерная функция
CREATE OR REPLACE FUNCTION tp.insert_info_games()
RETURNS TRIGGER
AS $$
BEGIN
    RAISE NOTICE 'Information has been added in table tp.games';
    RAISE NOTICE 'id = %, name = %',
                 new.id, new.name;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

-- Удаление триггера
DROP TRIGGER IF EXISTS insert_info_games_trigger on tp.games;

-- Создание триггера
CREATE TRIGGER insert_info_games_trigger 
AFTER INSERT ON tp.games
FOR EACH ROW
EXECUTE FUNCTION tp.insert_info_games();

-- Вставка, после которой вызывается триггер
Insert into tp.games
values (1005, 'ARK Survival Evolved', 'game', 1023, 400, 14, '2005-01-10', 43131, 499.00);

SELECT * FROM tp.games WHERE id = 1005;

DELETE FROM tp.games where id = 1005;

-- Триггер INSTEAD OF.

-- Добавление игры без существующей клмпании и 
-- дата выпуска игры должна быть после даты создания компании

-- Создание view для tp.games
DROP VIEW IF EXISTS tp.games_view;
CREATE VIEW tp.games_view
AS SELECT * FROM tp.games;

SELECT * from tp.games_view;

-- Триггер фунция для триггера INSTED OF
CREATE OR REPLACE FUNCTION tp.insert_games_date_limit()
RETURNS TRIGGER
AS $$ 
BEGIN
    IF new.developer is null THEN
        RAISE EXCEPTION 'The game developer is not specified, null is passed!';
        RETURN NULL;
    ELSIF new.publisher is null THEN
        RAISE EXCEPTION 'The game publisher is not specified, null is passed!';
        RETURN NULL;
    ELSIF date_part('year', new.date_publish)::integer < (Select c.year_creation
                          FROM tp.companies as c where new.developer = c.id) THEN
        RAISE EXCEPTION 'The release date of the game cannot be less than the date of the creation of the company %d!',
            (Select c.name FROM tp.companies as c where new.developer = c.id);
        RETURN NULL;
    ELSE
        RAISE INFO 'Success!';
        INSERT INTO tp.games VALUES(
            new.id,
            new.name,
            new.type,
            new.developer,
            new.publisher,
            new.req_age,
            new.date_publish,
            new.number_copies,
            new.price
        );
        RETURN NEW;
    END IF;    
END;
$$ LANGUAGE PLPGSQL

-- Удаление триггера 
DROP TRIGGER IF EXISTS insert_games_date_limit ON tp.games_view;
-- Создания триггера по условию -- INSTEAD OF
CREATE OR REPLACE TRIGGER insert_games_date_limit
INSTEAD OF INSERT ON tp.games_view
FOR ROW
EXECUTE FUNCTION tp.insert_games_date_limit();

-- Вставка данных. Вызывается триггер insert_games_date_limit
Insert into tp.games_view
values (1005, 'ARK Survival Evolved', 'game', 1023, 400, 14, '2020-01-10', 43131, 499.00);

Insert into tp.games_view
values (1005, 'ARK Survival Evolved', 'game', null, 400, 14, '2020-01-10', 43131, 499.00);

Insert into tp.games_view
values (1005, 'ARK Survival Evolved', 'game', 400, null, 14, '2020-01-10', 43131, 499.00);

-- Посмотреть данные компании нужнего id
Select c.year_creation FROM tp.companies as c where c.id = 1023;
-- Достать данные
SELECT * FROM tp.games WHERE id = 1005;
-- Удаление данных 
DELETE FROM tp.games where id = 1005;