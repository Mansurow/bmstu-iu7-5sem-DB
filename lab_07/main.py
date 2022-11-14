import sqlalchemy
from sqlalchemy import create_engine, select, insert, update, delete, func
from sqlalchemy.orm import Session, sessionmaker

import json

from tp.models import *

print("Версия SQL Alchemy:", sqlalchemy.__version__)


engine = create_engine(
    f'postgresql://postgres:postgres@localhost:5555/lab_01',
    pool_pre_ping=True)
    

Session = sessionmaker(bind=engine)
session = Session()
print(session)

# LINQ to Object
# 1. Вывести список всех компаний - название и тип
def get_name_type_companies(session):
    data = session.query(Companies).join(Companies.typiescompany).all()
    for row in data:
        print((row.name, row.typiescompany.name))

# 2. Вывести все игры у которых разработчик и издатель один и тот же
def get_games_same_dp(session):
    data = session.query(Games).where(Games.developerID == Games.publisherID).order_by(Games.id).all()
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

#data = session.query(Games).all()

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
        Select p.name as platform, count(*) as count_games from tp.platforms as p
        join tp.supports as s on s.platformid = p.id
        group by p.id    
        """)
    for pl in res:
            print(pl)
# 3. Три запроса на добавление, изменение и удаление данных в базе данных.

# Добавление данных в таблицу  insert into tp.games
def insert_games(session):
    try:
        name = input("Название игры: ")
        type = input("Тип: ")
        developer = input("Разработчик: ")
        publisher = input("Издатель: ")
        req_age = int(input("Огр. возраст: "))
        date_pubish = input("Дата выпуска: ")
        price = float(input("Цена: "))
        num_copies = int(input("Кол-во копий: "))

        count_games = session.query(func.count(Games.name)).all()
        id = count_games[0][0] + 1

        find_dev = session.query(Companies.id).join(Games, Companies.id == Games.developerID).\
            where(Companies.name.like('Valve%')).group_by(Companies.id).all()
        if find_dev:
            developer = find_dev[0][0]
        else:
            print("Такого разработчика не существует!")
            return

        find_pub = session.query(Companies.id).join(Games, Companies.id == Games.developerID).\
            where(Companies.name.like('Valve%')).group_by(Companies.id).all()
        if find_pub:
            publisher = find_pub[0][0]
        else:
            print("Такого издателя не существует!")
            return

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
            print("error input data")
            return

# Select * from tp.games
def select_games_all(session):
    games = session.query(Games).order_by(Games.id).all()
    for g in games:
        print((g.id, g.name, g.type, g.developerID, g.publisherID, g.req_age, str(g.date_publish), float(g.price), g.number_copies))

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
def call_get_clients(sessiom):
    numbers = int(input("Введите кол-во игр у игроков: "))
    data = session.execute(f"Select * from tp.get_clients(%d);" %(numbers)).all()
    for row in data:
        print(row)
