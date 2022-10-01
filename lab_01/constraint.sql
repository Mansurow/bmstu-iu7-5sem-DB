ALTER table tp.games 
    ADD CONSTRAINT pk_games_id primary key(id);

ALTER table tp.genres 
    ADD CONSTRAINT pk_genre_id primary key(id),
    ALTER COLUMN name SET NOT NULL; 

ALTER table tp.platforms 
    ADD CONSTRAINT pk_platform_id primary key(id);

ALTER table tp.clients 
    ADD CONSTRAINT pk_client_id primary key(id);

ALTER table tp.companies 
    ADD CONSTRAINT pk_company_id primary key(id);

ALTER table tp.typies_company
    ADD CONSTRAINT pk_type_id primary key(id),
    ALTER COLUMN name SET NOT NULL;    

ALTER table tp.games 
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

ALTER table tp.categories
    ADD CONSTRAINT fk_gameid foreign key(gameid) references tp.games(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_genreid foreign key(genreid) references tp.genres(id) ON DELETE CASCADE,
    ALTER COLUMN gameid SET NOT NULL,
    ALTER COLUMN genreid SET NOT NULL;

ALTER table tp.platforms 
    ADD CONSTRAINT fk_manufacturer foreign key(manufacturer) references tp.companies(id) ON DELETE SET NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN year_production SET NOT NULL,
    ALTER COLUMN type SET NOT NULL;

ALTER table tp.supports
    ADD CONSTRAINT fk_gameid foreign key(gameid) references tp.games(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_platformid foreign key(platformid) references tp.platforms(id) ON DELETE CASCADE,
    ALTER COLUMN gameid SET NOT NULL,
    ALTER COLUMN platformid SET NOT NULL;

ALTER table tp.clients 
    ALTER COLUMN nick SET NOT NULL,
    ALTER COLUMN surname SET NOT NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN middle_name SET NOT NULL,
    ALTER COLUMN address SET NOT NULL,
    ALTER COLUMN sex SET NOT NULL,
    ALTER COLUMN birthday SET NOT NULL,
    ALTER COLUMN password SET NOT NULL,
    ALTER COLUMN registration_date SET NOT NULL,
    ADD CONSTRAINT valid_registration CHECK(registration_date <= current_date),
    ADD CONSTRAINT valid_birthday CHECK(birthday <= current_date),
    ADD CONSTRAINT UC_client UNIQUE (email, login);

ALTER table tp.sales
    ADD CONSTRAINT fk_gameid foreign key(gameid) references tp.games(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_clientid foreign key(clientid) references tp.clients(id) ON DELETE CASCADE,
    ALTER COLUMN gameid SET NOT NULL,
    ALTER COLUMN clientid SET NOT NULL;

ALTER table tp.companies 
    ADD CONSTRAINT fk_type foreign key(type) references tp.typies_company(id) ON DELETE SET NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN country SET NOT NULL,
    ALTER COLUMN city SET NOT NULL,
    ALTER COLUMN sphere SET NOT NULL,
    ALTER COLUMN type SET NOT NULL,
    ALTER COLUMN year_creation SET NOT NULL,
    ALTER COLUMN url SET NOT NULL,
    ADD CONSTRAINT valid_number_employees CHECK(number_employees >= 0),
    ADD CONSTRAINT valid_type CHECK(type >= 0);
    