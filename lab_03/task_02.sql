-- Подставляемая табличная функция

DROP FUNCTION tp.get_cgonpfc();

-- Вывести компании, который разрабатываю под укзанную платформу и вывести количество игр, разработанных на этой платформе

CREATE OR REPLACE FUNCTION tp.get_cgonpfc(platform text)
RETURNS TABLE (id int, name text, count bigint)
AS $$
BEGIN
    RETURN QUERY 
    Select c.id, c.name, count(c.id)
    from tp.companies as c
        join (
            Select g.id, g.name, g.developer, count(g.name) as cnt
            from tp.games as g
                join tp.supports as sp on sp.gameid = g.id
                join tp.platforms as pl on sp.platformid = pl.id and pl.name like platform
            group by g.id
            order by g.developer
        ) as gp on c.id = gp.developer
    group by c.id
    order by c.name;
END            
$$ LANGUAGE PLPGSQL;        

Select * from tp.get_cgonpfc('%Xbox%');

