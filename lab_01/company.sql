CREATE TABLE IF NOT EXISTS public.type_company (
    id int primary key,
    name text not null
);

CREATE TABLE IF NOT EXISTS public.companies (
    id int primary key,
    name text not null,
    country text not null,
    type int,
    date_of_creation date not null,
    CONSTRAINT fk_type_company FOREIGN KEY(type) references public.type_company(id)
);