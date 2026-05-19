from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.database import get_db
from schemas.schemas import EmergencyContactResponse, EmergencyContactUpdate
from routes.auth_routes import get_current_user
from services.contact_service import get_emergency_contacts, update_emergency_contacts

router = APIRouter(prefix="/user/emergency-contacts", tags=["Emergency Contacts"])

@router.get("/", response_model=list[EmergencyContactResponse])
def get_contacts(
    token: str,
    db: Session = Depends(get_db)
):
    """Get emergency contacts for logged-in user"""
    user = get_current_user(token, db)
    contacts = get_emergency_contacts(db, user.id)
    return contacts

@router.put("/")
def update_contacts(
    contacts_data: EmergencyContactUpdate,
    token: str,
    db: Session = Depends(get_db)
):
    """Update emergency contacts for logged-in user"""
    user = get_current_user(token, db)
    
    updated_contacts = update_emergency_contacts(
        db, 
        user.id, 
        contacts_data.contacts
    )
    
    return {
        "message": "Emergency contacts updated successfully",
        "contacts": [
            {
                "id": contact.id,
                "priority": contact.priority,
                "contact_name": contact.contact_name,
                "relationship": contact.relationship,
                "phone": contact.phone,
                "whatsapp": contact.whatsapp
            }
            for contact in updated_contacts
        ]
    }
