# Emergency Agent

A comprehensive emergency management system with integrated communication channels for travelers and emergency contacts.

## Overview

Emergency Agent is a multi-channel emergency response system that allows users to quickly trigger alerts through various channels including WhatsApp, voice calls, and web interfaces. The system automatically notifies emergency contacts and provides location information to facilitate rapid assistance.

## Features

- Multi-channel emergency signaling (WhatsApp, voice calls, web interface)
- Real-time location tracking
- User profile management
- Emergency contact management
- Automated notifications to emergency contacts
- Integration with Twilio and VAPI for voice services
- Secure authentication system

## Tech Stack

- **Backend**: Python FastAPI
- **Frontend**: HTML/CSS/JavaScript (with potential Flutter mobile app)
- **Database**: SQLite (can be extended to PostgreSQL/MySQL)
- **Communication**: Twilio API, WhatsApp Business API
- **Voice Services**: VAPI (Voice Application Platform)

## Project Structure

```
emergency_agent/
├── backend/                  # FastAPI backend
│   ├── database/             # Database setup
│   ├── models/               # ORM models
│   ├── routes/               # API route definitions
│   ├── schemas/              # Pydantic schemas
│   ├── services/             # Business logic
│   ├── main.py              # Main application entry point
│   └── requirements.txt     # Python dependencies
├── frontend/                 # Frontend assets
│   ├── index.html           # Main landing page
│   ├── profile.html         # Profile management page
│   ├── contacts.html        # Emergency contacts page
│   ├── app.js               # JavaScript functionality
│   └── style.css            # Styling
├── docs/                     # Documentation
├── scripts/                  # Utility scripts
├── .env.example            # Example environment variables
├── README.md               # This file
└── requirements.txt        # Root dependencies
```

## Setup Instructions

### Prerequisites

- Python 3.8+
- Node.js (for frontend development)
- Twilio account
- VAPI account (optional)
- Ngrok account (for local development)

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   ```

3. Activate the virtual environment:
   - On Linux/Mac:
     ```bash
     source venv/bin/activate
     ```
   - On Windows:
     ```bash
     venv\Scripts\activate
     ```

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

5. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```
   
   Edit the `.env` file and add your configuration values.

6. Run the backend server:
   ```bash
   uvicorn main:app --reload
   ```

### Frontend Setup

The frontend consists of static HTML/CSS/JS files. For development, you can serve them using any local server:

```bash
cd frontend
python -m http.server 8080
```

Or use live-server if you have Node.js installed:
```bash
npm install -g live-server
cd frontend
live-server
```

## Environment Variables

Create a `.env` file based on `.env.example` with the following variables:

- `DATABASE_URL`: Database connection string
- `SECRET_KEY`: JWT secret key
- `ALGORITHM`: JWT algorithm (default: HS256)
- `ACCESS_TOKEN_EXPIRE_MINUTES`: Token expiration time
- `TWILIO_ACCOUNT_SID`: Twilio Account SID
- `TWILIO_AUTH_TOKEN`: Twilio Auth Token
- `TWILIO_PHONE_NUMBER`: Twilio phone number
- `VAPI_API_KEY`: VAPI API key (optional)
- `VAPI_WEBHOOK_SECRET`: VAPI webhook secret (optional)
- `WHATSAPP_BUSINESS_ACCOUNT_ID`: WhatsApp Business Account ID
- `WHATSAPP_ACCESS_TOKEN`: WhatsApp Access Token
- `NGROK_AUTH_TOKEN`: Ngrok authentication token

## API Endpoints

The backend provides the following main endpoints:

- `POST /auth/login` - User authentication
- `POST /auth/logout` - User logout
- `GET /users/me` - Get current user info
- `PUT /users/update` - Update user info
- `GET /contacts` - Get user's emergency contacts
- `POST /contacts` - Add emergency contact
- `POST /emergency/webhook` - Emergency signal webhook

## Emergency Signaling

The system supports triggering emergency signals through multiple channels:

1. **WhatsApp**: Send "SOS" or "HELP" to the registered number
2. **Web Interface**: Click the emergency button on the website
3. **Voice Call**: Through integrated VAPI system
4. **Mobile App**: Via the mobile application (when implemented)

When an emergency signal is triggered, the system:
1. Identifies the user based on phone number or other identifiers
2. Retrieves user information and location data
3. Sends notifications to all emergency contacts
4. Logs the incident for review

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the project maintainers.
