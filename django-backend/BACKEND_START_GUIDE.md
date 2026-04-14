# Django Backend - Quick Start Guide

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Supabase account with PostgreSQL database
- Firebase project with Admin SDK

## Step-by-Step Setup

### 1. Install Python Dependencies

```bash
cd django-backend
pip install -r requirements.txt
```

**Dependencies installed:**
- Django 5.0 - Web framework
- djangorestframework - REST API
- django-cors-headers - CORS support
- psycopg[binary] - PostgreSQL driver
- python-decouple - Environment variables
- firebase-admin - Firebase Admin SDK
- PyJWT - JWT token generation
- requests - HTTP library

### 2. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click ⚙️ Settings → Project Settings
4. Go to **Service Accounts** tab
5. Click **Generate New Private Key**
6. Save the JSON file as:
   ```
   django-backend/backend/firebase-service-account.json
   ```

### 3. Configure Environment Variables

1. Copy the example file:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` with your credentials:

```env
# Django Settings
SECRET_KEY=your-random-secret-key-here
DEBUG=True

# JWT Settings (generate a random secret key)
JWT_SECRET_KEY=your-jwt-secret-key-here

# Supabase PostgreSQL Database
DB_NAME=postgres
DB_USER=postgres.your-project-ref
DB_PASSWORD=your-supabase-password
DB_HOST=db.your-project-ref.supabase.co
DB_PORT=5432
```

**How to get Supabase credentials:**
1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Go to **Settings** → **Database**
4. Find **Connection String** section
5. Copy the values for Host, User, Password

### 4. Verify Database Schema

Make sure your Supabase database has the `users` table:

```sql
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    user_uid VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(15),
    role_id INT REFERENCES roles(role_id),
    role_locked BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (role_name) VALUES
('Admin'),
('Supervisor'),
('Site Engineer'),
('Junior Accountant');
```

### 5. Test Database Connection

```bash
python manage.py check
```

If successful, you should see:
```
System check identified no issues (0 silenced).
```

### 6. Start Django Server

```bash
python manage.py runserver 0.0.0.0:8000
```

Or use the batch file:
```bash
run.bat
```

Server will start at: `http://localhost:8000`

### 7. Test API Endpoints

#### Test 1: Sign-In (Get JWT Token)

First, get a Firebase ID token from your Flutter app (check console logs), then:

```bash
curl -X POST http://localhost:8000/api/auth/signin/ ^
  -H "Content-Type: application/json" ^
  -d "{\"firebase_id_token\": \"YOUR_FIREBASE_TOKEN_HERE\"}"
```

**Expected Response:**
```json
{
  "is_new_user": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "user_uid": "firebase_uid_here",
    "email": "user@gmail.com",
    "full_name": "User Name",
    "phone": "",
    "role": "Supervisor",
    "role_locked": false
  }
}
```

#### Test 2: Get Profile (Use JWT Token)

```bash
curl -X GET http://localhost:8000/api/user/profile/ ^
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "full_name": "User Name",
  "email": "user@gmail.com",
  "phone": "",
  "role": "Supervisor"
}
```

#### Test 3: Update Profile

```bash
curl -X PUT http://localhost:8000/api/user/profile/update/ ^
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -d "{\"full_name\": \"New Name\", \"phone\": \"1234567890\"}"
```

**Expected Response:**
```json
{
  "message": "Profile updated successfully"
}
```

## API Endpoints Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/signin/` | None | Verify Firebase token, return JWT |
| GET | `/api/user/profile/` | JWT | Get user profile |
| PUT | `/api/user/profile/update/` | JWT | Update name/phone |

## Authentication Flow

```
1. Flutter App → Google Sign-In → Firebase ID Token
2. Flutter App → POST /api/auth/signin/ (Firebase Token)
3. Django → Verify with Firebase Admin SDK
4. Django → Create/Fetch User from Supabase
5. Django → Generate JWT Token (7-day expiry)
6. Django → Return JWT to Flutter
7. Flutter → Store JWT locally
8. Flutter → Use JWT for all API calls (Authorization: Bearer <token>)
```

## Troubleshooting

### Error: "Firebase service account file not found"
**Solution:** Download `firebase-service-account.json` from Firebase Console and place it in `django-backend/backend/`

### Error: "Database connection failed"
**Solution:** 
- Check Supabase credentials in `.env`
- Verify your IP is allowed in Supabase dashboard
- Test connection: `psql -h DB_HOST -U DB_USER -d DB_NAME`

### Error: "Invalid Firebase token"
**Solution:**
- Make sure Firebase Admin SDK is initialized
- Check if `firebase-service-account.json` is correct
- Verify the token is fresh (not expired)

### Error: "JWT token invalid"
**Solution:**
- Check `JWT_SECRET_KEY` in `.env`
- Verify token format: `Authorization: Bearer <token>`
- Token expires after 7 days

### Error: "CORS error from Flutter app"
**Solution:** CORS is already enabled for all origins in `settings.py`. If still having issues, check if the request includes proper headers.

## Project Structure

```
django-backend/
├── backend/
│   ├── __init__.py          # Firebase initialization
│   ├── settings.py          # Django settings (DB, JWT, CORS)
│   ├── urls.py              # Main URL routing
│   ├── firebase_config.py   # Firebase Admin SDK setup
│   └── firebase-service-account.json  # (You need to add this)
├── api/
│   ├── views.py             # API endpoints
│   ├── urls.py              # API URL routing
│   ├── authentication.py    # JWT authentication middleware
│   ├── jwt_utils.py         # JWT token generation
│   └── database.py          # Supabase database operations
├── manage.py                # Django management script
├── requirements.txt         # Python dependencies
├── .env                     # Environment variables (You need to create this)
├── .env.example             # Environment variables template
└── run.bat                  # Windows batch file to start server
```

## Next Steps

1. ✅ Backend is running
2. ⏳ Update Flutter app to use Django backend
3. ⏳ Test sign-in flow end-to-end
4. ⏳ Add more API endpoints (sites, reports, etc.)
5. ⏳ Deploy to production server

## Production Deployment

Before deploying to production:

1. Set `DEBUG=False` in `.env`
2. Change `SECRET_KEY` and `JWT_SECRET_KEY` to strong random values
3. Update `ALLOWED_HOSTS` in `settings.py`
4. Use a proper WSGI server (gunicorn, uwsgi)
5. Set up HTTPS/SSL
6. Configure proper CORS origins (not `*`)
7. Set up database backups
8. Enable logging and monitoring

## Support

If you encounter issues:
1. Check console logs for error messages
2. Verify all environment variables are set correctly
3. Test database connection separately
4. Check Firebase Admin SDK initialization
5. Review API request/response in browser DevTools or Postman
