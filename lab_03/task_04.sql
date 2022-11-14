-- Рекурсивная функция или функцию с рекурсивным ОТВ

Drop table companies;

Create table if not exists companies
(
    id int,
    name text,
    parentid int
);

Insert into companies values(1, 'LTD C0.', null),
                        (2, 'LTD co. and ...', 1),
                        (3, 'LTD co. and ... and', 2);

Select * from companies;

CREATE OR REPLACE FUNCTION recursive()
RETURNS TABLE (id int, name text, parentid int, level int)
AS $$
BEGIN
    RETURN QUERY
    WITH recursive parents(id, name, parentid, level) as 
    (
        Select c.id, c.name, c.parentid, 0 as level
        from companies as c
        where c.parentid is null

        UNION

        Select c.id, c.name, c.parentid, p.level + 1
        from companies as c
        join parents as p
        on p.id = c.parentid
    )
    Select * from parents;
END;    
$$ LANGUAGE PLPGSQL;

Select * from recursive();
