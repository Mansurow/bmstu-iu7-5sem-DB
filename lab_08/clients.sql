CREATE TABLE IF NOT EXISTS tp.clients_nifi (
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

ALTER table tp.clients_nifi
    ADD CONSTRAINT pk_client_nifi_id primary key(id);
    
ALTER table tp.clients_nifi
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
    ADD CONSTRAINT un_client UNIQUE (email, login);

DELETE FROM tp.clients_nifi;        