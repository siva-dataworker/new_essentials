# Start Django Backend - Quick Guide

## ✅ Dependencies Installed Successfully!

All Python packages have been installed. Now you need to configure the backend.

## 🔧 Required Configuration (2 Steps)

### Step 1: Create `.env` File

1. Copy the example file:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` and add your credentials:

```env
# Django Settings
SECRET_KEY=your-random-secret-key-here
DEBUG=True

# JWT Settings
JWT_SECRET_KEY=your-jwt-secret-key-here

# Supabase PostgreSQL Database
DB_NAME=postgres
DB_USER=postgres.your-project-ref
DB_PASSWORD=your-supabase-password
DB_HOST=db.your-project-ref.supabase.co
DB_PORT=5432
```

**Where to get Supabase credentials:**
1. Go to https://app.supabase.com/
2. Select your project
3. Go to Settings → Database
4. Find "Connection String" section
5. Copy: Host, User, Password

### Step 2: Download Firebase Service Account

1. Go to https://console.firebase.google.com/
2. Select your project
3. Click ⚙️ Settings → Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate New Private Key"
6. Save the JSON file as:
   ```
   django-backend/backend/firebase-service-account.json
   ```

## 🚀 Start the Server

Once you've completed both steps above, run:

```bash
python manage.py runserver 0.0.0.0:8000
```

Or use the batch file:
```bash
run.bat
```

## ✅ Test the Backend

### 1. Check if server is running
Open browser: http://localhost:8000/api/auth/signin/

You should see: `{"error": "firebase_id_token is required"}`

This means the API is working!

### 2. Test with Firebase token

Get a Firebase token from your Flutter app (check console logs), then:

```bash
curl -X POST http://localhost:8000/api/auth/signin/ ^
  -H "Content-Type: application/json" ^
  -d "{\"firebase_id_token\": \"YOUR_TOKEN_HERE\"}"
```

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/signin/` | POST | Sign in with Firebase token |
| `/api/user/profile/` | GET | Get user profile (JWT required) |
| `/api/user/profile/update/` | PUT | Update profile (JWT required) |

## 🐛 Troubleshooting

### Error: "No module named 'decouple'"
**Solution**: Run `pip install -r requirements.txt` again

### Error: "Firebase service account file not found"
**Solution**: Download the JSON file from Firebase Console (Step 2 above)

### Error: "Database connection failed"
**Solution**: Check your Supabase credentials in `.env` file

### Error: "Invalid Firebase token"
**Solution**: Make sure you're using a fresh token from the Flutter app

## 📝 Next Steps

1. ✅ Install dependencies (DONE)
2. ⏳ Create `.env` file
3. ⏳ Download Firebase service account JSON
4. ⏳ Start Django server
5. ⏳ Test API endpoints
6. ⏳ Connect Flutter app to Django backend

## 🎯 Current Status

- ✅ Python dependencies installed
- ⏳ `.env` file needs to be created
- ⏳ Firebase service account needs to be downloaded
- ⏳ Server ready to start

---

**Need help?** Check `BACKEND_START_GUIDE.md` for detailed instructions.
