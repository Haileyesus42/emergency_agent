# Vapi API Timeout Troubleshooting Guide

## Problem
Vapi API calls are timing out with error:
```
HTTPSConnectionPool(host='api.vapi.ai', port=443): Read timed out. (read timeout=60)
```

## Diagnosis Results

✅ **Credentials are valid** - API key, Assistant ID, and Phone Number ID all verified  
✅ **API endpoint is reachable** - GET requests work fine  
✅ **Configuration is correct** - All settings properly loaded from .env  

❌ **POST requests timeout** - Call initiation endpoint not responding within timeout period

## Root Cause

The Vapi API's `/call/phone` endpoint is **not responding within the timeout period** from your location. This could be due to:

1. **Network latency** from Ethiopia to Vapi servers (likely US-based)
2. **Firewall/proxy** slowing down or blocking POST requests
3. **Vapi API server load** causing slow response times
4. **ISP routing issues** to api.vapi.ai

## Solutions Implemented

### 1. Retry Logic with Increasing Timeouts ✅

The system now automatically retries failed requests:
- **Attempt 1**: 30 second timeout
- **Attempt 2**: 45 second timeout (after 2s wait)
- **Attempt 3**: 60 second timeout (after 2s wait)

Total wait time: Up to **139 seconds** (2+ minutes) before giving up

### 2. WhatsApp Fallback ✅

When Vapi fails after all retries, the system **automatically falls back to WhatsApp**:
- Sends emergency notification via Twilio WhatsApp
- Logs the fallback in emergency logs
- Ensures contact is notified even if voice call fails

## Testing

Run the connectivity test:
```bash
python3 test_vapi_connectivity.py
```

This verifies:
- Credentials are loaded correctly
- API endpoint is reachable
- Authentication works
- Assistant and phone number exist

## Alternative Solutions

### Option 1: Increase Timeout Further

If you want to wait longer, edit `backend/services/vapi_service.py`:

```python
# Change this line:
timeout = 30 + (attempt - 1) * 15

# To something like:
timeout = 60 + (attempt - 1) * 30  # 60s, 90s, 120s
```

### Option 2: Check Network Configuration

1. **Test from different network** (try mobile hotspot)
2. **Check firewall rules** - ensure POST to api.vapi.ai:443 is allowed
3. **Use VPN** - try connecting through a US-based VPN server
4. **Contact ISP** - ask about routing to api.vapi.ai

### Option 3: Use Webhook-Based Approach

Instead of synchronous calls, use Vapi webhooks:
1. Initiate call asynchronously
2. Receive status updates via webhook
3. More resilient to timeouts

### Option 4: Switch to Twilio Voice

If Vapi continues to have issues, consider using Twilio Voice directly:
- More reliable in some regions
- Better documentation
- Direct integration (no AI assistant needed)

## Current Behavior

When you trigger an SOS:

1. **System tries Vapi call** (up to 3 attempts, ~2 minutes total)
2. **If Vapi succeeds** → Call is placed, AI assistant speaks
3. **If Vapi fails** → WhatsApp message sent automatically
4. **Both logged** in emergency_logs table

## Monitoring

Check these logs to diagnose issues:

```bash
# Watch backend logs in real-time
tail -f backend/logs/app.log | grep -i vapi

# Check emergency logs in database
sqlite3 backend/emergency_system.db "SELECT * FROM emergency_logs ORDER BY created_at DESC LIMIT 5;"
```

## Quick Fix Right Now

The system already has retry logic and WhatsApp fallback implemented. Just restart your backend:

```bash
cd backend
uvicorn main:app --reload
```

Now when you trigger an emergency:
- If Vapi works → Great! Voice call placed
- If Vapi times out → WhatsApp sent automatically as backup

This ensures your emergency contacts **always get notified**, even if one method fails.

## Contact Vapi Support

If the issue persists, contact Vapi support:
- Email: support@vapi.ai
- Include: Your API key (first 8 chars), region, error logs
- Ask: "Why are POST /call/phone requests timing out from Ethiopia?"
