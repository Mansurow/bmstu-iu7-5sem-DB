-- Для работы PLPYTHON3U лучше сипользовать POSTGRESQL 13 и Python 3.7
-- DOKER container вбить комманду 
-- apt-get update && apt-get install postgresql-plpython3-13

-- Создать, развернуть и протестировать 6 объектов SQL CLR

-- 1. Определяемую пользователем скалярную функцию CLR

-- Создание языка с PLPYTHON3U

CREATE EXTENSION PLPYTHON3U;

-- Возврат число, которое заработало компания за выпущенную игру
CREATE OR REPLACE FUNCTION tp.get_active_py(price NUMERIC, copies INTEGER) 
RETURNS NUMERIC 
AS $$
    return price * copies
$$ LANGUAGE PLPYTHON3U;


SELECT name,
	tp.get_active_py(price, number_copies) AS active
FROM tp.games;

-- 2. Пользовательскую агрегатную функцию CLR

-- Возвращает количетво игр, у которых бюджет достиг 100000
CREATE OR REPLACE FUNCTION tp.get_number_actives_py(active bigint) 
RETURNS NUMERIC 
AS $$
    query = '''
        Select tp.get_active_py(price, number_copies) as active
        from tp.games
        '''
    res = plpy.execute(query)
    if res is not None:
        count = 0
        for el in res:
            if el["active"] >= active:
               count += 1
        return count
    return 0
$$ LANGUAGE PLPYTHON3U;

SELECT
	tp.get_number_actives_py(10000000) AS cnt_active;

-- 3. Определяемую пользователем табличную функцию CLR

-- Вывести компании, который разрабатываю под укзанную платформу и вывести количество игр, разработанных на этой платформе
CREATE OR REPLACE FUNCTION tp.get_cgonpfc_py(platform text)
RETURNS TABLE (id int, name text, count bigint)
AS $$
    query = '''
    Select c.id, c.name, count(c.id)
    from tp.companies as c
        join (
            Select g.id, g.name, g.developer, count(g.name) as cnt
            from tp.games as g
                join tp.supports as sp on sp.gameid = g.id
                join tp.platforms as pl on sp.platformid = pl.id and pl.name like '%s'
            group by g.id
            order by g.developer
        ) as gp on c.id = gp.developer
    group by c.id
    order by c.name;
    ''' %(platform)
    res = plpy.execute(query)
    return res;
$$ LANGUAGE PLPYTHON3U;

Select * from tp.get_cgonpfc_py('%Xbox%');

-- 4. Хранимую процедуру CLR

-- Повышение цен на указанный процент от стоимости игр и id игры
CREATE OR REPLACE PROCEDURE tp.price_up_py(game int, percent int)
AS $$
    update_inst = plpy.prepare("UPDATE tp.games SET price = price + (price / 100 * $2) where id = $1;",
                               ["INT", "INT"])
    plpy.execute(update_inst, [game, percent])
$$ LANGUAGE PLPYTHON3U;

Select * from tp.games where id = 2;

CALL tp.price_up_py(2, 100);

-- 5. Триггер CLR

CREATE OR REPLACE FUNCTION tp.insert_info_games_py()
RETURNS TRIGGER
AS $$
    plpy.notice("Information has been added in table tp.games");
    plpy.notice(f"id = {TD['new']['id']}, name = {TD['new']['name']}");
$$ LANGUAGE PLPYTHON3U;

-- Удаление триггера
DROP TRIGGER IF EXISTS insert_info_games_trigger_py on tp.games;

CREATE TRIGGER insert_info_games_trigger_py 
AFTER INSERT ON tp.games
FOR ROW EXECUTE FUNCTION tp.insert_info_games_py();

-- Вставка, после которой вызывается триггер
Insert into tp.games
values (1005, 'ARK Survival Evolved', 'game', 1023, 400, 14, '2005-01-10', 43131, 499.00);

SELECT * FROM tp.games WHERE id = 1005;

DELETE FROM tp.games where id = 1005;


-- Триггер instead of CLR 
CREATE OR REPLACE FUNCTION tp.insert_games_date_limit_py()
RETURNS TRIGGER
AS $$ 
if TD['new']['developer'] is None:
    plpy.notice("The game developer is not specified, null is passed!")
    return None
elif TD['new']['publisher'] is None:
    plpy.notice("The game publisher is not specified, null is passed!");
    return None
plpy.notice("Success!")
plpy.notice(f"{TD['new']}")
inst = plpy.prepare("INSERT INTO tp.games VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9)", 
        ["INT", "TEXT", "TEXT", "INT", "INT", "INT", "DATE", "INT", "NUMERIC"])
plpy.execute(inst, [TD['new']['id'],
                    TD['new']['name'],
                    TD['new']['type'],
                    TD['new']['developer'],
                    TD['new']['publisher'],
                    TD['new']['req_age'],
                    TD['new']['date_publish'],
                    TD['new']['number_copies'],
                    TD['new']['price']])     
$$ LANGUAGE PLPYTHON3U
                    
-- Удаление триггера 
DROP TRIGGER IF EXISTS insert_games_date_limit ON tp.games_view;
-- Создания триггера по условию -- INSTEAD OF
CREATE TRIGGER insert_games_date_limit
INSTEAD OF INSERT ON tp.games_view
FOR ROW
EXECUTE FUNCTION tp.insert_games_date_limit_py(); 

DELETE from tp.games where id > 1004;

Insert into tp.games_view
values (1005, 'ARK Survival Evolved', 'game', 1023, 400, 14, '2020-01-10', 43131, 499.00);

Insert into tp.games_view
values (1005, 'ARK Survival Evolved', 'game', null, 400, 14, '2020-01-10', 43131, 499.00);

Insert into tp.games_view
values (1005, 'ARK Survival Evolved', 'game', 400, null, 14, '2020-01-10', 43131, 499.00);

-- 6. Определяемый пользователем тип данных CLR

DROP TYPE IF EXISTS tp.company_game;
CREATE TYPE tp.company_game as
(
    company text,
    count_game bigint
);

DROP FUNCTION tp.get_inf_about_company_game_py();

CREATE OR REPLACE FUNCTION tp.get_inf_about_company_game_py()
RETURNS SETOF tp.company_game
AS $$
   query = '''
    Select 
        c.name as company, 
        count(c.id) as count_game
    from tp.companies as c
    join tp.games as gp on c.id = gp.developer
    group by c.id
    order by c.name;     
   '''
   
   res = plpy.execute(query)

   if res is not None:
       return res   
$$ LANGUAGE PLPYTHON3U;

SELECT * FROM tp.get_inf_about_company_game_py();