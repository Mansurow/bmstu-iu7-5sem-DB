CREATE TABLE IF NOT EXISTS public.staff (
    id int primary key,
    surname text not null,
    name text not null,
    middle_name text not null,
    sex text not null,
    birthday date not null,
    vocation text not null,
    country text not null,
    company int,
    CONSTRAINT fk_company FOREIGN KEY(company) references public.companies(id)
);