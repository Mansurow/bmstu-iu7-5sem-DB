-- Многооператорная табличная функция

-- Вывести клиентов у которых игр больше указаного количества 

CREATE OR REPLACE FUNCTION tp.get_clients(count_games int)
RETURNS TABLE (id int, nick text, count bigint)
AS $$
BEGIN

    Drop table if exists result;
    
    Create temp table if not exists result (id int, nick text, count bigint);

    Insert into result(id, nick, count)
    Select *
    from (SELECT c.id, c.nick, count(*) as cnt
    FROM tp.clients as c
        join tp.sales as s on c.id = s.clientid     
    group by c.id, c.name) as tmp
    where tmp.cnt >= 500;
    
    RETURN QUERY
    SELECT *
    FROM Result
    order by nick;
END            
$$ LANGUAGE PLPGSQL;


Select * from result;

Select * from tp.get_clients(500);
