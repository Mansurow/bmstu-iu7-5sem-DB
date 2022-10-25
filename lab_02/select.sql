-- Active: 1666620714975@@127.0.0.1@5555@lab_01@tp
Select * from tp.games 
--1.Запрос с предикатом сравнения
--Вывести игры, где копии более 1000000, объединяя при этом таблицы игры и компании, сортируя по имени 
select G1.name,
       G1.type,
       C1.name as developer, 
       G1.price,
       G1.date_publish,
       G1.number_copies
from tp.games G1 
join tp.companies as C1 
on G1.developer = C1.id 
where G1.number_copies > 1000000
order by G1.name, developer;

--2 Запрос с предикатом between
--Вывести игры разработанные между датами...
Select name,
       date_publish
from tp.games
where date_publish between '01-01-2015' and '2020-01-01'
order by date_publish;

--3 Запрос с предикатом Like
-- Получить список ники клиентов в описании которых присутствует слово 'and', обладающие игрой с id = 2
Select clients.nick, games.name 
from tp.games, tp.clients
where clients.nick like '%and%' and 
games.id = 2;

--4 Запрос с предикатом in c вложенным подзапросом
--Получить список игр, разработанных компаниями из Японии, купленных клиентов 3
Select name, developer, clientId
from tp.games
join tp.sales on id = gameId and clientid = 3
where developer in (
    select id
    from tp.companies
    where country = 'Япония'
);

--5 Запрос с предикатом EXISTS с вложенным подзапросом
--Вывести списко игр, которые поддерживают платформу 1
Select id, name
from tp.games gms 
where EXISTS(
    Select gms.id, spr.gameid
    from tp.games
    join tp.supports as spr
    on gms.id = spr.gameid 
    and spr.platformid = 1
);

--6 Запрос, использующая предикат сравнения с квантором ALL, SOME, ANY
--Получить список компаний, где количество сотрудников больше, чем у 5-го компаний
Select name, country, type
from tp.companies
where number_employees > ALL(
      Select number_employees
      from tp.companies
      where type = 5
);

--Получить список игр после 2002, где количество копий равно любой из игр выпушенного до 2002 года
Select name, date_publish, number_copies
from tp.games
where number_copies = ANY(
    Select number_copies 
    from tp.games
    where date_publish < '2002-01-01' 
) and date_publish >= '2002-01-01';

--7 Запрос, использующая агрегатные функции в выражениях столбцов
Select 
    AVG(ALL number_copies) as Actual_AVG_copies,          -- AVG() средне-ариф.
    AVG(DISTINCT number_copies),                          -- Distinct уникально рвзмаривает все элементы
    SUM(number_copies) / COUNT(*) as clac_avg_copies,     -- SUM() нахождение  суммы, COUNT()
    MIN(number_copies) as min_copies,
    MAX(number_copies) as max_copies
from tp.games;

--8 Запрос, использующая скалярные подзапросы в выражениях столбцов
Select id,
       name,
       (Select AVG(number_employees)
        from tp.companies),
       (Select MIN(number_employees)
        from tp.companies
        where tp.games.developer = id),
from tp.games
where type = 'demo';

--9 Запрос, использующая простое выражение CASE
Select name,
      CASE 
          WHEN price = 0 THEN 'free'
          ELSE price::text || ' p.'
      END as price,
      CASE date_part('year', date_publish)
          WHEN date_part('year', now()) THEN 'this year'
          WHEN date_part('year', now()) - 1 THEN 'last year'
          ELSE (DATE_PART('year', now()) - DATE_PART('year', date_publish))::text || ' years ago'
      end as "when"    
from tp.games;

--10 Запрос, использующая поисковое выражение CASE
Select name,
       CASE
            WHEN number_employees < 500 THEN 'small'
            WHEN number_employees < 1000 THEN 'middle'
            WHEN number_employees < 5000 THEN 'large'
            else 'corporation'
       END as cmp
from tp.companies
order by cmp;

--11 Создание новой временной локальной таблицы из результирующего набора данных интрукции Select
Select id,
       price::money,
       (price * number_copies)::money as actives
INTO TEMP TABLE BestActives
from tp.games
where id IS NOT NULL and price > 0
group by id;

Select * from BestActives;
DROP TABLE BestActives;

--12 Запрос Select, использующая вложенные каррелированные подзапросы в качестве производных таблиц в предложении FROM
Select g.name
from tp.games g 
join (
    Select id, name, SUM(number_employees) as SNE
    from tp.companies
    group by id
    order by SNE desc
    LIMIT 1) as OD on od.id = g.developer;

--13 Запрос Select, использующая вложенные подзапросы с уровнем вложенности
--Вывести списко компаний, у которых игр набрали опред бюджет и игра с поределенным жанром
Select name as developer
from tp.companies
where id in ( Select g.developer
             from tp.games as g
             where g.id in (Select gameid
                           from tp.categories
                           where g.id = gameid and genreid in (Select id 
                                                               from tp.genres
                                                               where name like '%Steam%')
                         ) 
              and (price * number_copies) > 100000
            );

--14 Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING. 
Select g.id, g.name, g.price, AVG(c.number_employees) as avg_employees
from tp.games g left outer join tp.companies as c on c.id = g.developer
where g.type = 'game'
group by g.id, g.name, g.price
order by g.name;

--15 Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING
Select g.id, AVG(g.price)
from tp.games g
group by g.id
having avg(g.price) > (Select avg(price)
                       from tp.games);

Select * from tp.games
where id = 1001;
--16 Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений
Insert into tp.games
values (1001, 'ARK Survival Evolved', 'game', 378, 400, 14, '2005-01-10', 43131, 499.00);

--17 Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса
Insert into tp.categories
Select ( Select id from tp.games
         where name = 'ARK Survival Evolved'
), id
from tp.genres
where name like '%Steam%';

Select * from tp.categories
where gameid = 1001;

DELETE from tp.categories
where gameid = 1001;

--18 Простая инструкция UPDATE
UPDATE tp.games
SET price = price * 1.5
where id > 1000;

Select * from tp.games
where id > 1000;

--19 Инструкция UPDATE со скалярным подзапросом в предложении SET
Update tp.games
SET price = (Select AVG(price)
             from tp.games
             where price > 100)
where id > 950;    

--20 Простая инструкция DELETE
DELETE from tp.games
where id is null;

--21 Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
Delete from tp.games
where id in (Select g.id
                    from tp.games g left outer join tp.companies c 
                    on g.developer = c.id
                    where c.id is null
                    );
                    
--22 Инструкция SELECT, использующая обобщенное табличное выражениe
--Вывести сколько в среднем каждая компания разработала игр
with CDG(id, count_games) as(
    Select developer, count(*) as total
    from tp.games
    where developer is not null
    group by developer
)
SELECT AVG(count_games) as avg_count_games
from CDG;

--23 Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
WITH recursive PriceGames(gameid, gamename, devid, price, level) as 
(
    Select g.id, g.name, g.developer, g.price, 0 as level
    from tp.games as g
    where g.price = 0
    
    UNION
    
    Select g.id, g.name, g.developer, g.price, level + 1
    from tp.games as g 
    join PriceGames as d
    on g.price = d.price + 133 * (level + 1)
)
Select * from PriceGames;

select price from tp.games;

--24 Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--Для каждой компании вывести среднее значение стоимости игр
Select c.id, c.name, c.country, g.name as game, g.price,
       AVG(price) OVER(PARTITION BY c.id, c.name) as avg_price,
       MIN(price) OVER(PARTITION BY c.id, c.name) as min_price,
       MAX(price) OVER(PARTITION BY c.id, c.name) as max_price
from tp.companies as c 
join tp.games as g
on g.developer = c.id

--25 Oконные фнкции для устранения дублей
Select * from (Select c.id, c.name, c.country,
                      AVG(g.price) OVER(PARTITION BY c.id) avg_price,
                      MIN(price) OVER(PARTITION BY c.id, c.name) as min_price,
                      MAX(price) OVER(PARTITION BY c.id, c.name) as max_price,
                      row_number() OVER(PARTITION BY c.id order by c.name) cnt
               from tp.companies as c 
               join tp.games as g
               on g.developer = c.id) data
where cnt = 1;


Select c.name
from tp.companies as c;

Select c.id, c.name, count(c.id)
from tp.companies as c
join (
    Select g.id, g.name, g.developer, count(g.name) as cnt
    from tp.games as g
    join tp.supports as sp 
    on sp.gameid = g.id
    join tp.platforms as pl 
    on sp.platformid = pl.id and pl.name like '%Xbox%'
    group by g.id
    order by g.developer
) as gp on c.id = gp.developer
group by c.id
order by c.name;

Select g.name, c.name, 'Xbox' as platfrom
from tp.games as g
join tp.supports as sp
on sp.gameid = g.id
join tp.platforms as pl
on pl.id = sp.platformid
and pl.name like '%Xbox%'
join tp.companies as c
on g.developer = c.id
group by g.name, c.name
order by c.name;

