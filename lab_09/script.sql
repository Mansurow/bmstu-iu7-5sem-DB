CREATE TABLE IF NOT EXISTS tp.games_redis (
    id int,
    name text,
    type text,
    developer int,
    publisher int,
    req_age int,
    date_publish date,
    number_copies int,
    price numeric
);

ALTER table tp.games_redis
    ADD CONSTRAINT pk_games_redis_id primary key(id);

ALTER table tp.games_redis 
    ADD CONSTRAINT fk_developer foreign key(developer) references tp.companies(id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_publisher foreign key(publisher) references tp.companies(id) ON DELETE SET NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN type SET NOT NULL,
    ALTER COLUMN req_age SET NOT NULL,
    ALTER COLUMN date_publish SET NOT NULL,
    ALTER COLUMN number_copies SET NOT NULL,
    ALTER COLUMN price SET NOT NULL,
    ADD CONSTRAINT positive_price CHECK(price >= 0),
    ADD CONSTRAINT positive_copies CHECK(number_copies >= 0);   

COPY tp.games_redis FROM '/var/lib/postgresql/data/games.csv' DELIMITER ',' CSV HEADER;    