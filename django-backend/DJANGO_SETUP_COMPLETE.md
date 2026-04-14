# Django Backend Setup Complete ✅

## What's Been Configured

### 1. API Endpoints Created
- **POST** `/api/auth/signin/` - Firebase token verification & JWT generation
- **GET** `/api/user/profile/` - Get user profile (requires JWT)
- **PUT** `/api/user/profile/update/` - Update profile (requires JWT)

### 2. Authentication Flow
1. Flutter app sends Firebase ID token to `/api/auth/signin/`
2. Django verifies token with Firebase Admin SDK
3. Django creates/fetches user from Supabase PostgreSQL
4. Django returns JWT bearer token (7-day expiry)
5. Flutter uses JWT for all subsequent API calls

### 3. Database Integration
- Connected to Supabase PostgreSQL
- User data stored in `users` table
- Firebase UID stored in `user_uid` column
- Default role: Supervisor (role_id = 2)

### 4. Security Features
- Firebase Admin SDK for token verification
- JWT authentication for API endpoints
- CORS enabled for Flutter app
- Email and role cannot be changed via API
- Only phone and full_name are editable

## Next Steps to Run Backend

### Step 1: Install Dependencies
```bash
cd django-backend
pip install -r requirements.txt
```

### Step 2: Download Firebase Service Account Key
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Save as `django-backend/backend/firebase-service-account.json`

### Step 3: Configure Environment Variables
1. Copy `.env.example` to `.env`:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` with your Supabase credentials:
   ```
   DB_NAME=postgres
   DB_USER=postgres.your-project-ref
   DB_PASSWORD=your-supabase-password
   DB_HOST=db.your-project-ref.supabase.co
   DB_PORT=5432
   JWT_SECRET_KEY=your-random-secret-key
   ```

### Step 4: Run Django Server
```bash
python manage.py runserver 0.0.0.0:8000
```

### Step 5: Test API Endpoints

**Test Sign-In:**
```bash
curl -X POST http://localhost:8000/api/auth/signin/ \
  -H "Content-Type: application/json" \
  -d "{\"firebase_id_token\": \"<your_firebase_token>\"}"
```

**Test Get Profile:**
```bash
curl -X GET http://localhost:8000/api/user/profile/ \
  -H "Authorization: Bearer <your_jwt_token>"
```

**Test Update Profile:**
```bash
curl -X PUT http://localhost:8000/api/user/profile/update/ \
  -H "Authorization: Bearer <your_jwt_token>" \
  -H "Content-Type: application/json" \
  -d "{\"full_name\": \"New Name\", \"phone\": \"1234567890\"}"
```

## Files Modified/Created

### Created:
- `django-backend/backend/firebase_config.py` - Firebase Admin SDK setup
- `django-backend/api/jwt_utils.py` - JWT token generation
- `django-backend/api/authentication.py` - JWT authentication middleware
- `django-backend/api/database.py` - Supabase PostgreSQL operations
- `django-backend/api/views.py` - API endpoints
- `django-backend/.env.example` - Environment variables template

### Updated:
- `django-backend/api/urls.py` - API routing
- `django-backend/backend/urls.py` - Main URL configuration
- `django-backend/backend/settings.py` - Django settings (JWT, CORS, DB)
- `django-backend/backend/__init__.py` - Firebase initialization
- `django-backend/requirements.txt` - Added dependencies

## Architecture

```
Flutter App (Google Sign-In)
    ↓ Firebase ID Token
Django Backend (/api/auth/signin/)
    ↓ Verify with Firebase Admin SDK
    ↓ Create/Fetch User from Supabase
    ↓ Generate JWT Token
Flutter App (Store JWT)
    ↓ Use JWT for all API calls
Django Backend (Protected Endpoints)
    ↓ Verify JWT
    ↓ Query/Update Supabase
```

## Important Notes

1. **Firebase Token**: Used ONLY once during sign-in
2. **JWT Token**: Used for ALL subsequent API calls
3. **Token Lifetime**: 7 days (configurable in settings.py)
4. **Default Role**: Supervisor (role_id = 2)
5. **Editable Fields**: full_name, phone
6. **Read-Only Fields**: email, role, user_uid

## Troubleshooting

### Firebase Admin SDK Error
- Make sure `firebase-service-account.json` is in `django-backend/backend/`
- Check file permissions

### Database Connection Error
- Verify Supabase credentials in `.env`
- Check if Supabase allows connections from your IP
- Ensure SSL mode is enabled

### JWT Token Invalid
- Check JWT_SECRET_KEY in `.env`
- Verify token hasn't expired (7 days)
- Ensure Authorization header format: `Bearer <token>`

## Ready to Integrate with Flutter

Once the backend is running, update Flutter app's backend service to use:
- Base URL: `http://localhost:8000` (development)
- Sign-in endpoint: `/api/auth/signin/`
- Profile endpoint: `/api/user/profile/`
- Update endpoint: `/api/user/profile/update/`
