import psycopg2

class TradePlatfromDB:
    def __init__(self):
        try:
            self.__connection = psycopg2.connect(
                    database='lab_01',
                    user='postgres', 
                    password='postgres',
                    host='127.0.0.1',
                    port="5555")
            self.__connection.autocommit = True
            self.__cursor = self.__connection.cursor()
            self.table = []
            print("PostgreSQL connection opened\n")        
        except Exception as ex:
            print("Error while connecting with PostgreSQL\n", ex)
            return

    def __del__(self):
        if self.__connection:
            self.__cursor.close()
            self.__connection.close()
            print("PostgreSQL connection closed\n")
    
    def __sql_executer(self, sql_query):
        try:
            self.__cursor.execute(sql_query)
        except Exception as err:
            print("Error while get query - PostgreSQL\n", err)
            return
    
        return sql_query

    # 1. Скалаярный запрос
    def get_avg_employees(self):

        print("Вывести среднее количество сотрудников в компаниях.")

        sql_query = \
            """
            Select AVG(number_employees)
            from tp.companies
            """
        if self.__sql_executer(sql_query) is not None:
             row = self.__cursor.fetchone()

             return row[0]  
        
    # 2. Выполнить запрос с несколькими соединениями (JOIN)
    def get_game_table(self):
        print("Вывести таблицу данных о игр (первые 10)")
        sql_query = \
            """
            Select g.name,
                   g.type, 
                   cd.name as developer,
                   cp.name as publisher,
                   g.date_publish  
            from tp.games g
            join tp.companies cd on cd.id = g.developer
            join tp.companies cp on cp.id = g.publisher
            WHERE g.id < 11
            """
        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 3. Выполнить запрос с ОТВ(CTE) и оконными функциями
    def get_companies_avg_price_game(self):
        print("Вывести таблицу данных о компании и средней цены за все их игр")
        sql_query = \
            """
            with CPG(developer, avg_price) as(
                Select developer, AVG(price) as avg_price
                from tp.games 
                group by developer
                order by developer
            )
            SELECT c.id, c.name as developer, 
                g.avg_price
            from CPG g
            right outer join tp.companies c 
            on c.id = g.developer
            where c.id between 100 and 110 
            order by c.id;
            """
        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 4. Выполнить запрос к метаданным;
    def get_data_types(self, name_table):
        print("Вывести данные о типах атрибутах в таблице", name_table)
        sql_query = \
        """
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = \'%s\';
        """ %(name_table)

        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 5 Вызвать скалярную функцию (написанную в третьей лабораторной работе);
    def get_actives_game(self):
        print("Возврат число, которое заработало компания за выпущенную игру.")
        sql_query = \
        """
        CREATE OR REPLACE FUNCTION tp.get_active(price NUMERIC, copies INTEGER)
        RETURNS NUMERIC as $$
        BEGIN
            RETURN price * copies;
        END;
        $$ LANGUAGE PLPGSQL;

        Select name, tp.get_active(price, number_copies)::money as active 
        FROM tp.games;
        """

        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 6. Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе);
    def get_clients(self, count):
        print("Вывести клиентов у которых игр больше указаного количества.")
        sql_query = \
        """
            CREATE OR REPLACE FUNCTION tp.get_clients(count_games int)
            RETURNS TABLE (id int, nick text, count bigint)
            AS $$
            BEGIN

            Drop table if exists result;
            
            Create temp table if not exists result (id int, nick text, count bigint);

            Insert into result(id, nick, count)
                Select *
                from (SELECT c.id, c.nick, count(*) as cnt
                FROM tp.clients as c
                    join tp.sales as s on c.id = s.clientid     
                group by c.id, c.name) as tmp
                where tmp.cnt >= count_games;
                
                RETURN QUERY
                SELECT *
                FROM Result
                order by nick;
            END            
            $$ LANGUAGE PLPGSQL;

            Select * from tp.get_clients(%d);
        """  %(count)

        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 7. Вызвать хранимую процедуру (написанную в третьей лабораторной работе);
    def discount_procedure(self, percent):
        print("Распродажа игр по указанным процентом.")
        sql_query = \
        """
        CREATE OR REPLACE PROCEDURE tp.discount(percent int)
        AS $$
        BEGIN
            UPDATE tp.games
            SET price = price - (price / 100 * percent);
        END;
        $$ LANGUAGE PLPGSQL;

        CALL tp.discount(%d);

        Select name, price from tp.games;
        """ %(percent)

        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 8. Вызвать системную функцию или процедуру;
    def system_functionc_call(self):
        print("Вызвать системную функцию для вывода имени текущей базы данных.")

        sql_query = \
        """
            -- Вызвать системную функцию.
            SELECT *
            FROM current_database();
        """

        if self.__sql_executer(sql_query) is not None:
             self.table = self.__cursor.fetchall()

    # 9. Создать таблицу в базе данных, соответствующую тематике БД;
    def create_table_dls_games(self):
        print("Создать таблицу DLS игр")

        sql_query = \
        """
        DROP TABLE IF EXISTS tp.dls;
        CREATE TABLE IF NOT EXISTS tp.dls
        (
            id int PRIMARY KEY,
            name text not null,
            game int,
            date_publish date CHECK(date_publish <= current_date),
            CONSTRAINT fk_game foreign key(game) references tp.games(id) 
            ON DELETE CASCADE
        );
        """

        if self.__sql_executer(sql_query) is not None:
            print("ОК")
        else:
            print("Error! Check Sql Query!")    

    # 10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY
    def insert_table_dls_games(self, id, name, gameid, date):
        print("Вставка данных в таблицу tp.dls.")
        sql_query = \
        """
        INSERT INTO tp.dls(id, name, game, date_publish)
        VALUES(%d, \'%s\', %d, \'%s\')
        """ %(id, name, gameid, date)

        if self.__sql_executer(sql_query) is not None:
            print("ОК")
        else:
            print("Error! Check Sql Query!")  

    def print_table(self):
        for r in self.table:
            print(r)          
