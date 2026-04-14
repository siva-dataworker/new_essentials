# ✅ Firebase CLI Installed Successfully!

## Current Status
✅ Firebase CLI version 15.1.0 installed

## Next Steps

### 1. Login to Firebase
```cmd
firebase login
```

This will open your browser to authenticate with Google.

### 2. Configure FlutterFire
```cmd
cd otp_phone_auth
flutterfire configure --project=construction-4a98c
```

This will:
- Connect to your Firebase project
- Auto-generate `lib/firebase_options.dart`
- Configure Android, iOS, Web platforms

### 3. Get Flutter Dependencies
```cmd
flutter pub get
```

### 4. Update main.dart

Replace the content of `otp_phone_auth/lib/main.dart` with the code from `otp_phone_auth/lib/main_with_firebase.dart.example`

### 5. Enable Google Sign-In in Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **construction-4a98c**
3. Click **Authentication** → **Get Started**
4. Click **Sign-in method** tab
5. Enable **Google**
6. Add support email
7. Click **Save**

### 6. Add SHA-1 Fingerprint

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

### 7. Run Your App!

```cmd
flutter run
```

---

## Quick Command Summary

```cmd
# 1. Login
firebase login

# 2. Configure
cd otp_phone_auth
flutterfire configure --project=construction-4a98c

# 3. Dependencies
flutter pub get

# 4. Get SHA-1
get_sha1.bat

# 5. Run
flutter run
```

---

**Total Time: ~10 minutes** ⏱️

**Start with: `firebase login`** 🚀
