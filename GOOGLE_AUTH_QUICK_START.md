# 🚀 Google Authentication - Quick Start (5 Minutes)

## ✅ What You Already Have

- ✅ `google_sign_in: ^6.2.1` in pubspec.yaml
- ✅ Google auth service code
- ✅ Google auth screen

## 🎯 What You Need to Do

### Step 1: Create/Select Firebase Project (2 min)

1. Go to: https://console.firebase.google.com/
2. Click **"Add project"** or select existing
3. Name: **Essential Homes**
4. Click **Create project**

### Step 2: Add Android App (2 min)

1. Click **Android icon** in Firebase Console
2. **Package name**: `com.example.otp_phone_auth`
3. **Get SHA-1**:
   ```cmd
   cd otp_phone_auth
   get_sha1.bat
   ```
   Copy the SHA-1 output

4. Paste SHA-1 in Firebase
5. Click **Register app**
6. **Download** `google-services.json`
7. **Place** it in: `otp_phone_auth/android/app/google-services.json`

### Step 3: Enable Google Sign-In (1 min)

1. Firebase Console → **Authentication**
2. Click **Get Started**
3. Click **Sign-in method** tab
4. Enable **Google**
5. Set support email
6. Click **Save**

### Step 4: Add Firebase Dependencies

Update `pubspec.yaml`:
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

### Step 5: Configure Android

Add to `android/build.gradle.kts`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

Add to `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
```

### Step 6: Initialize Firebase

Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### Step 7: Test!

```cmd
flutter run
```

---

## 📁 File Checklist

- [ ] `android/app/google-services.json` - Downloaded from Firebase
- [ ] `android/build.gradle.kts` - Added google-services plugin
- [ ] `android/app/build.gradle.kts` - Added Firebase dependencies
- [ ] `pubspec.yaml` - Added firebase_core and firebase_auth
- [ ] `lib/main.dart` - Initialize Firebase

---

## 🧪 Test Google Sign-In

1. Run app: `flutter run`
2. Navigate to Google Sign-In screen
3. Click "Sign in with Google"
4. Select Google account
5. Should see success!

---

## 🐛 Common Issues

**"google-services.json not found"**
- File must be in `android/app/` folder
- Exact name: `google-services.json`

**"SHA-1 mismatch"**
- Run `get_sha1.bat` again
- Add SHA-1 to Firebase Console

**"Sign-in failed"**
- Check Google Sign-In is enabled in Firebase
- Verify package name matches

**Build errors**
```cmd
flutter clean
flutter pub get
flutter run
```

---

## 📚 Full Guide

See `FIREBASE_GOOGLE_AUTH_SETUP.md` for detailed instructions.

---

## ✨ Summary

1. Create Firebase project
2. Add Android app + SHA-1
3. Download google-services.json
4. Enable Google Sign-In
5. Add Firebase dependencies
6. Configure Android
7. Initialize Firebase
8. Test!

**Total time: ~5 minutes** ⏱️

