# Umojee Emergency System - Quick Start Guide

## 🎉 System Successfully Created!

Your Umojee emergency management system prototype is now up and running!

## 🚀 Current Status

✅ **Backend Server**: Running on `http://localhost:8000`
✅ **Frontend Server**: Running on `http://localhost:3000`
✅ **Database**: SQLite database created with mock users
✅ **API Endpoints**: All endpoints tested and working

## 📱 Access the Application

### Frontend (Mobile-Friendly UI)
Open your browser and visit: **http://localhost:3000**

Start with: **http://localhost:3000/index.html**

### Backend API Documentation
Interactive API docs: **http://localhost:8000/docs**

## 🔐 Mock User Credentials

Use these credentials to log in:

**User 1:**
- Username: `haile`
- Password: `1234`

**User 2:**
- Username: `traveler1`
- Password: `1234`

## 🎯 Features Available

### 1. Login System
- Navigate to `index.html`
- Enter username and password
- Click "Login" button
- Automatic redirect to profile page on success

### 2. User Profile Management
- View complete user profile information
- Edit any field (name, address, phone, email, city, country, hotel)
- Save changes to database
- See success/error notifications

### 3. Emergency Contacts
- View all emergency contacts with priority order
- Edit contact information (name, relationship, phone, WhatsApp)
- Save updates to database
- Real-time display updates

## 📁 Project Structure

```
emergency_agent/
├── backend/
│   ├── main.py                    # FastAPI application
│   ├── database/
│   │   ├── __init__.py
│   │   └── database.py           # Database configuration
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py               # User model
│   │   ├── emergency_contact.py  # Emergency contact model
│   │   └── travel_history.py     # Travel history model
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth_routes.py        # Authentication endpoints
│   │   ├── user_routes.py        # User profile endpoints
│   │   └── contact_routes.py     # Contact management endpoints
│   ├── services/
│   │   ├── __init__.py
│   │   ├── user_service.py       # User business logic
│   │   ├── contact_service.py    # Contact business logic
│   │   └── travel_service.py     # Travel history logic
│   ├── schemas/
│   │   ├── __init__.py
│   │   └── schemas.py            # Pydantic schemas
│   └── umojee.db                 # SQLite database (auto-generated)
│
└── frontend/
    ├── index.html                # Login page
    ├── profile.html              # Profile management page
    ├── contacts.html             # Emergency contacts page
    ├── style.css                 # Mobile-responsive styles
    └── app.js                    # Frontend JavaScript logic
```

## 🔧 API Endpoints Reference

### Authentication
- `POST /auth/login` - User login
  ```json
  {
    "username": "haile",
    "password": "1234"
  }
  ```
  Response: `{ "message": "Login successful", "token": "session_1", "user": {...} }`

- `POST /auth/logout?token={token}` - User logout

### User Profile
- `GET /user/profile?token={token}` - Get user profile
- `PUT /user/profile?token={token}` - Update user profile
  ```json
  {
    "full_name": "New Name",
    "phone": "+1234567890",
    ...
  }
  ```

### Emergency Contacts
- `GET /user/emergency-contacts/?token={token}` - Get contacts
- `PUT /user/emergency-contacts/?token={token}` - Update contacts
  ```json
  {
    "contacts": [
      {
        "priority": 1,
        "contact_name": "John Doe",
        "relationship": "Father",
        "phone": "+1234567890",
        "whatsapp": "+1234567890"
      }
    ]
  }
  ```

## 🎨 Frontend Features

- **Mobile-first responsive design**: Works perfectly on mobile devices
- **Clean modern UI**: Gradient backgrounds, card-based layout
- **Real-time validation**: Form validation and error handling
- **Session management**: Automatic authentication checks
- **Success/error notifications**: Visual feedback for all actions
- **Navigation tabs**: Easy switching between Profile and Contacts

## 🗄️ Database Schema

### users Table
- id (Primary Key)
- username (Unique)
- password (Plain text for prototype)
- full_name, address, phone, email
- current_city, current_country, hotel_name

### emergency_contacts Table
- id (Primary Key)
- user_id (Foreign Key → users.id)
- priority (Integer)
- contact_name, relationship, phone, whatsapp

### travel_history Table
- id (Primary Key)
- user_id (Foreign Key → users.id)
- country, city, travel_date

## ⚠️ Important Notes

1. **Prototype Stage**: Passwords are stored in plain text (not production-ready)
2. **Session Management**: Uses simple token system (use JWT for production)
3. **No Registration**: Only predefined mock users can log in
4. **Auto-initialization**: Database is created and populated on first run
5. **CORS Enabled**: Frontend can communicate with backend without restrictions

## 🔄 Restarting Services

### Backend (if needed):
```bash
source /home/haile/ai/bin/activate
cd /home/haile/ai/projects/upwork/emergency_agent/backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend (if needed):
```bash
cd /home/haile/ai/projects/upwork/emergency_agent/frontend
python3 -m http.server 3000
```

## 🧪 Testing the System

1. Open browser to `http://localhost:3000/index.html`
2. Login with username: `haile`, password: `1234`
3. View and edit your profile information
4. Navigate to Emergency Contacts tab
5. View and edit emergency contact information
6. Test logout functionality

## 🎯 Next Steps (Future Enhancements)

- Implement JWT authentication
- Add password hashing (bcrypt)
- Create user registration system
- Add SOS emergency alert feature
- Implement real-time location tracking
- Add push notifications
- Deploy to production environment

---

**System is ready to use! Enjoy your Umojee Emergency Management System! 🚀**
