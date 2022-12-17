Select game.name as game,
       dev.name as developer,
       pub.name as publisher
from tp.games as game
join tp.companies as dev on dev.id = game.developer
join tp.companies as pub on pub.id = game.publisher;

Select * from tp.genres;