import time
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, Integer, ForeignKey, Text, Time, CheckConstraint, Date

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