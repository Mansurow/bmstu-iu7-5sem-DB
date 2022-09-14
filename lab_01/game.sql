CREATE TABLE IF NOT EXISTS public.games (
    id int primary key,
    name text not null,
    developer int,
    publisher int,
    year_of_publication date,
    price money default 0,
    CONSTRAINT fk_developer FOREIGN KEY(developer) references public.companies(id),
    CONSTRAINT fk_publisher FOREIGN KEY(publisher) references public.companies(id)
);
