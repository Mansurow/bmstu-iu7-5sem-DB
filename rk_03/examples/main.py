import time

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from json import dumps, load

from models import *
from sqlalchemy import func, select, insert, delete, update


# На уровне БД
def get_departmant_sql(session):
    ## Найти все отделы, в которых работает более 10 сотрудников.
    res = session.execute("select department from staff group by department having count(*) > 10;")
    return res.fetchall()
# Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
def get_staff():
    print

# На уровне Приложения
def get_departmant(session):
    ## Найти все отделы, в которых работает более 10 сотрудников.
    return [row.department for row in
            session.query(Staff.department).group_by(Staff.department).having(func.count("*") > 10)]

def main():
    engine = create_engine(
        f'postgresql://postgres:postgres@localhost:5555/rk3',
        pool_pre_ping=True)
    try:
        engine.connect()
        print("БД к базе rk3 успешно подключена!")
    except:
        print("Ошибка соединения к БД!")
        return

    Session = sessionmaker(bind=engine)
    sesssion_con = Session()
    res = get_departmant(sesssion_con)
    print(res)  

if __name__ == "__main__":
    main()      