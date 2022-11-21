import json
import datetime
import os
import time
from faker import Faker

faker = Faker('ru')

SLEEP_TIME_SEC = 300 # 5 минут

id = 0 # идентификатор файла
name_table = 'clients' # имя таблицы в которую загружаются данные из этого файла
date_mask = '%Y-%m-%d-%H.%M.%S' # маска для даты и времени формирования файла
file_mask = '{}_{}_{}.json' # маска для файла
dir = './data/lab_08/' # путь к файлу


def generate_json(count):
    clients = []
    for i in range(count):
        user = faker.simple_profile()
        fio = user['name'].split()
        client = {"id": i + 1,
                  "nick": user['username'], 
                  "surname": fio[2], 
                  "name": fio[0], 
                  "middle_name": fio[1],
                  "address": faker.country() + " " + faker.address(),
                  "sex": user['sex'],
                  "birthday": faker.date(),
                  "email": user['mail'],
                  "login": user['mail'].split("@")[0],
                  "password": faker.password(),
                  "registration_date": faker.date()
                  }
        clients.append(client)
    return json.dumps(clients, ensure_ascii=False, indent=4)   

def generate_file(tablename):
    global id
    name = file_mask.format(tablename, id, 
                            datetime.datetime.now().strftime(date_mask))
    return name

def main():
    global id
    if not os.path.exists('./data'):
        print("Нет доступа к папке для предачы файл в контейнер ДОСКЕРА!")
        return
    if not os.path.exists(dir):
        os.makedirs(dir)
    else:
        os.chdir(dir)
        if os.listdir():
            print("Удаление данных ...")
            for name in os.listdir():
                os.remove(name)
                print("Удален файл -", dir + name)
            print("Данные удалены!")
            print("=====================================")    
        os.chdir("../..")   
        
    while True:
        fname = generate_file(name_table)
        with open(dir + fname, "w", encoding='utf-8') as f:
            f.write(generate_json(10))
        print("Файл создан -", dir + fname)
        id += 1
        time.sleep(5)   


if __name__ == "__main__":
    main()