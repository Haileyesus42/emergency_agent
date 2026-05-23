#!/usr/bin/env python3
"""
Test Vapi API connectivity and credentials
"""
import os
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

print("=" * 60)
print("VAPI API CONNECTIVITY TEST")
print("=" * 60)

# Check credentials
api_key = os.getenv('VAPI_API_KEY')
assistant_id = os.getenv('VAPI_ASSISTANT_ID')
phone_number_id = os.getenv('VAPI_PHONE_NUMBER_ID')

print(f"\n1. Checking credentials...")
print(f"   API Key: {'✅ Found' if api_key else '❌ Missing'}")
print(f"   Assistant ID: {'✅ Found' if assistant_id else '❌ Missing'}")
print(f"   Phone Number ID: {'✅ Found' if phone_number_id else '❌ Missing'}")

if not all([api_key, assistant_id, phone_number_id]):
    print("\n❌ ERROR: Missing credentials in .env file")
    exit(1)

# Test API connectivity
print(f"\n2. Testing API endpoint connectivity...")
try:
    response = requests.get('https://api.vapi.ai', timeout=10)
    print(f"   ✅ API endpoint reachable (Status: {response.status_code})")
except Exception as e:
    print(f"   ❌ Cannot reach API endpoint: {e}")
    exit(1)

# Test authentication by listing assistants
print(f"\n3. Testing authentication (listing assistants)...")
try:
    headers = {
        'Authorization': f'Bearer {api_key}'
    }
    response = requests.get(
        'https://api.vapi.ai/assistant',
        headers=headers,
        timeout=15
    )
    
    print(f"   Status Code: {response.status_code}")
    
    if response.status_code == 200:
        print(f"   ✅ Authentication successful!")
        assistants = response.json()
        print(f"   Found {len(assistants)} assistant(s)")
        
        # Check if our assistant exists
        for assistant in assistants:
            if assistant.get('id') == assistant_id:
                print(f"   ✅ Assistant ID '{assistant_id}' found!")
                print(f"      Name: {assistant.get('name', 'N/A')}")
                break
        else:
            print(f"   ⚠️  Assistant ID '{assistant_id}' NOT found in your account")
            print(f"      Available assistants:")
            for a in assistants:
                print(f"        - {a.get('id')}: {a.get('name', 'N/A')}")
    elif response.status_code == 401:
        print(f"   ❌ Authentication failed - Invalid API key")
    elif response.status_code == 403:
        print(f"   ❌ Access forbidden - Check API key permissions")
    else:
        print(f"   ⚠️  Unexpected status: {response.status_code}")
        print(f"   Response: {response.text[:200]}")
        
except Exception as e:
    print(f"   ❌ Error testing authentication: {e}")
    import traceback
    traceback.print_exc()

# Test phone number
print(f"\n4. Testing phone number configuration...")
try:
    response = requests.get(
        'https://api.vapi.ai/phone-number',
        headers={'Authorization': f'Bearer {api_key}'},
        timeout=15
    )
    
    if response.status_code == 200:
        phone_numbers = response.json()
        print(f"   Found {len(phone_numbers)} phone number(s)")
        
        for pn in phone_numbers:
            if pn.get('id') == phone_number_id:
                print(f"   ✅ Phone Number ID '{phone_number_id}' found!")
                print(f"      Number: {pn.get('number', 'N/A')}")
                print(f"      Provider: {pn.get('provider', 'N/A')}")
                break
        else:
            print(f"   ⚠️  Phone Number ID '{phone_number_id}' NOT found")
            print(f"      Available phone numbers:")
            for pn in phone_numbers:
                print(f"        - {pn.get('id')}: {pn.get('number', 'N/A')}")
    else:
        print(f"   ⚠️  Could not verify phone number (Status: {response.status_code})")
        
except Exception as e:
    print(f"   ❌ Error checking phone number: {e}")

print("\n" + "=" * 60)
print("TEST COMPLETE")
print("=" * 60)
