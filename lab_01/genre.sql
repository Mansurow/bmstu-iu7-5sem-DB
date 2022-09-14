CREATE TABLE IF NOT EXISTS public.genres (
    id int primary key,
    type text not null,
    subtype text not null
);

CREATE TABLE IF NOT EXISTS public.categories (
    id_game int,
    id_genre int,
    CONSTRAINT fk_games_cat FOREIGN KEY(id_game) references public.games(id),
    CONSTRAINT fk_genre_cat FOREIGN KEY(id_genre) references public.genres(id)
);