import sqlalchemy
from sqlalchemy import create_engine, select, insert, update, delete, func
from sqlalchemy.orm import Session, sessionmaker, class_mapper

from json import dumps, load

from tp.models import *

# LINQ to Object
# 1. Вывести список всех компаний - название и тип
def get_name_type_companies(session):
    data = session.query(Companies).join(Companies.typiescompany).all()
    for row in data:
        print((row.name, row.typiescompany.name))

# 2. Вывести все игры у которых разработчик и издатель один и тот же
def get_games_same_dp(session):
    data = session.query(Games).where(Games.developer == Games.publisher).order_by(Games.id).all()
    for row in data:
        print((row.id, row.name, row.type, float(row.price), str(row.date_publish)))

# 3. Вывести средную цену игр
def get_avg_games(session):
    data = session.query(func.avg(Games.price).label("avg_price"))
    for row in data:
        print(row.avg_price)

# 4. Вывести количество платформ у игр
def get_game_count_pl(session):
    games_support = session.query(
            (Games.name).label("game"),
            func.count(Games.name).label('count_platfroms'),
        ).join(Supports).join(Platforms).group_by(Games.name).all()
    for row in games_support:
        print((row.game, row.count_platfroms))

# 5. Вывести игру и ее активы 
def get_actives_game(session):
    data = session.query(Games.name, Games.price, (Games.price * Games.number_copies).label("actives")).all()
    for row in data:
        print((row.name, float(row.price), float(row.actives)))

# LINQ to JSON
# 1. Запись в Json

def serialize_all(model):
  """Transforms a model into a dictionary which can be dumped to JSON."""
  # first we get the names of all the columns on your model
  columns = [c.key for c in class_mapper(model.__class__).columns]
  # then we return their values in a dict
  return dict((c, getattr(model, c)) for c in columns)

def games_to_json(session):
    serialized_labels = [
    serialize_all(label) 
    for label in session.query(Games).order_by(Games.id).all()
    ]

    for dt in serialized_labels:
        dt["date_publish"] = str(dt["date_publish"])
        dt["price"] = float(dt["price"])

    with open('lab_07/games.json', 'w') as f:
        f.write(dumps(serialized_labels,indent=4))

def read_json():
    with open('lab_07/games.json') as f:
        games = load(f)

    for g in games:
        print(g)    

# LINQ to SQL

# 1. Однотабличный запрос на выборку.
# Вывести название игрыи цену игры
def select_name_price_games(session):
    res = session.execute(
        select(Games.name, Games.price)
    )

    for g in res:
        print((g.name, float(g.price)))
  
# 2. Многотабличный запрос на выборку.
# Вывести название платформ у которых более 500 игр

def select_platform_count_games(session):
    res = session.execute("""
        Select * from (Select p.name as platform, count(*) as count_games from tp.platforms as p
        join tp.supports as s on s.platformid = p.id
        group by p.id) as dp 
        where dp.count_games > 500   
        """)
    for pl in res:
            print(pl)
# 3. Три запроса на добавление, изменение и удаление данных в базе данных.

# Добавление данных в таблицу  insert into tp.games
def insert_games(session):
    try:
        name = input("Название игры: ")
        type = input("Тип: ")
        developer = int(input("Разработчик: "))
        publisher = int(input("Издатель: "))
        req_age = int(input("Огр. возраст: "))
        date_pubish = input("Дата выпуска: ")
        price = float(input("Цена: "))
        num_copies = int(input("Кол-во копий: "))

        count_games = session.query(func.count(Games.name)).all()
        id = count_games[0][0] + 1

        session.execute (
            insert(Games).values(
                id=id,
                name=name,
                type=type,
                developer=developer,
                publisher=publisher,
                req_age=req_age,
                date_publish=date_pubish,
                number_copies=num_copies,
                price=price  
            )
        )
        session.commit()
        print("Данные успешно добавлены!")
    except:
            print("error input data",)
            return

# Select * from tp.games
def select_games_all(session):
    games = session.query(Games).order_by(Games.id).all()
    for g in games:
        print((g.id, g.name, g.type, g.developer, g.publisher, g.req_age, str(g.date_publish), float(g.price), g.number_copies))

# Обновление данных update tp.games
def update_games_price(session):
    name = input("Название игры: ")
    price = float(input("Новая цена для игры: "))

    exists = session.query(
                session.query(Games).where(Games.name == name).exists()
            ).scalar()

    if not exists:
        print("Такой игры нет!")
        return

    session.execute(
        update(Games).where(Games.name == name).values(price=price)
    )
    session.commit()
    print("Данные успешно измененны!")

# Удаление данных delete tp.games
def delete_games_by_name(session):
    name = input("Название игры для удаления: ")

    exists = session.query(
                session.query(Games).where(Games.name == name).exists()
            ).scalar()

    if not exists:
        print("Такой игры нет!")
        return

    session.execute(
        delete(Games).where(Games.name == name)
    )
    session.commit()
    print("Данные успешно удалены!")

# 4. Получение доступа к данным, выполняя только хранимую процедуру или функцию.
# Вывести клиентов у которых игр больше указаного количества
def call_get_clients(session):
    numbers = int(input("Введите кол-во игр у игроков: "))
    data = session.execute(f"Select * from tp.get_clients(%d);" %(numbers)).all()
    for row in data:
        print(row)


MSG = "\n\t\t\tМеню\n\n"\
      "\t--------- LINQ_to_Object -------------- \n"\
      "\t(1) 5 запросов созданные для проверки LINQ\n"\
      "\t  1. Вывести список всех компаний - название и тип\n"\
      "\t  2. Вывести все игры у которых разработчик и издатель один и тот же \n"\
      "\t  3. Вывести средную цену игр \n"\
      "\t  4. Вывести количество платформ у игр \n"\
      "\t  5. Вывести игру и ее активы \n"\
      "\t--------- LINQ_to_JSON -------------- \n"\
      "\t  6. Запись в JSON документ. \n"\
      "\t  7. Чтение из JSON документа. \n"\
      "\t  8. Обновление JSON документа. \n"\
      "\t--------- LINQ_to_SQL -------------- \n"\
      "\t(3) Создать классы сущностей, которые моделируют таблицы Вашей базы данных\n"\
      "\t  9. Однотабличный запрос на выборку. (Вывести название игрыи цену игры)\n"\
      "\t 10. Многотабличный запрос на выборку. (Вывести название платформ у которых более 500 игр)\n"\
      "\t (3.1) Три запроса на добавление, изменение и удаление данных в базе данных\n"\
      "\t 11. Добавление данных в таблицу  insert into tp.games\n"\
      "\t 12. Обновление данных update tp.games\n"\
      "\t 13. Удаление данных delete tp.games\n"\
      "\t 14. Select * from tp.games\n"\
      "\t (3.2) Получение доступа к данным, выполняя только хранимую процедуру\n"\
      "\t 15. Вызов функции tp.get_clients\n"\
      "\t0. Выход \n\n"\
      "\tВыбор: "

def input_command():
    try:
        command = int(input(MSG))
        print()
    except:
        command = -1
    
    if command < 0 or command > 15:
        print("\nОжидался ввод целого числа от 0 до 15")

    return command

def main():
    print("Версия SQL Alchemy:", sqlalchemy.__version__)

    engine = create_engine(
        f'postgresql://postgres:postgres@localhost:5555/lab_01',
        pool_pre_ping=True)
    try:
        engine.connect()
        print("БД под именнем  tp успешно подключена!")
    except:
        print("Ошибка соединения к БД!")
        return    

    Session = sessionmaker(bind=engine)
    session = Session()
    command = -1

    while command != 0:
        command = input_command()

        if command == 1:
            get_name_type_companies(session)
        elif command == 2:
            get_games_same_dp(session)
        elif command == 3:
            get_avg_games(session)
        elif command == 4:
            get_game_count_pl(session)
        elif command == 5:
            get_actives_game(session)
        elif command == 6:
            games_to_json(session)
        elif command == 7:
            read_json()
        elif command == 8:
            print()
        elif command == 9:
            select_name_price_games(session)
        elif command == 10:
            select_platform_count_games(session)
        elif command == 11:
            insert_games(session)
        elif command == 12:
            update_games_price(session)
        elif command == 13:
            delete_games_by_name(session)
        elif command == 14:
            select_games_all(session)
        elif command == 15:
            call_get_clients(session)                                                
        else:
            continue

if __name__ == "__main__":
    main()