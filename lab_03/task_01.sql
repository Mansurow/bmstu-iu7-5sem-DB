-- Скалярная функция

-- Возврат число, которое заработало компания за выпущенную игру
CREATE OR REPLACE FUNCTION tp.get_active(price NUMERIC, copies INTEGER)
RETURNS NUMERIC as $$
BEGIN
    RETURN price * copies;
END;
$$ LANGUAGE PLPGSQL;

Select name, tp.get_active(price, number_copies) as active 
FROM tp.games;

