--1.Запрос с предикатом сравнения
select G1.name,
       G1.type,
       C1.name as developer, 
       C1.name as publisher,
       G1.price,
       G1.date_publish,
       G1.number_copies
from games G1 join companies as C1 on
     G1.developer = C1.id and G1.publisher = C1.id 
     where G1.number_copies > 1000000
order by G1.name, developer, publisher;

--2 Запрос с предикатом between
Select games.name,
       games.date_publish
from games
where date_publish between '01-01-2000' and '2020-01-01';

--3 Запрос с предикатом Like
Select clients.nick, games.name 
from games, clients
where clients.nick like '%and%' and 
games.id = 2

--4 Запрос с предикатом in
Select 
