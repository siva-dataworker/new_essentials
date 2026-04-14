# Essential Homes - Quick Reference

## 🚀 Quick Start Commands

### Run Flutter App
```bash
cd otp_phone_auth
flutter run
```

### Run Django Backend
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### Hot Restart Flutter
Press `Ctrl+Shift+F5` or click 🔄 button

### Clean Flutter Build
```bash
flutter clean
flutter pub get
flutter run
```

## 🔑 Important Credentials

### Supabase (Database)
- **URL**: `https://your-project.supabase.co`
- **Anon Key**: In `lib/config/supabase_config.dart`
- **Database**: PostgreSQL connection in Django `.env`

### Firebase (Authentication)
- **google-services.json**: `android/app/google-services.json`
- **Service Account**: `django-backend/backend/firebase-service-account.json`
- **Web Client ID**: In Firebase Console

### Django Backend
- **Base URL**: `http://localhost:8000`
- **Environment**: `.env` file in `django-backend/`
- **JWT Secret**: In `.env` file

## 📡 API Endpoints

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/auth/signin/` | POST | None | Get JWT token |
| `/api/user/profile/` | GET | JWT | Get profile |
| `/api/user/profile/update/` | PUT | JWT | Update profile |

## 🎨 Color Scheme

```dart
AppColors.deepNavy        // #1A237E (Primary)
AppColors.safetyOrange    // #FF6F00 (Accent)
AppColors.cleanWhite      // #FAFAFA (Background)
AppColors.textPrimary     // #212121 (Text)
AppColors.textSecondary   // #757575 (Secondary Text)
```

## 📱 App Flow

```
Splash (2s) → Role Selection → Google Sign-In → Dashboard → Profile
```

## 🗄️ Database Tables

### Main Tables
- `users` - User accounts
- `roles` - User roles (Admin, Supervisor, etc.)
- `sites` - Construction sites
- `material_master` - Material catalog
- `daily_site_report` - Daily reports

### Entry Tables
- `daily_labour_summary` - Labour count
- `daily_salary_entry` - Salary records
- `daily_material_balance` - Material inventory
- `material_bills` - Bill uploads
- `work_activity` - Work photos

## 🔧 Common Issues & Fixes

### Issue: Phone verification screen appears
**Fix**: Hot restart (`Ctrl+Shift+F5`)

### Issue: Google Sign-In fails
**Fix**: 
1. Check `google-services.json` exists
2. Verify SHA-1 in Firebase Console
3. Check internet permissions

### Issue: User data not saving
**Fix**:
1. Verify Supabase credentials
2. Check `user_uid` column exists
3. Review console logs

### Issue: Backend connection error
**Fix**:
1. Ensure Django server is running
2. Check `.env` file exists
3. Verify Firebase service account JSON

### Issue: Logo not showing
**Fix**: Copy logo to `assets/images/essential_homes_logo.png`

## 📂 Key File Locations

### Flutter
```
lib/main.dart                          # Entry point
lib/screens/splash_screen.dart         # Splash
lib/screens/role_selection_screen.dart # Role selection
lib/screens/google_auth_screen.dart    # Google auth
lib/services/google_auth_service.dart  # Auth logic
lib/config/supabase_config.dart        # DB config
```

### Django
```
backend/settings.py                    # Settings
backend/firebase_config.py             # Firebase
api/views.py                           # Endpoints
api/urls.py                            # Routing
api/database.py                        # DB operations
.env                                   # Credentials
```

### Configuration
```
android/app/google-services.json       # Firebase config
django-backend/.env                    # Backend config
django-backend/backend/firebase-service-account.json  # Firebase admin
```

## 🧪 Testing

### Test Google Sign-In
1. Run app
2. Select Supervisor role
3. Click "Continue with Google"
4. Sign in with Google account
5. Should land on dashboard

### Test Backend API
```bash
# Get JWT token
curl -X POST http://localhost:8000/api/auth/signin/ \
  -H "Content-Type: application/json" \
  -d "{\"firebase_id_token\": \"<token>\"}"

# Get profile
curl -X GET http://localhost:8000/api/user/profile/ \
  -H "Authorization: Bearer <jwt_token>"
```

## 📊 User Roles

| Role ID | Role Name | Status |
|---------|-----------|--------|
| 1 | Admin | Coming Soon |
| 2 | Supervisor | ✅ Active |
| 3 | Site Engineer | Coming Soon |
| 4 | Junior Accountant | Coming Soon |

## 🔐 Authentication Flow

```
1. User selects role
2. User signs in with Google
3. Firebase returns ID token
4. App sends token to Django
5. Django verifies with Firebase
6. Django creates/fetches user
7. Django returns JWT token
8. App stores JWT
9. App uses JWT for API calls
```

## 📝 User Data Fields

| Field | Source | Editable |
|-------|--------|----------|
| user_uid | Firebase | ❌ |
| email | Google | ❌ |
| full_name | Google | ✅ |
| phone | User | ✅ |
| role_id | Selection | ❌ (Admin only) |

## 🎯 Next Development Tasks

1. ⏳ Connect Flutter to Django backend
2. ⏳ Implement daily site reports
3. ⏳ Add labour count entry
4. ⏳ Add salary entry
5. ⏳ Add material balance tracking
6. ⏳ Add bill upload with photos
7. ⏳ Add work activity photos
8. ⏳ Implement other role dashboards

## 📞 Quick Help

### Flutter Commands
```bash
flutter doctor          # Check setup
flutter clean           # Clean build
flutter pub get         # Get dependencies
flutter run             # Run app
flutter build apk       # Build APK
```

### Django Commands
```bash
python manage.py check              # Check config
python manage.py runserver          # Start server
python manage.py migrate            # Run migrations
pip install -r requirements.txt     # Install deps
```

### Git Commands
```bash
git status              # Check status
git add .               # Stage changes
git commit -m "msg"     # Commit
git push                # Push to remote
```

## 🌐 URLs

- **Flutter App**: Running on device/emulator
- **Django Backend**: `http://localhost:8000`
- **Supabase Dashboard**: `https://app.supabase.com`
- **Firebase Console**: `https://console.firebase.google.com`

## 📚 Documentation

- `README_START_HERE.md` - Project overview
- `CURRENT_STATUS.md` - Detailed status
- `PHONE_LOGIN_REMOVED.md` - Auth flow
- `django-backend/BACKEND_START_GUIDE.md` - Backend setup
- `QUICK_REFERENCE.md` - This file

## 💾 Backup Important Files

Before making changes, backup:
- `lib/config/supabase_config.dart`
- `android/app/google-services.json`
- `django-backend/.env`
- `django-backend/backend/firebase-service-account.json`

## 🎓 Learning Resources

- Flutter: https://flutter.dev/docs
- Django: https://docs.djangoproject.com
- Firebase: https://firebase.google.com/docs
- Supabase: https://supabase.com/docs
- REST API: https://restfulapi.net/

---

**Last Updated**: December 20, 2024
**Version**: 1.0.0
**Status**: Development
