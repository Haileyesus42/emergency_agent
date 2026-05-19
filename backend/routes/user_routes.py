from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.database import get_db
from schemas.schemas import UserResponse, UserUpdate
from routes.auth_routes import get_current_user
from models.user import User

router = APIRouter(prefix="/user", tags=["User"])

@router.get("/profile")
def get_profile(
    token: str,
    db: Session = Depends(get_db)
):
    """Get current user profile"""
    user = get_current_user(token, db)
    
    return {
        "id": user.id,
        "username": user.username,
        "full_name": user.full_name,
        "address": user.address,
        "phone": user.phone,
        "email": user.email,
        "current_city": user.current_city,
        "current_country": user.current_country,
        "hotel_name": user.hotel_name,
        "current_location": user.current_location,
        "gps_latitude": user.gps_latitude,
        "gps_longitude": user.gps_longitude
    }

@router.put("/profile")
def update_profile(
    profile_data: UserUpdate,
    token: str,
    db: Session = Depends(get_db)
):
    """Update user profile"""
    user = get_current_user(token, db)
    
    # Update fields if provided
    if profile_data.full_name is not None:
        user.full_name = profile_data.full_name
    if profile_data.address is not None:
        user.address = profile_data.address
    if profile_data.phone is not None:
        user.phone = profile_data.phone
    if profile_data.email is not None:
        user.email = profile_data.email
    if profile_data.current_city is not None:
        user.current_city = profile_data.current_city
    if profile_data.current_country is not None:
        user.current_country = profile_data.current_country
    if profile_data.hotel_name is not None:
        user.hotel_name = profile_data.hotel_name
    if profile_data.current_location is not None:
        user.current_location = profile_data.current_location
    if profile_data.gps_latitude is not None:
        user.gps_latitude = profile_data.gps_latitude
    if profile_data.gps_longitude is not None:
        user.gps_longitude = profile_data.gps_longitude
    
    db.commit()
    db.refresh(user)
    
    return {
        "message": "Profile updated successfully",
        "user": {
            "id": user.id,
            "username": user.username,
            "full_name": user.full_name,
            "address": user.address,
            "phone": user.phone,
            "email": user.email,
            "current_city": user.current_city,
            "current_country": user.current_country,
            "hotel_name": user.hotel_name,
            "current_location": user.current_location,
            "gps_latitude": user.gps_latitude,
            "gps_longitude": user.gps_longitude
        }
    }