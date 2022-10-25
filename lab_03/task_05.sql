-- Хранимую процедуру без параметров или с параметрами

-- c параметров

-- Введется распродажа ввести 15% на все игры

CREATE OR REPLACE PROCEDURE tp.discount(percent int)
AS $$
BEGIN
    UPDATE tp.games
    SET price = price - (price / 100 * percent);
END;
$$ LANGUAGE PLPGSQL;

-- Повышение цен на указанный процент от стоимости игр и id игры

CREATE OR REPLACE PROCEDURE tp.price_up(game int, percent int)
AS $$
BEGIN
    UPDATE tp.games
    SET price = price + (price / 100 * percent)
    where id = game;
END;
$$ LANGUAGE PLPGSQL;

Select * from tp.games;

CALL tp.discount(15);
CALL tp.price_up(1, 100);
