CREATE TABLE IF NOT EXISTS public.trading_platforms (
    id int primary key,
    type text not null,
    company int,
    date_of_creation date not null,
    number_of_users int default 0
);

CREATE TABLE IF NOT EXISTS public.pages_tp (
    id_game int,
    id_tp int,
    CONSTRAINT fk_games_page FOREIGN KEY(id_game) references public.games(id),
    CONSTRAINT fk_tp_page FOREIGN KEY(id_tp) references public.trading_platforms(id)
);
