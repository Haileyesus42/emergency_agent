from sqlalchemy import Column, Integer, String, ForeignKey
from database.database import Base

class EmergencyContact(Base):
    __tablename__ = "emergency_contacts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    priority = Column(Integer, nullable=False)
    contact_name = Column(String, nullable=False)
    relationship = Column(String)
    phone = Column(String)
    whatsapp = Column(String)
