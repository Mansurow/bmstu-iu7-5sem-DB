COPY tp.clients FROM '/var/lib/postgresql/data/clients.csv' DELIMITER ',' CSV HEADER;

COPY tp.typies_company FROM '/var/lib/postgresql/data/typies_company.csv' DELIMITER ',' CSV HEADER;
COPY tp.companies FROM '/var/lib/postgresql/data/companies.csv' DELIMITER ',' CSV HEADER;

COPY tp.games FROM '/var/lib/postgresql/data/games.csv' DELIMITER ',' CSV HEADER;
COPY tp.platforms FROM '/var/lib/postgresql/data/platforms.csv' DELIMITER ',' CSV HEADER;
COPY tp.supports FROM '/var/lib/postgresql/data/supports.csv' DELIMITER ',' CSV HEADER;

COPY tp.genres FROM '/var/lib/postgresql/data/genres.csv' DELIMITER ',' CSV HEADER;
COPY tp.categories FROM '/var/lib/postgresql/data/categories.csv' DELIMITER ',' CSV HEADER;

COPY tp.sales FROM '/var/lib/postgresql/data/sales.csv' DELIMITER ',' CSV HEADER;

