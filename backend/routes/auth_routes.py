from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.database import get_db
from schemas.schemas import UserLogin, UserResponse
from services.user_service import authenticate_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Simple session storage (in production, use JWT or proper session management)
active_sessions = {}

@router.post("/login")
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    """Login with username and password"""
    user = authenticate_user(db, login_data.username, login_data.password)
    
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )
    
    # Create a simple session token (for prototype, use username as token)
    token = f"session_{user.id}"
    active_sessions[token] = user.id
    
    return {
        "message": "Login successful",
        "token": token,
        "user": {
            "id": user.id,
            "username": user.username,
            "full_name": user.full_name,
            "address": user.address,
            "phone": user.phone,
            "email": user.email,
            "current_city": user.current_city,
            "current_country": user.current_country,
            "hotel_name": user.hotel_name
        }
    }

@router.post("/logout")
def logout(token: str):
    """Logout and clear session"""
    if token in active_sessions:
        del active_sessions[token]
    
    return {"message": "Logout successful"}

def get_current_user(token: str, db: Session = Depends(get_db)):
    """Get current user from session token"""
    if token not in active_sessions:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    user_id = active_sessions[token]
    from models.user import User
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user
