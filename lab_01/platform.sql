CREATE TABLE IF NOT EXISTS public.platforms (
    id int primary key,
    name text not null,
    manufacturer text not null,
    year_start_of_production date,
    type text not null
);

CREATE TABLE IF NOT EXISTS public.supports (
    id_game int,
    id_platform int,
    CONSTRAINT fk_GS FOREIGN KEY(id_game) references public.games(id),
    CONSTRAINT fk_PS FOREIGN KEY(id_platform) references public.platforms(id)
);