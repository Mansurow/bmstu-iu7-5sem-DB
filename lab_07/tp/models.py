from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, Integer, ForeignKey, Text, Numeric, CheckConstraint, Date, JSON
from sqlalchemy import PrimaryKeyConstraint

Base = declarative_base()

class Games(Base):
    __tablename__ = 'games'
    __table_args__ = {"schema": "tp"}
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
    type = Column(Text, nullable=False)
    developer = Column('developer', Integer, ForeignKey('tp.companies.id'))
    publisher = Column('publisher', Integer, ForeignKey('tp.companies.id'))
    req_age = Column(Integer, nullable=False)
    date_publish = Column(Date, nullable=False)
    number_copies = Column('number_copies', Integer, CheckConstraint("number_copies >= 0"),nullable=False)
    price = Column('price', Numeric, CheckConstraint("price >= 0"), nullable=False)

    developer_rel = relationship("Companies", foreign_keys=[developer])
    publisher_rel = relationship("Companies", foreign_keys=[publisher])

class Platforms(Base):
    __tablename__ = 'platforms'
    __table_args__ = {"schema": "tp"}
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
    manufacturerID = Column('manufacturer', Integer, ForeignKey('tp.companies.id'))
    type = Column(Text, nullable=False)
    year_production = Column(Integer, nullable=False)

    manufacturer = relationship("Companies", foreign_keys=[manufacturerID])

class Supports(Base):
    __tablename__ = 'supports'
    __table_args__ = (
        PrimaryKeyConstraint('gameid', 'platformid'),
        {"schema": "tp"}
    )

    gameID = Column('gameid', Integer, ForeignKey('tp.games.id', ondelete="CASCADE"))
    platformID = Column('platformid', Integer, ForeignKey('tp.platforms.id', ondelete="CASCADE"))

    game = relationship("Games", foreign_keys=[gameID])
    platform = relationship("Platforms", foreign_keys=[platformID])

class Genres(Base):
    __tablename__ = 'genres'
    __table_args__ = {"schema": "tp"}
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)

class Categories(Base):
    __tablename__ = 'categories'
    __table_args__ = (
        PrimaryKeyConstraint('gameid', 'genreid'),
        {"schema": "tp"}
    )

    gameID = Column('gameid', Integer, ForeignKey('tp.games.id', ondelete="CASCADE"))
    genreID = Column('genreid', Integer, ForeignKey('tp.genres.id', ondelete="CASCADE"))

    game = relationship("Games", foreign_keys=[gameID])
    genre = relationship("Genres", foreign_keys=[genreID])

class Clients(Base):
    __tablename__ = 'clients'
    __table_args__ = {"schema": "tp"}

    id = Column(Integer, primary_key=True)
    nick = Column(Text, nullable=False)
    surname = Column(Text, nullable=False)
    name = Column(Text, nullable=False)
    middle_name = Column(Text, nullable=False)
    address = Column(Text, nullable=False)
    sex = Column(Text, nullable=False)
    birthday = Column(Date, nullable=False)
    email = Column(Text)
    login = Column(Text)
    password = Column(Text, nullable=False)
    registration_date = Column(Date, nullable=False)

class Sales(Base):
    __tablename__ = 'sales'
    __table_args__ = (
        PrimaryKeyConstraint('gameid', 'clientid'),
        {"schema": "tp"}
    )

    gameID = Column('gameid', Integer, ForeignKey('tp.games.id', ondelete="CASCADE"))
    clientID = Column('clientid', Integer, ForeignKey('tp.clients.id', ondelete="CASCADE"))

    game = relationship("Games", foreign_keys=[gameID])
    client = relationship("Clients", foreign_keys=[clientID])

class Companies(Base):
    __tablename__ = 'companies'
    __table_args__ = {"schema": "tp"}
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
    country = Column(Text, nullable=False)
    city = Column(Text, nullable=False)
    sphere = Column(Text, nullable=False)
    type = Column(Integer, ForeignKey('tp.typies_company.id'), nullable=False)
    year_creation = Column(Integer, nullable=False)
    number_employees = Column('number_employees', Integer, CheckConstraint("number_employees >= 0"))
    url = Column(Text, nullable=False)

    typiescompany = relationship("TypiesCompany")

class TypiesCompany(Base):
    __tablename__  = 'typies_company'
    __table_args__ = {"schema": "tp"}
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
