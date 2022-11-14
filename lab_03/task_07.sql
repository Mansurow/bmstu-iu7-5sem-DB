-- Хранимые процедуры.
-- Хранимая процедура с курсором.

-- Вывести игру, разработчика, издателя, год выпуска за определнный год, отсортированный по дате

-- Создание процедуры
CREATE OR REPLACE PROCEDURE tp.get_games_by_year(year int)
AS $$
DECLARE 
    game RECORD;
    cur_table CURSOR FOR
        Select g.name, cd.name as dev, cp.name as pub, g.date_publish
        from tp.games as g
        join tp.companies as cd on cd.id = g.developer
        join tp.companies as cp on cp.id = g.publisher
        where date_part('year', g.date_publish)::integer = year
        order by g.date_publish;
BEGIN
    OPEN cur_table;
    LOOP
        FETCH cur_table INTO game;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'game = %, developer = %, publisher = %, publish date = %',
                     game.name, game.dev, game.pub, game.date_publish;
                     
    END LOOP;
    CLOSE cur_table;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE tp.get_games_by_year_wc(year int)
AS $$
BEGIN
    DROP TABLE if exists game;
    
    CREATE temp table if not exists game
    (
        name text,
        dev text,
        pub text,
        date_publish date
    );
    
    Insert into game(name, dev, pub, date_publish) 
    Select g.name, cd.name as dev, cp.name as pub, g.date_publish
        from tp.games as g
        join tp.companies as cd on cd.id = g.developer
        join tp.companies as cp on cp.id = g.publisher
        where date_part('year', g.date_publish)::integer = year
        order by g.date_publish;

END;
$$ LANGUAGE PLPGSQL;

-- Вызов процедуры
CALL tp.get_games_by_year(1999);
CALL tp.get_games_by_year_wc(1999);
Select * from game;