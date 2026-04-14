# 🚀 START HERE - Complete Setup Guide

## Current Status

✅ **Django Backend**: Running on http://localhost:8000
✅ **Supabase Database**: Connected with sample data
✅ **Flutter App**: Configured with Supabase
⏳ **Firebase Google Auth**: Needs Firebase CLI installation

---

## 🎯 Next Steps to Complete Setup

### Step 1: Install Firebase CLI (5 minutes)

**Choose ONE option:**

#### Option A: Using npm (Fastest if you have Node.js)
```cmd
npm install -g firebase-tools
```

#### Option B: Standalone Installer (No Node.js needed)
1. Download: https://firebase.tools/bin/win/instant/latest
2. Run installer
3. Restart terminal

#### Option C: Using Chocolatey
```cmd
choco install firebase-cli
```

**Verify installation:**
```cmd
firebase --version
```

---

### Step 2: Login to Firebase
```cmd
firebase login
```
This opens your browser to authenticate.

---

### Step 3: Configure FlutterFire
```cmd
cd otp_phone_auth
flutterfire configure --project=construction-4a98c
```

This will:
- ✅ Auto-generate `lib/firebase_options.dart`
- ✅ Configure all platforms (Android, iOS, Web)

---

### Step 4: Add Firebase Dependencies

Update `otp_phone_auth/pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  google_sign_in: ^6.2.1  # Already added ✅
```

Run:
```cmd
cd otp_phone_auth
flutter pub get
```

---

### Step 5: Update main.dart

Replace `otp_phone_auth/lib/main.dart` with:
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/supabase_service.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Supabase
  await SupabaseService.initialize(
    supabaseUrl: SupabaseConfig.supabaseUrl,
    supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essential Homes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
```

---

### Step 6: Enable Google Sign-In in Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **construction-4a98c**
3. Click **Authentication** → **Get Started**
4. Click **Sign-in method** tab
5. Enable **Google**
6. Set support email
7. Click **Save**

---

### Step 7: Add SHA-1 to Firebase

```cmd
cd otp_phone_auth
get_sha1.bat
```

Copy the SHA-1 output, then:

1. Firebase Console → **Project Settings** (gear icon)
2. Scroll to **Your apps** → Select Android app
3. Click **Add fingerprint**
4. Paste SHA-1
5. Click **Save**

---

### Step 8: Test Everything!

```cmd
cd otp_phone_auth
flutter run
```

---

## 📋 Quick Command Checklist

```cmd
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login
firebase login

# 3. Configure FlutterFire
cd otp_phone_auth
flutterfire configure --project=construction-4a98c

# 4. Add dependencies
flutter pub get

# 5. Get SHA-1
get_sha1.bat

# 6. Run app
flutter run
```

---

## 🔍 Verify Everything Works

### Backend Check
```cmd
curl http://localhost:8000/api/users/
```
Should return JSON with users data.

### Flutter App Check
1. Run app: `flutter run`
2. Navigate to Google Sign-In screen
3. Click "Sign in with Google"
4. Select account
5. Should authenticate successfully!

---

## 📁 Important Files

### Backend
- `django-backend/.env` - Database credentials
- `django-backend/api/models.py` - 15 database models
- `django-backend/run.bat` - Start backend

### Flutter
- `otp_phone_auth/lib/firebase_options.dart` - Auto-generated (after Step 3)
- `otp_phone_auth/lib/main.dart` - App entry point
- `otp_phone_auth/lib/config/supabase_config.dart` - Supabase config
- `otp_phone_auth/pubspec.yaml` - Dependencies

---

## 🐛 Troubleshooting

### "npm is not recognized"
Install Node.js: https://nodejs.org/

### "firebase is not recognized"
Restart terminal after installing Firebase CLI

### "FlutterFire configure fails"
Make sure:
- Firebase CLI installed: `firebase --version`
- Logged in: `firebase login`
- Project exists: `construction-4a98c`

### Backend not running
```cmd
cd django-backend
run.bat
```

---

## 📚 Documentation Files

- `FIREBASE_CLI_SETUP.md` - Detailed Firebase CLI installation
- `GOOGLE_AUTH_QUICK_START.md` - Quick Firebase setup guide
- `FIREBASE_GOOGLE_AUTH_SETUP.md` - Complete Firebase guide
- `HOW_TO_START_BACKEND.md` - Backend startup guide
- `django-backend/README.md` - Backend documentation

---

## ✨ What You'll Have After Setup

✅ Django REST API backend connected to Supabase
✅ 15 database models with API endpoints
✅ Firebase Google Authentication
✅ Flutter app with Supabase integration
✅ Role-based authentication system
✅ Ready for construction management features

---

## 🎯 Next Development Steps

After completing setup:

1. **Test Google Sign-In** - Verify authentication works
2. **Connect Auth to Backend** - Link Firebase users to Django
3. **Build Role Dashboards** - Admin, Supervisor, Site Engineer, etc.
4. **Implement Features**:
   - Daily site reports
   - Labour tracking
   - Material management
   - Photo uploads
   - Complaints system

---

## 💡 Need Help?

- Firebase CLI issues → See `FIREBASE_CLI_SETUP.md`
- Google Auth setup → See `GOOGLE_AUTH_QUICK_START.md`
- Backend issues → See `HOW_TO_START_BACKEND.md`
- Database schema → See `django-backend/insert_data.sql`

---

**Total Setup Time: ~15 minutes** ⏱️

Let's build something amazing! 🚀
