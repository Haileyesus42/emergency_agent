import requests
import json

def test_webhook_endpoint():
    """
    Test script to simulate Vapi webhook calls to test the endpoint
    """
    # Example payloads for different call events
    test_payloads = [
        {
            "type": "call-ended",
            "call": {
                "id": "019e2bb4-74c9-7bb5-9ff7-691f2237b0e2",
                "status": "finished-cause-hangup",
                "durationSeconds": 45,
                "metadata": {
                    "user_id": 1,
                    "contact_id": 1,
                    "contact_phone": "+251949867668",
                    "traveler_name": "Haile Selassie",
                    "current_location": "Bale Mountains National Park",
                    "signal_type": "SOS_BUTTON"
                }
            }
        },
        {
            "type": "callee-input",
            "call": {
                "id": "019e2bb4-74c9-7bb5-9ff7-691f2237b0e2",
                "status": "in-progress",
                "metadata": {
                    "user_id": 1,
                    "contact_id": 1,
                    "contact_phone": "+251949867668",
                    "traveler_name": "Haile Selassie",
                    "current_location": "Bale Mountains National Park",
                    "signal_type": "SOS_BUTTON"
                }
            }
        },
        {
            "type": "call-started",
            "call": {
                "id": "019e2bb4-74c9-7bb5-9ff7-691f2237b0e2",
                "status": "in-progress",
                "metadata": {
                    "user_id": 1,
                    "contact_id": 1,
                    "contact_phone": "+251949867668",
                    "traveler_name": "Haile Selassie",
                    "current_location": "Bale Mountains National Park",
                    "signal_type": "SOS_BUTTON"
                }
            }
        }
    ]

    # Local webhook endpoint
    webhook_url = "http://localhost:8000/vapi/webhook"
    
    for i, payload in enumerate(test_payloads, 1):
        print(f"Sending test payload {i} to webhook endpoint...")
        print(f"Payload: {json.dumps(payload, indent=2)}")
        
        try:
            response = requests.post(
                webhook_url,
                json=payload,
                headers={"Content-Type": "application/json"}
            )
            
            print(f"Response status: {response.status_code}")
            print(f"Response: {response.text}")
            print("-" * 50)
        except Exception as e:
            print(f"Error sending request: {str(e)}")
            print("-" * 50)


if __name__ == "__main__":
    print("Testing Vapi webhook endpoint...")
    test_webhook_endpoint()
    print("Test completed!")