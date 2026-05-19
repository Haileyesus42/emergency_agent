from sqlalchemy import Column, Integer, String, ForeignKey
from database.database import Base

class TravelHistory(Base):
    __tablename__ = "travel_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    country = Column(String, nullable=False)
    city = Column(String, nullable=False)
    travel_date = Column(String)
