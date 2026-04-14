# ⚡ Quick Start Guide - Essential Homes

## 🎯 Current Status: 85% Complete

✅ Backend Running | ✅ Database Connected | ⏳ Firebase Pending

---

## 🚨 DO THIS NOW (2 minutes)

```cmd
npm install -g firebase-tools
```

If you don't have npm, download: https://firebase.tools/bin/win/instant/latest

---

## 📋 Complete Setup (15 minutes)

### 1. Install Firebase CLI
```cmd
npm install -g firebase-tools
```

### 2. Login & Configure
```cmd
firebase login
cd otp_phone_auth
flutterfire configure --project=construction-4a98c
flutter pub get
```

### 3. Update main.dart
Copy from `lib/main_with_firebase.dart.example` to `lib/main.dart`

### 4. Enable Google Sign-In
Firebase Console → Authentication → Enable Google

### 5. Add SHA-1
```cmd
get_sha1.bat
```
Add to Firebase Console

### 6. Run!
```cmd
flutter run
```

---

## 🔗 Quick Links

- **Complete Guide**: `START_NOW.md`
- **Detailed Steps**: `ALL_CONFIGURED.md`
- **Checklist**: `SETUP_CHECKLIST.md`
- **Firebase Help**: `FIREBASE_CLI_SETUP.md`

---

## 🧪 Test Backend (Already Working)

```cmd
curl http://localhost:8000/api/users/
```

---

## 🎉 After Setup

You'll have:
- ✅ Google Authentication
- ✅ Backend API (15 endpoints)
- ✅ Database (15 tables)
- ✅ Flutter App Ready

---

**Start here: `npm install -g firebase-tools`** 🚀
