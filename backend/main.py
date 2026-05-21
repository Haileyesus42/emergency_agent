from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
import sys
import os
import json

# Load environment variables from project root .env file
from dotenv import load_dotenv
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
env_path = os.path.join(project_root, '.env')
load_dotenv(dotenv_path=env_path)
print(f"✅ Loaded .env from: {env_path}")

# Add the backend directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database.database import engine, Base, SessionLocal, get_db, initialize_database
from models import user, emergency_contact, travel_history
from models.emergency_log import EmergencyLog  # Import the new model
from routes import auth_routes, user_routes, contact_routes
from services.user_service import create_mock_users
from services.contact_service import create_mock_emergency_contacts
from services.travel_service import create_mock_travel_history
from services.vapi_service import make_emergency_call
from services.emergency_log_service import create_emergency_log, update_emergency_log, get_emergency_log_by_call_sid

# Create FastAPI app
app = FastAPI(
    title="Umojee Emergency System",
    description="Emergency management system API",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_routes.router)
app.include_router(user_routes.router)
app.include_router(contact_routes.router)

# Serve static files (frontend)
frontend_path = os.path.join(os.path.dirname(__file__), '..', 'frontend')
if os.path.exists(frontend_path):
    app.mount("/static", StaticFiles(directory=frontend_path), name="static")
    
    # Serve index.html at root
    @app.get("/")
    def root():
        return FileResponse(os.path.join(frontend_path, 'index.html'))
    
    # Serve index.html explicitly
    @app.get("/index.html")
    def index():
        return FileResponse(os.path.join(frontend_path, 'index.html'))
    
    # Serve other HTML pages
    @app.get("/profile.html")
    def profile():
        return FileResponse(os.path.join(frontend_path, 'profile.html'))
    
    @app.get("/contacts.html")
    def contacts():
        return FileResponse(os.path.join(frontend_path, 'contacts.html'))

# Include the new model in the metadata for table creation
from models.emergency_log import EmergencyLog

# Initialize database and mock data on startup
@app.on_event("startup")
def startup_event():
    """Initialize database and create mock data"""
    # Initialize database with proper schema
    initialize_database()
    
    # Create mock data
    db = SessionLocal()
    try:
        create_mock_users(db)
        create_mock_emergency_contacts(db)
        create_mock_travel_history(db)
    finally:
        db.close()

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "healthy"}

# Endpoint to view emergency logs
@app.get("/emergency/logs")
def get_emergency_logs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Retrieve emergency call logs"""
    from models.emergency_log import EmergencyLog
    logs = db.query(EmergencyLog).offset(skip).limit(limit).all()
    return {"logs": logs, "total": len(logs)}

def generate_emergency_context(user, travel_records, contacts):
    """
    Generate a structured emergency context message using user and travel information
    """
    # Get the most recent travel record if available
    latest_travel = travel_records[0] if travel_records else None
    
    # Format emergency contacts
    contact_list = []
    for contact in contacts:
        contact_str = f"{contact.contact_name} ({contact.relationship}) - Phone: {contact.phone}"
        if contact.whatsapp:
            contact_str += f", WhatsApp: {contact.whatsapp}"
        contact_list.append(contact_str)
    
    # Create emergency context message
    emergency_context = f"""
================================================================================
                             EMERGENCY CONTEXT
================================================================================
Traveler Name: {user.full_name or user.username}
Current Location: {user.current_location or f'{user.current_city or "Unknown"}, {user.current_country or "Unknown"}'}
GPS Coordinates: {f'{user.gps_latitude}, {user.gps_longitude}' if user.gps_latitude and user.gps_longitude else 'Not available'}
Hotel/Address: {user.hotel_name or user.address or 'Not specified'}
Phone: {user.phone or 'Not available'}
Email: {user.email or 'Not available'}

TRAVEL DETAILS:
{f'Destination: {latest_travel.city}, {latest_travel.country}' if latest_travel else 'No travel details available'}
{f'Travel Date: {latest_travel.travel_date}' if latest_travel else ''}

EMERGENCY CONTACTS:
{os.linesep.join([f'- {contact}' for contact in contact_list]) if contact_list else 'No emergency contacts available'}

SOS SIGNAL:
Signal Type: {signal.signal if 'signal' in globals() else 'Not specified'}
Timestamp: {os.times().elapsed if hasattr(os, 'times') else 'Current time'}

Additional Information:
No additional notes available
================================================================================
"""
    return emergency_context

# Emergency webhook endpoint
class EmergencySignal(BaseModel):
    type: str
    user_name: str
    signal: str

@app.post("/emergency/webhook")
def emergency_webhook(signal: EmergencySignal):
    """Receive emergency signal from frontend"""
    print("\n" + "="*60)
    print("🚨 EMERGENCY SOS RECEIVED 🚨")
    print("="*60)
    print(f"Username: {signal.user_name}")
    print(f"Signal Type: {signal.signal}")
    print(f"Type: {signal.type}")
    print("="*60)
    
    db = SessionLocal()
    try:
        # Get user profile - try both username and full_name
        from models.user import User
        user = None
        
        # First try exact username match
        user = db.query(User).filter(User.username == signal.user_name).first()
        
        # If not found, try matching by full_name
        if not user:
            user = db.query(User).filter(User.full_name == signal.user_name).first()
        
        if user:
            print("\n📋 USER INFORMATION:")
            print("-" * 60)
            print(f"  ID: {user.id}")
            print(f"  Username: {user.username}")
            print(f"  Full Name: {user.full_name or 'N/A'}")
            print(f"  Address: {user.address or 'N/A'}")
            print(f"  Phone: {user.phone or 'N/A'}")
            print(f"  Email: {user.email or 'N/A'}")
            print(f"  Current City: {user.current_city or 'N/A'}")
            print(f"  Current Country: {user.current_country or 'N/A'}")
            print(f"  Hotel Name: {user.hotel_name or 'N/A'}")
            print(f"  Current Location: {user.current_location or 'N/A'}")
            print(f"  GPS: {user.gps_latitude or 'N/A'}, {user.gps_longitude or 'N/A'}")
            print("-" * 60)
            
            # Get emergency contacts ordered by priority
            from models.emergency_contact import EmergencyContact
            contacts = db.query(EmergencyContact).filter(
                EmergencyContact.user_id == user.id
            ).order_by(EmergencyContact.priority).all()
            
            if contacts:
                print("\n📞 EMERGENCY CONTACTS:")
                print("-" * 60)
                for contact in contacts:
                    print(f"\n  Priority {contact.priority}:")
                    print(f"    Name: {contact.contact_name}")
                    print(f"    Relationship: {contact.relationship or 'N/A'}")
                    print(f"    Phone: {contact.phone or 'N/A'}")
                    print(f"    WhatsApp: {contact.whatsapp or 'N/A'}")
                print("-" * 60)
                
                # Select the first priority contact for the emergency call
                primary_contact = contacts[0]  # First priority contact
                
                # Create emergency context dictionary for Vapi
                emergency_context_dict = {
                    "traveler_name": user.full_name or user.username,
                    "current_location": user.current_location or f"{user.current_city or 'Unknown'}, {user.current_country or 'Unknown'}",
                    "gps": f"{user.gps_latitude}, {user.gps_longitude}" if user.gps_latitude and user.gps_longitude else "Not available",
                    "hotel": user.hotel_name or user.address or "Not specified",
                    "traveler_phone": user.phone or "Not available",
                    "signal_type": signal.signal,
                    "contact_name": primary_contact.contact_name,
                    "relationship": primary_contact.relationship or "Unknown",
                    "contact_phone": primary_contact.phone  # Add contact phone for WhatsApp fallback
                }
                
                print(f"\n📱 INITIATING EMERGENCY CALL TO: {primary_contact.contact_name} ({primary_contact.relationship})")
                print(f"   Phone: {primary_contact.phone}")
                print(f"   Priority: {primary_contact.priority}")
                print(f"   Emergency Context Sent to Vapi: {emergency_context_dict}")
                
                # Make the emergency call via Vapi
                vapi_response = make_emergency_call(primary_contact.phone, emergency_context_dict)
                
                if vapi_response:
                    print(f"\n✅ EMERGENCY CALL INITIATED SUCCESSFULLY")
                    print(f"   Vapi Call ID: {vapi_response.get('id', 'unknown')}")
                    print(f"   Vapi Call Status: {vapi_response.get('status', 'unknown')}")
                    
                    # Log the emergency call attempt using the service
                    emergency_log = create_emergency_log(
                        db=db,
                        user_id=user.id,
                        contact_id=primary_contact.id,
                        call_sid=vapi_response.get('id'),
                        signal_type=signal.signal,
                        emergency_context=emergency_context_dict
                    )
                    
                    print(f"   Call logged in emergency logs with ID: {emergency_log.id}")
                else:
                    print(f"\n❌ FAILED TO INITIATE EMERGENCY CALL")
            else:
                print("\n⚠️  No emergency contacts found")
            
            # Get travel history
            from models.travel_history import TravelHistory
            travel_records = db.query(TravelHistory).filter(
                TravelHistory.user_id == user.id
            ).all()
            
            if travel_records:
                print("\n✈️  TRAVEL HISTORY:")
                print("-" * 60)
                for record in travel_records:
                    print(f"\n  Date: {record.travel_date}")
                    print(f"    From: {record.city}, {record.country}")  # Using available fields
                    print(f"    To: N/A (field not available)")          # Field doesn't exist
                    print(f"    Purpose: N/A (field not available)")      # Field doesn't exist
                print("-" * 60)
            else:
                print("\n⚠️  No travel history found")
                
            # Generate and print the emergency context
            emergency_context = generate_emergency_context(user, travel_records, contacts)
            print(emergency_context)
        else:
            print(f"\n❌ User '{signal.user_name}' not found in database")
            print(f"   Available users: haile, traveler1")
        
        print("="*60 + "\n")
        
        return {
            "status": "success",
            "message": "Emergency signal received and data retrieved",
            "user_found": user is not None
        }
        
    except Exception as e:
        print(f"\n❌ Error retrieving data: {str(e)}\n")
        return {
            "status": "error",
            "message": str(e)
        }
    finally:
        db.close()

# Add Vapi webhook endpoint to handle call events
@app.post("/vapi/webhook")
async def vapi_webhook(request: Request):
    """Handle incoming webhooks from Vapi"""
    import json
    from fastapi import Request
    
    # Get the raw body for logging purposes
    body = await request.body()
    payload = json.loads(body.decode('utf-8'))
    
    # Extract message data - Vapi wraps everything in 'message' field
    message = payload.get('message', {})
    
    # Determine event type from message.type
    event_type = message.get('type', 'unknown')
    
    # Extract call information - it's nested inside message.call
    call_data = message.get('call', {})
    call_id = call_data.get('id', 'unknown')
    call_status = message.get('status') or call_data.get('status')
    ended_reason = message.get('endedReason')
    
    print(f"\n🔔 VAPI WEBHOOK RECEIVED:")
    print(f"Event Type: {event_type}")
    print(f"Call ID: {call_id}")
    print(f"Call Status: {call_status}")
    if ended_reason:
        print(f"Ended Reason: {ended_reason}")
    
    # Determine if call was answered based on endedReason
    call_answered = None
    if ended_reason:
        # Common Vapi endedReason values:
        # - "customer-did-not-answer" = NOT answered
        # - "assistant-error" = NOT answered (technical issue)
        # - "normal-call-disconnect" = WAS answered and completed normally
        # - "busy" = NOT answered (line busy)
        # - "no-answer" = NOT answered
        
        answered_reasons = ['normal-call-disconnect', 'completed', 'answered']
        not_answered_reasons = ['customer-did-not-answer', 'busy', 'no-answer', 'assistant-error', 'timeout']
        
        ended_normalized = ended_reason.lower().replace('-', '_')
        if ended_normalized in [r.replace('-', '_') for r in answered_reasons]:
            call_answered = True
            print(f"✅ Call WAS ANSWERED")
        elif ended_normalized in [r.replace('-', '_') for r in not_answered_reasons]:
            call_answered = False
            print(f"❌ Call was NOT ANSWERED")
    
    # Process different types of events
    db = SessionLocal()
    try:
        if event_type in ['status-update', 'end-of-call-report'] and call_id != 'unknown':
            # Handle call status updates and end reports
            
            # Find the corresponding emergency log entry using the service
            emergency_log = get_emergency_log_by_call_sid(db, call_id)
            
            if emergency_log:
                # Update the log with call details
                update_kwargs = {'call_status': call_status}
                
                # Add duration if available (from end-of-call-report)
                if message.get('durationSeconds'):
                    update_kwargs['call_duration'] = message.get('durationSeconds')
                
                updated_log = update_emergency_log(db, emergency_log.id, **update_kwargs)
                
                # Extract transcript if available (from end-of-call-report)
                transcript = message.get('transcript') or call_data.get('transcript')
                if transcript:
                    update_emergency_log(db, emergency_log.id, transcript=transcript)
                
                # Log whether call was answered
                if call_answered is not None:
                    answer_status = "ANSWERED ✅" if call_answered else "NOT ANSWERED ❌"
                    print(f"📞 Call Answer Status: {answer_status}")
                    
                    # If call was NOT answered, send WhatsApp fallback
                    if call_answered == False:
                        print(f"\n🚨 CALL NOT ANSWERED - TRIGGERING WHATSAPP FALLBACK")
                        
                        # Parse emergency context to get contact info
                        import json as json_module
                        try:
                            # Handle both JSON string and dict formats
                            context = emergency_log.emergency_context
                            if isinstance(context, str):
                                context = json_module.loads(context)
                            elif isinstance(context, dict):
                                pass  # Already a dict
                            else:
                                context = {}
                            
                            # Extract contact phone with fallback
                            contact_phone = (
                                context.get('contact_phone') or 
                                context.get('phone') or 
                                ''
                            )
                            
                            if not contact_phone:
                                print(f"⚠️  WARNING: No contact phone found in emergency context!")
                                print(f"   Available keys: {list(context.keys())}")
                            
                            # Send WhatsApp to the emergency contact
                            from services.whatsapp_service import send_emergency_whatsapp
                            
                            whatsapp_result = send_emergency_whatsapp(
                                contact_name=context.get('contact_name', 'Emergency Contact'),
                                relationship=context.get('relationship', 'Unknown'),
                                phone=contact_phone,
                                traveler_name=context.get('traveler_name', 'Unknown'),
                                location=context.get('current_location', 'Unknown'),
                                gps=context.get('gps', 'Unknown'),
                                hotel=context.get('hotel', 'Unknown'),
                                signal_type=context.get('signal_type', 'SOS_BUTTON')
                            )
                            
                            if whatsapp_result['success']:
                                print(f"✅ WhatsApp fallback sent successfully!")
                                print(f"   Message SID: {whatsapp_result.get('message_sid')}")
                            else:
                                print(f"❌ WhatsApp fallback failed: {whatsapp_result.get('error')}")
                                
                        except Exception as e:
                            print(f"❌ Error sending WhatsApp fallback: {str(e)}")
                            import traceback
                            traceback.print_exc()
                
                print(f"✅ Emergency log updated for call {call_id} - Status: {call_status}")
            else:
                print(f"⚠️  No matching emergency log found for call {call_id}")
                
        else:
            print(f"ℹ️  Unhandled event type: {event_type}")
            
        return {"status": "received"}
        
    except Exception as e:
        print(f"❌ Error processing webhook: {str(e)}")
        import traceback
        traceback.print_exc()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)