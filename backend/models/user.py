from sqlalchemy import Column, Integer, String
from database.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    address = Column(String)
    phone = Column(String)
    email = Column(String)
    current_city = Column(String)
    current_country = Column(String)
    hotel_name = Column(String)
    current_location = Column(String)
    gps_latitude = Column(String)
    gps_longitude = Column(String)