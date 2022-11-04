from tp_db import TradePlatfromDB

MSG = "\n\t\tМеню\n\n"\
      "\t1. Выполнить скалярный запрос \n"\
      "\t2. Выполнить запрос с несколькими соединениями (JOIN) \n"\
      "\t3. Выполнить запрос с ОТВ(CTE) и оконными функциями \n"\
      "\t4. Выполнить запрос к метаданным \n"\
      "\t5. Вызвать скалярную фуclнкцию \n"\
      "\t6. Вызвать многооператорную табличную функцию \n"\
      "\t7. Вызвать хранимую процедуру \n"\
      "\t8. Вызвать системную функцию \n"\
      "\t9. Создать таблицу в базе данных, соответствующую тематике БД \n"\
      "\t10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT \n"\
      "\t0. Выход \n\n"\
      "\tВыбор: "\

def input_command():
    try:
        command = int(input(MSG))
        print()
    except:
        command = -1
    
    if command < 0 or command > 10:
        print("\nОжидался ввод целого чилово числа от 0 до 10")

    return command

def main():
    db_tp = TradePlatfromDB()
    command = -1

    while command != 0:
        command = input_command()

        if command == 1:
            print("Cреднее количество сотрудников в комании:",
            db_tp.get_avg_employees())

        elif command == 2:
            db_tp.get_game_table()

        elif command == 3:
            db_tp.get_companies_avg_price_game()

        elif command == 4:
            table = input("Введите название таблицы:")
            db_tp.get_data_types(table)

        elif command == 5:
            db_tp.get_actives_game()

        elif command == 6:
            db_tp.get_clients(500)

        elif command == 7:
            db_tp.discount_procedure(10)

        elif command == 8:
            db_tp.system_functionc_call()

        elif command == 9:
            db_tp.create_table_dls_games()

        elif command == 10:
            print("Ввод данных для tp.games")
            id = int(input("id: "))
            name = input("name: ")
            gameid = int(input("gameid: "))
            date = input("date: ")
            db_tp.insert_table_dls_games(id, name, gameid, date)
        else:
            continue
        
        db_tp.print_table()
   

if __name__ == "__main__":
    main()   