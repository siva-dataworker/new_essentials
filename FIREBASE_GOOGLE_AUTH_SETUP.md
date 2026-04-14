# Firebase Google Authentication Setup Guide

## Overview

This guide will help you set up Google Sign-In with Firebase for your Flutter app.

## Prerequisites

- Flutter app project
- Google account
- Firebase project

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select existing project
3. Enter project name: **"Essential Homes"**
4. Click **Continue**
5. Disable Google Analytics (optional)
6. Click **Create project**

---

## Step 2: Add Android App to Firebase

1. In Firebase Console, click **Android icon** (⚙️)
2. Register app:
   - **Android package name**: `com.example.otp_phone_auth` (get from `android/app/build.gradle.kts`)
   - **App nickname**: Essential Homes Android
   - **Debug signing certificate SHA-1**: Get using command below

### Get SHA-1 Certificate:

Run this command in your project root:
```cmd
cd otp_phone_auth
get_sha1.bat
```

Or manually:
```cmd
cd android
gradlew signingReport
```

Copy the **SHA-1** from the output and paste in Firebase.

3. Click **Register app**
4. Download `google-services.json`
5. Place it in: `otp_phone_auth/android/app/google-services.json`

---

## Step 3: Enable Google Sign-In in Firebase

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Click **Sign-in method** tab
4. Click **Google**
5. Toggle **Enable**
6. Set **Project support email**: your email
7. Click **Save**

---

## Step 4: Configure Android App

### 4.1 Update `android/build.gradle.kts`

Already configured! Check if this exists:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

### 4.2 Update `android/app/build.gradle.kts`

Already configured! Check if these exist:
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

---

## Step 5: Add Flutter Dependencies

Check `pubspec.yaml` has these:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  google_sign_in: ^6.2.1
```

Run:
```cmd
cd otp_phone_auth
flutter pub get
```

---

## Step 6: Initialize Firebase in Flutter

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(MyApp());
}
```

---

## Step 7: Test Google Sign-In

Run your app:
```cmd
cd otp_phone_auth
flutter run
```

Navigate to Google Sign-In screen and test!

---

## Troubleshooting

### Error: "google-services.json not found"
- Make sure file is in `android/app/` folder
- File name must be exactly `google-services.json`

### Error: "SHA-1 certificate mismatch"
- Run `get_sha1.bat` again
- Add SHA-1 to Firebase Console → Project Settings → Your apps → SHA certificate fingerprints

### Error: "Google Sign-In failed"
- Check Google Sign-In is enabled in Firebase Console
- Verify package name matches in Firebase and `build.gradle.kts`
- Make sure `google-services.json` is up to date

### Error: "PlatformException"
- Clean and rebuild:
  ```cmd
  flutter clean
  flutter pub get
  cd android
  gradlew clean
  cd ..
  flutter run
  ```

---

## Quick Reference

### Firebase Console URLs
- **Project**: https://console.firebase.google.com/project/YOUR_PROJECT_ID
- **Authentication**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication
- **Project Settings**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/general

### Important Files
- `android/app/google-services.json` - Firebase config
- `android/app/build.gradle.kts` - Android config
- `lib/services/google_auth_service.dart` - Google Sign-In service
- `lib/screens/google_auth_screen.dart` - Google Sign-In UI

### Commands
```cmd
# Get SHA-1
cd otp_phone_auth
get_sha1.bat

# Install dependencies
flutter pub get

# Clean build
flutter clean
flutter pub get

# Run app
flutter run
```

---

## Next Steps

1. ✅ Create Firebase project
2. ✅ Add Android app
3. ✅ Download google-services.json
4. ✅ Enable Google Sign-In
5. ✅ Configure Android
6. ✅ Add Flutter dependencies
7. ✅ Initialize Firebase
8. ✅ Test Google Sign-In

---

## Architecture

```
User clicks "Sign in with Google"
    ↓
Google Sign-In SDK
    ↓
Firebase Authentication
    ↓
User authenticated
    ↓
Store user in Supabase/Django backend
```

---

## Security Notes

- Never commit `google-services.json` to public repos
- Use different Firebase projects for dev/prod
- Enable App Check for production
- Set up proper security rules

---

## Support

- [Firebase Auth Docs](https://firebase.google.com/docs/auth)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Flutter](https://firebase.flutter.dev/)

