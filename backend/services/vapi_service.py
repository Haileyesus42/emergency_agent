import os
import requests
import logging
from typing import Dict, Any, Optional
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

VAPI_BASE_URL = "https://api.vapi.ai"


class VapiService:
    def __init__(self):
        self.api_key = os.getenv("VAPI_API_KEY")
        self.assistant_id = os.getenv("VAPI_ASSISTANT_ID")
        self.phone_number_id = os.getenv("VAPI_PHONE_NUMBER_ID")

        # Validate environment variables
        if not self.api_key:
            logger.warning("VAPI_API_KEY environment variable is not set")

        if not self.assistant_id:
            logger.warning("VAPI_ASSISTANT_ID environment variable is not set")

        if not self.phone_number_id:
            logger.warning("VAPI_PHONE_NUMBER_ID environment variable is not set")

    def make_emergency_call(
        self,
        phone_number: str,
        emergency_context: Dict[str, Any]
    ) -> Optional[Dict[str, Any]]:
        """
        Makes an outbound emergency call using Vapi API.

        Args:
            phone_number: Destination phone number
            emergency_context: Emergency metadata/context

        Returns:
            Dict response from Vapi or None
        """

        # Validate required configuration
        if not all([
            self.api_key,
            self.assistant_id,
            self.phone_number_id
        ]):
            logger.error("Missing Vapi configuration.")
            return {
                "status": "failed",
                "message": "Missing Vapi environment configuration"
            }

        # Updated Vapi endpoint for phone calls
        url = f"{VAPI_BASE_URL}/call/phone"

        # Headers
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        # Payload with metadata only
        payload = {
            "assistantId": self.assistant_id,
            "phoneNumberId": self.phone_number_id,
            "customer": {
                "number": phone_number
            },
            "metadata": emergency_context
        }

        try:
            logger.info("========================================")
            logger.info("INITIATING VAPI EMERGENCY CALL")
            logger.info("========================================")
            logger.info(f"Destination Number: {phone_number}")
            logger.info(f"Assistant ID: {self.assistant_id}")
            logger.info(f"Phone Number ID: {self.phone_number_id}")
            logger.info(f"Emergency Context: {emergency_context}")
            logger.info(f"Payload: {payload}")

            response = requests.post(
                url,
                json=payload,
                headers=headers,
                timeout=30
            )

            logger.info("========================================")
            logger.info(f"VAPI STATUS CODE: {response.status_code}")
            logger.info(f"VAPI RESPONSE: {response.text}")
            logger.info("========================================")

            # Success
            if response.status_code in [200, 201]:
                result = response.json()
                logger.info(
                    f"Emergency call initiated successfully. "
                    f"Call ID: {result.get('id', 'unknown')}"
                )
                return result
            else:
                logger.error(
                    f"Failed to initiate emergency call. "
                    f"Status: {response.status_code}, Response: {response.text}"
                )
                return None

        except requests.exceptions.RequestException as e:
            logger.error(f"Error making emergency call: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error making emergency call: {str(e)}")
            return None


# Global singleton instance
try:
    vapi_service = VapiService()

except Exception as e:
    logger.exception(f"Error initializing VapiService: {e}")
    vapi_service = None


def make_emergency_call(
    phone_number: str,
    emergency_context: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """
    Wrapper function for emergency calling
    """

    if not vapi_service:
        logger.error("VapiService is not initialized")

        return {
            "status": "failed",
            "message": "VapiService not initialized"
        }

    return vapi_service.make_emergency_call(
        phone_number,
        emergency_context
    )