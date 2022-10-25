-- Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ

CREATE OR REPLACE PROCEDURE reverse_counter(count int)
AS $$
BEGIN
    IF count > 0 THEN
        RAISE NOTICE 'cout = %', 
            count;
           
        CALL reverse_counter(count - 1);
    ELSE
        RAISE NOTICE 'END';
    END IF; 
END;
$$ LANGUAGE PLPGSQL;

CALL reverse_counter(10);