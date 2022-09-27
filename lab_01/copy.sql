COPY public.clients FROM '/var/lib/postgresql/data/clients.csv' DELIMITER ',' CSV HEADER;

COPY public.typies_company FROM '/var/lib/postgresql/data/typies_company.csv' DELIMITER ',' CSV HEADER;
COPY public.companies FROM '/var/lib/postgresql/data/companies.csv' DELIMITER ',' CSV HEADER;

COPY public.games FROM '/var/lib/postgresql/data/games.csv' DELIMITER ',' CSV HEADER;
COPY public.platforms FROM '/var/lib/postgresql/data/platforms.csv' DELIMITER ',' CSV HEADER;
COPY public.supports FROM '/var/lib/postgresql/data/supports.csv' DELIMITER ',' CSV HEADER;

COPY public.genres FROM '/var/lib/postgresql/data/genres.csv' DELIMITER ',' CSV HEADER;
COPY public.categories FROM '/var/lib/postgresql/data/categories.csv' DELIMITER ',' CSV HEADER;

COPY public.sales FROM '/var/lib/postgresql/data/sales.csv' DELIMITER ',' CSV HEADER;

