from operator import and_
import time

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from json import dumps, load

from models import *
from sqlalchemy import func, select, insert, delete, update

## Найти все отделы, в которых работает более 10 сотрудников.
def get_departmant_sql(session):
    res = session.execute("select department from staff group by department having count(*) > 10;")
    return res.fetchall()
def get_departmant(session):
    return [row.department for row in
            session.query(Staff.department).group_by(Staff.department).having(func.count("*") > 10)]

## Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
def get_staff_not_get_out_sql(session, date):
    res = session.execute(f"""
    Select s.id, s.fio from staff as s
    join (Select idstaff, date, count(*) as count from staff_track
        group by idstaff, date
        order by idstaff, date) as st on st.idstaff = s.id
    where st.date = '{date}' and st.count = 2;
    """)
    return res.fetchall()
def get_staff_not_get_out(session, date):
    st = session.query(StaffTrack.idstaff, 
                       StaffTrack.date, 
                       func.count("*").label('count')
                       ).group_by(StaffTrack.idstaff, StaffTrack.date
                       ).order_by(StaffTrack.idstaff, StaffTrack.date
                       ).subquery('st')
    # print(session.query(Staff.id, Staff.fio).join(st).filter(st.c.idstaff == Staff.id
    #         ).where(and_(st.c.date == date, st.c.count == 2)))
    return [row for row in
            session.query(Staff.id, Staff.fio).join(st).filter(st.c.idstaff == Staff.id
            ).where(and_(st.c.date == date, st.c.count == 2))]

## Найти отделы, в которых нет сотрудников моложе 25 лет
def get_department_25_sql(session):
    res = session.execute("""
    Select s.department from staff as s
    where s.department not in (
        Select department
        from staff
        where date_part('year', current_date) - date_part('year', birthday) < 25
    )
    GROUP BY s.department;
    """)
    return res.fetchall()
def get_department_25(session):
    dp = session.query(Staff.department).where(
                        func.date_part('year', func.current_date()) - func.date_part('year', Staff.birthday) < 25
                        ).subquery()
    return [row.department for row in
            session.query(Staff.department).where(
                Staff.department.not_in(dp)
                ).group_by(Staff.department)]

## Найти сотрудника, который пришел на работу раньше всех
def get_staff_come_earlier_sql(session):
    res = session.execute("""
    Select s.id, s.fio from staff as s
    join staff_track as st on st.idstaff = s.id
    where st.date = current_date -- '2018-12-14' 
    and st.time = (
        Select MIN(time) from staff_track
        where date = current_date); -- '2018-12-14'
    """)
    return res.fetchall()
def get_staff_come_earlier(session):
    che = session.query(func.MIN(StaffTrack.time).label("min_hour")
                       ).where(StaffTrack.date == func.current_date()).scalar_subquery() 
    return [row.fio for row in
            session.query(Staff.fio).join(StaffTrack).where(and_(StaffTrack.date == func.current_date(), StaffTrack.time == (che)))]

## Найти сотрудников опоздавших не менее 5 раз
def gat_staff_late_5_sql(session):
    res = session.execute("""
    with late(id, count) as (
        Select l.idstaff as id, count(l.idstaff) as count
        from (Select idstaff, date, MIN(time) from staff_track
            where type = 1
            GROUP BY idstaff, date) as l
        GROUP BY l.idstaff
    )
    Select s.fio from late
    join staff as s on s.id = late.id
    where late.count >= 5
    """)
    return [res.fetchall()[0][0]]
def gat_staff_late_5(session):
    time_come = session.query(StaffTrack.idstaff,
                              StaffTrack.date,
                              func.min(StaffTrack.time).label("min")
                       ).where(StaffTrack.type == 1
                       ).group_by(
                        StaffTrack.idstaff, StaffTrack.date
                       ).subquery("l")

    late = session.query(time_come.c.idstaff.label("id"),
                         func.count(time_come.c.idstaff).label('count')
                        ).group_by (
                            time_come.c.idstaff 
                        ).subquery()
    return [row.fio for row in
                session.query(Staff.fio).join(late).filter
                (late.c.id == Staff.id).where(late.c.count >= 5)]


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

    # Запуск запроса
    res = gat_staff_late_5(sesssion_con)
    print(res) 

if __name__ == "__main__":
    main()      