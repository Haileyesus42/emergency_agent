from database.database import Base, engine

# Import all models to ensure they are registered
from models.user import User
from models.emergency_contact import EmergencyContact
from models.travel_history import TravelHistory

def init_db():
    """Initialize database by creating all tables"""
    Base.metadata.create_all(bind=engine)
