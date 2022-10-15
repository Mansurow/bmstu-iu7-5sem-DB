CREATE SCHEMA lab_02_extra

CREATE TABLE IF NOT EXISTS lab_02_extra.table1(
    id int,
    var1 text,
    valid_from_dttm date default '5999-12-31',
    valid_to_dttm date default '5999-12-31'
);

CREATE TABLE IF NOT EXISTS lab_02_extra.table2(
    id int,
    var2 text,
    valid_from_dttm date default '5999-12-31',
    valid_to_dttm date default '5999-12-31'
);

insert into lab_02_extra.table1 values(1, 'A', '2018-09-01', '2018-09-15');
insert into lab_02_extra.table1 values(1, 'B', '2018-09-16', default);
insert into lab_02_extra.table1 values(2, 'С', '2018-09-01', '2018-09-13');
insert into lab_02_extra.table1 values(2, 'В', '2018-09-16', default);
insert into lab_02_extra.table1 values(3, 'T', '2018-09-10', '2018-09-30');
insert into lab_02_extra.table1 values(4, 'Y', '2018-09-16', '2018-10-01');

insert into lab_02_extra.table2 values(1, 'A', '2018-09-01', '2018-09-18');
insert into lab_02_extra.table2 values(1, 'B', '2018-09-19', default);
insert into lab_02_extra.table2 values(2, 'E', '2018-09-01', '2018-09-23');
insert into lab_02_extra.table2 values(2, 'F', '2018-09-24', default);
insert into lab_02_extra.table2 values(3, 'L', '2018-09-23', '2018-09-30');
insert into lab_02_extra.table2 values(3, 'L', '2018-10-01', default);
insert into lab_02_extra.table2 values(4, 'U', '2018-09-30', default);

SELECT id, var1, var2, valid_from_dttm, valid_to_dttm
FROM (
    SELECT t1.id, t1.var1, t2.var2,
		GREATEST(t1.valid_from_dttm, t2.valid_from_dttm) AS valid_from_dttm,
		LEAST(t1.valid_to_dttm, t2.valid_to_dttm) AS valid_to_dttm
--         CASE 
--             WHEN t1.valid_from_dttm > t2.valid_from_dttm THEN t1.valid_from_dttm
--             WHEN t2.valid_from_dttm > t1.valid_from_dttm THEN t2.valid_from_dttm
--             ELSE t1.valid_from_dttm
--         END valid_from_dttm,
--         CASE 
--             WHEN t1.valid_to_dttm < t2.valid_to_dttm THEN t1.valid_to_dttm
--             WHEN t2.valid_to_dttm < t1.valid_to_dttm THEN t2.valid_to_dttm
--             ELSE t1.valid_to_dttm
--         END valid_to_dttm
    FROM 
		lab_02_extra.table1 AS t1 JOIN 
		lab_02_extra.table2 AS t2 ON t1.id = t2.id
) as dttm
WHERE valid_from_dttm <= valid_to_dttm
group by id, var1, var2, valid_from_dttm, valid_to_dttm
ORDER BY id, valid_from_dttm;
