CREATE SCHEMA tp

CREATE TABLE IF NOT EXISTS tp.games (
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

CREATE TABLE IF NOT EXISTS tp.genres (
    id int,
    name text
);

CREATE TABLE IF NOT EXISTS tp.categories (
    gameId int,
    genreId int
);

CREATE TABLE IF NOT EXISTS tp.platforms (
    id int,
    name text,
    manufacturer int,
    type text,
    year_production int
);

CREATE TABLE IF NOT EXISTS tp.supports (
    gameId int,
    platformId int
);

CREATE TABLE IF NOT EXISTS tp.typies_company (
    id int,
    name text
);

CREATE TABLE IF NOT EXISTS tp.companies (
    id int,
    name text,
    country text,
    city text,
    sphere text,
    type int,
    year_creation int,
    number_employees int,
    url text
);

CREATE TABLE IF NOT EXISTS tp.clients (
    id int,
    nick text,
    surname text,
    name text,
    middle_name text,
    address text,
    sex text,
    birthday date,
    email text,
    login text,
    password text,
    registration_date date
);

CREATE TABLE IF NOT EXISTS tp.sales (
    gameId int,
    clientId int
);
