from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import sqlite3
import logging

# Create SQLite database
SQLALCHEMY_DATABASE_URL = "sqlite:///./emergency_system.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, 
    connect_args={"check_same_thread": False}  # Needed for SQLite
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def initialize_database():
    """Initialize database with proper schema"""
    # Drop all existing tables and recreate them (this will clear all data)
    Base.metadata.drop_all(bind=engine)
    
    # Create all tables according to models
    Base.metadata.create_all(bind=engine)
    
    # Then, check for missing columns and add them
    conn = sqlite3.connect('./emergency_system.db')
    cursor = conn.cursor()
    
    # Check and add missing columns to users table
    try:
        cursor.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in cursor.fetchall()]
        
        # Add current_location if it doesn't exist
        if 'current_location' not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN current_location TEXT")
            logging.info("Added current_location column to users table")
        
        # Add gps_latitude if it doesn't exist
        if 'gps_latitude' not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN gps_latitude TEXT")
            logging.info("Added gps_latitude column to users table")
        
        # Add gps_longitude if it doesn't exist
        if 'gps_longitude' not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN gps_longitude TEXT")
            logging.info("Added gps_longitude column to users table")
        
        conn.commit()
    except Exception as e:
        logging.error(f"Error updating database schema: {e}")
    finally:
        conn.close()