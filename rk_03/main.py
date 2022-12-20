import time
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, Integer, ForeignKey, Text, Time, CheckConstraint, Date
from sqlalchemy import func

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from operator import and_

Base = declarative_base()

DAYS_CONSTRAINT = \
    "('Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье')"

class Staff(Base):
    __tablename__ = 'staff'
    id = Column(Integer, primary_key=True,  autoincrement=True)
    fio = Column(Text, nullable=False)
    birthday = Column(Date, default=time.time())
    department = Column(Text)



class TypeTrack(Base):
    __tablename__ = 'type_track'
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)


class StaffTrack(Base):
    __tablename__ = 'staff_track'
    id = Column(Integer, primary_key=True)
    idstaff = Column(Integer, ForeignKey("staff.id"), nullable=False)
    date = Column(Date, default=time.time())
    dayofweek = Column(Text, CheckConstraint(f"days in {DAYS_CONSTRAINT}"), nullable=False)
    time = Column("time", Time, default=time.time())
    type = Column("type", Integer, CheckConstraint("type = 1 or type = 2"), ForeignKey("type_track.id"))

    staff_fk = relationship("Staff", foreign_keys=[idstaff])
    type_fk = relationship("TypeTrack", foreign_keys=[type])

# Зарос 1 --- Задания 2
# 1. Найти самого старшего сотрудника в бухгалтерии.
def get_oldest_emp_b_sql(session):
    res = session.execute(f"""
        with ages(id, age) as (
            Select id,
                date_part('year', current_date) - date_part('year', birthday) as age
            from staff
            where department = 'Бухгалтерия'
        )
        Select s1.id, s1.fio
        from staff as s1
        join ages as s2 on s1.id = s2.id
        where s2.age = (Select MIN(age) from ages);
    """)
    return res.fetchall()
def get_oldest_emp_b(session):
    ages = session.query(Staff.id, 
                        (func.date_part('year', func.current_date()) - func.date_part('year', Staff.birthday)).label('age')
                        ).where(Staff.department == 'Бухгалтерия').subquery('ages')

    min_age = session.query(func.min(ages.c.age)).scalar_subquery()
    query = session.query(Staff.id, Staff.fio).select_from(ages).filter(ages.c.id == Staff.id).where(ages.c.age == (min_age))               
    return [row for row in query]                   

# Запрос 2 -- Задание 2
# 2. Найти сотрудников, выходивших больше 3-х раз с рабочего места.
def get_emp_3_late_sql(session):
    res = session.execute(f"""
        with count_out(id, date, out) as (
            Select idstaff as id, date, count(*) as out
            from staff_track
            where type = 2
            GROUP BY idstaff, date
        )
        SELECT s.id, s.fio from staff as s
        join count_out as co on co.id = s.id
        where co.out > 3;
    """)
    return res.fetchall()
def get_emp_3_late(session):
    count_out = session.query(StaffTrack.idstaff.label('id'), 
                         StaffTrack.date,
                         func.count("*").label('out')
                        ).where(
                            StaffTrack.type == 2
                        ).group_by (
                            StaffTrack.idstaff,
                            StaffTrack.date
                        ).subquery('count_out')

    query = session.query(Staff.id, Staff.fio).join(count_out).filter(count_out.c.id == Staff.id).where(count_out.c.out > 3)               
    return [row for row in query]   

# Запрос 3 -- Задание 2
# 3. Найти сотрудника, который пришел сегодня последним.
def get_emp_come_last_sql(session):
    res = session.execute(f"""
        Select s.id, s.fio from staff as s
        join staff_track as st on st.idstaff = s.id
        where st.date = current_date -- '2018-12-14' 
        and st.time = (
            Select MAX(time) from staff_track
            where date = current_date  -- '2018-12-14'
            and type = 1);
    """)
    return res.fetchall()
def get_emp_come_last(session):
    max_time_come = session.query(
                         func.max(StaffTrack.time)
                        ).where(and_(
                            StaffTrack.date == func.current_date(),
                            StaffTrack.type == 1
                            )
                        ).scalar_subquery()
    query = session.query(Staff.id, Staff.fio).join(StaffTrack).where(and_(
                                                        StaffTrack.date == func.current_date(),
                                                        StaffTrack.time == (max_time_come)
                                                    ))               
    return [row for row in query]                     

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

    menu = """ 
        \t1. Найти самого старшего сотрудника в бухгалтерии.
        \t2. Найти сотрудников, выходивших больше 3-х раз с рабочего места.
        \t3. Найти сотрудника, который пришел сегодня последним.
        \t0. Выход.\n
    """

    while(True):
        print(menu)
        c = int(input("\tВыбор: "))
        if (c == 0):
            break
        elif (c == 1):
            print("Запрос со стороны БД: ")
            res = get_oldest_emp_b_sql(sesssion_con)
            print("Результат:\n", res)
            print("Запрос со стороны Приложения: ")
            res = get_oldest_emp_b(sesssion_con)
            print("Результат:\n", res)
        elif (c == 2):
            print("Запрос co стороны БД: ")
            res = get_emp_3_late_sql(sesssion_con)
            print("Результат:\n", res)
            print("Запрос co стороны Приложения: ")
            res = get_emp_3_late(sesssion_con)
            print("Результат:\n", res)
        elif (c == 2):
            print("Запрос co стороны БД: ")
            res = get_emp_come_last_sql(sesssion_con)
            print("Результат:\n", res)
            print("Запрос co стороны Приложения: ")
            res = get_emp_come_last(sesssion_con)
            print("Результат:\n", res)       

if __name__ == "__main__":
    main()          