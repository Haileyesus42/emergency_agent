from .user_service import *
from .contact_service import *
from .travel_service import *
from .emergency_log_service import *

# Import Vapi service separately to handle potential errors
try:
    from .vapi_service import *
except ImportError as e:
    print(f"Warning: Could not import Vapi service: {e}")
    # Define a dummy function if import fails
    def make_emergency_call(phone_number: str, emergency_context: dict):
        print("Vapi service not available. Would make emergency call to:", phone_number)
        return None

# Import WhatsApp service separately to handle potential errors
try:
    from .whatsapp_service import *
except ImportError as e:
    print(f"Warning: Could not import WhatsApp service: {e}")