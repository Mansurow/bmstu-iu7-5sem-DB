from time import time, sleep
import threading

import matplotlib.pyplot as plt
import psycopg2
import redis
import json
from random import randint

from faker import Faker
faker = Faker('en')

N_REPEATS = 5

def connection():
    # Подключаемся к БД.
    try:
        con = psycopg2.connect(
            database='lab_01',
            user='postgres',
            password='postgres',
            host='127.0.0.1',
            port=5555
        )
    except:
        print("Ошибка при подключении к Базе Данных")
        return

    print("База данных успешно открыта")
    return con

# Написать запрос, получающий статистическую информацию на основе
# данных БД. Например, получение топ 10 самых покупаемых товаров или
# получение количества проданных деталей в каждом регионе.
# Игры одного типа mod
def get_games_mod(cur):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)
    cache_value = redis_client.get('games_mod')
    if cache_value is not None:
        redis_client.close()
        return json.loads(cache_value)
    
    cur.execute("select * from tp.games where type = 'mod'")
    res = cur.fetchall()

    redis_client.set("games_mod", json.dumps(res, default=str))
    redis_client.close()

    return res

# Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша.        
def get_games_redis(cur, type):
    #threading.Timer(5.0, get_games_redis, [cur, type]).start()
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cache_value = redis_client.get(f"games_{type}")
    # if cache_value is not None:
    #     redis_client.close()
    #     return json.loads(cache_value)
    cur.execute(f"select * from tp.games where type = '{type}'")

    result = cur.fetchall()
    data = json.dumps(result, default=str)
    redis_client.set(f"games_{type}", data)
    redis_client.close()

    return result

# Приложение выполняет запрос каждые 5 секунд на стороне БД.
def get_games_db(cur, type):
    #threading.Timer(5.0, get_games_db, [cur, type]).start()
    
    cur.execute(f"select * from tp.games where type = '{type}'")

    result = cur.fetchall()
    return result

def select_query(cur):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    td1 = time()
    cur.execute("select * from tp.games_redis where type = 'mod'")
    td2 = time()

    result = cur.fetchall()

    data = json.dumps(result, default=str)
    cache_value = redis_client.get("g1")
    if cache_value is not None:
        pass
    else:
        redis_client.set("g1", data)

    tr1 = time()
    redis_client.get("g1")
    tr2 = time()

    redis_client.close()
    return td2 - td1, tr2 - tr1

def insert_query(cur, con):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cur.execute("select count(*) from tp.games_redis")
    count_games = cur.fetchall()
    id = count_games[0][0] + 1
    name = faker.word() 
    type = 'game'
    developer = randint(1, 1032)
    publisher = randint(1, 1032)
    req_age = randint(12, 21)
    date_publish = faker.date()
    number_copies = randint(500, 10000)
    price = randint(1000, 300000) / randint(5, 100)

    td1 = time()
    cur.execute(f"insert into tp.games_redis "
                f"values ({id}, '{name}', '{type}', {developer}, {publisher}, {req_age}, '{date_publish}', {number_copies}, {price});")
    td2 = time()
    con.commit()

    cur.execute(f"Select * from tp.games_redis where id = {id};")
    print("Добавленные данные:")
    result = cur.fetchall()
    print(result[0])

    data = json.dumps(result,  default=str)
    tr1 = time()
    redis_client.set(f"g{id}", data)
    tr2 = time()

    redis_client.close()
    return td2 - td1, tr2 - tr1

def delete_query(cur, con):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cur.execute("select count(*) from tp.games_redis")
    count_games = cur.fetchall()
    id = count_games[0][0]

    cur.execute(f"Select * from tp.games_redis where id = {id};")
    print("Удаленные данные:")
    result = cur.fetchall()
    print(result[0])

    td1 = time()
    cur.execute(f"delete from tp.games_redis where id = {id};")
    td2 = time()
    con.commit()
    
    tr1 = time()
    redis_client.delete(f"g{id}")
    tr2 = time()

    redis_client.close()
    return td2 - td1, tr2 - tr1

def update_query(cur, con):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cur.execute("select count(*) from tp.games_redis")
    count_games = cur.fetchall()
    id = count_games[0][0]

    rand_id = randint(1, id)

    name = faker.word();

    td1 = time()
    cur.execute(f"UPDATE tp.games_redis SET name = '{name}' WHERE id = {rand_id}")
    td2 = time()
    con.commit()
    
    cur.execute(f"Select * from tp.games_redis where id = {rand_id};")
    print("Обновленные данные --- имя:", name)
    result = cur.fetchall()
    print(result[0])

    data = json.dumps(result, default=str)

    tr1 = time()
    redis_client.set(f"g{rand_id}", data)
    tr2 = time()

    redis_client.close()
    return td2 - td1, tr2 - tr1

def make_result(cur, con):
    # select 
    t1 = 0
    t2 = 0
    print("Количетсво повторов:", N_REPEATS)
    for i in range(N_REPEATS):
        
        b1, b2 = select_query(cur)
        t1 += b1
        t2 += b2
    print("Без изменения данных: \n\tdb:", t1 / N_REPEATS, "\n\tredis:", t2 / N_REPEATS)
    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("Без изменения данных")
    plt.show()

    # insert
    t1 = 0
    t2 = 0
    print("Количетсво повторов:", N_REPEATS)
    for i in range(N_REPEATS):
        
        b1, b2 = insert_query(cur, con)
        t1 += b1
        t2 += b2
        sleep(10)
    print("При добавлении данных: \n\tdb:", t1 / N_REPEATS, "\n\tredis:", t2 / N_REPEATS)
    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("При добавлении новых строк каждые 10 секунд")
    plt.show()

    # delete
    t1 = 0
    t2 = 0
    print("Количетсво повторов:", N_REPEATS)
    for i in range(N_REPEATS):
        
        b1, b2 = delete_query(cur, con)
        t1 += b1
        t2 += b2
        sleep(10)
    print("При удалении данных: \n\tdb:", t1 / N_REPEATS, "\n\tredis:", t2 / N_REPEATS)
    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("При удалении новых строк каждые 10 секунд")
    plt.show()

    # Update
    t1 = 0
    t2 = 0
    print("Количетсво повторов:", N_REPEATS)
    for i in range(N_REPEATS):
        
        b1, b2 = update_query(cur, con)
        t1 += b1
        t2 += b2
        sleep(10)
    print("При обновлении данных: \n\tdb:", t1 / N_REPEATS, "\n\tredis:", t2 / N_REPEATS)
    index = ["БД", "Redis"]
    values = [t1 / N_REPEATS, t2 / N_REPEATS]
    plt.bar(index, values)
    plt.title("При обновлении данных каждые 10 секунд")
    plt.show()

def main():
    con = connection()
    cur = con.cursor()

    print("1. Моды игр (задание 2)\n"
          "2. Приложение выполняет запрос каждые 5 секунд на стороне БД. (задание 3.1)\n"
          "3. Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша. (задание 3.2)\n"
          "4. Результаты сравнений (задание 3.3)\n"
          "0. Выход\n"
          )
    

    while True:
        choose = int(input("\n\tВыбор: "))
        if (choose == 0):
            break

        if (choose == 1):
            res = get_games_mod(cur)
            for elem in res:
                print(elem)
        elif (choose == 2):
            type = input("Введите тип игры: ")
            while True:
                print("----------------New-----------------")
                res = get_games_db(cur, type)
                for el in res:
                    print(el)
                print("----------------END-----------------")    
                sleep(5) 
            
        elif (choose == 3):
            type = input("Введите тип игры: ")
            while True:
                print("----------------New-----------------")
                res = get_games_redis(cur, type)
                for el in res:
                    print(el)
                print("----------------END-----------------")    
                sleep(5) 
        elif (choose == 4):
            make_result(cur, con)     
        else:
            print("Ошибка! Неверная команда!\n")
            break        

if __name__ == "__main__":
    main()