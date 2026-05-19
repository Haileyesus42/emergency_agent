from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from database.database import Base
from datetime import datetime

class EmergencyLog(Base):
    __tablename__ = "emergency_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    contact_id = Column(Integer, ForeignKey("emergency_contacts.id"), nullable=False)
    call_sid = Column(String)  # Vapi call ID
    call_status = Column(String)  # completed, failed, ringing, etc.
    signal_type = Column(String)  # sos button, panic, etc.
    emergency_context = Column(Text)  # JSON string of emergency context
    transcript = Column(Text)  # Transcript of the call if available
    call_duration = Column(Integer)  # Duration in seconds
    created_at = Column(DateTime, default=datetime.utcnow)