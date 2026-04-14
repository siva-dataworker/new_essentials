# 🔴 CRITICAL: Full Rebuild Required

## The Problem
You're seeing the error: **"Assertion failed: 'clientId != null'"**

This is because the app is still running with the **old package name** (`com.example.otp_phone_auth`) but we changed it to **`com.example.essential_homes`**.

Hot restart **DOES NOT** apply package name changes. You need a **full rebuild**.

## ✅ What We Fixed
1. Changed package name from `com.example.otp_phone_auth` to `com.example.essential_homes`
2. Moved MainActivity to correct location: `android/app/src/main/kotlin/com/example/essential_homes/MainActivity.kt`
3. Updated `build.gradle.kts` with new package name
4. Placed correct `google-services.json` in `android/app/` folder with OAuth client configured

## 🚀 Required Steps (DO THIS NOW)

### Step 1: Stop the App Completely
- Press `Ctrl+C` in the terminal where Flutter is running
- Or click the Stop button in your IDE
- Make sure the app is completely closed on your device/emulator

### Step 2: Clean Build Cache
```bash
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth
flutter clean
```

### Step 3: Get Dependencies
```bash
flutter pub get
```

### Step 4: Full Rebuild and Run
```bash
flutter run
```

**IMPORTANT**: Select your device when prompted (Android emulator or physical device)

### Step 5: Test Google Sign-In
1. App opens → Splash Screen
2. Tap anywhere → Role Selection Screen
3. Tap "Supervisor" → Google Sign-In Screen
4. Tap "Sign in with Google" → Google account picker should appear
5. Select your Google account → Should sign in successfully
6. Navigate to Supervisor Dashboard

## Why This Happens
- Package name changes require native Android code recompilation
- Hot restart only reloads Dart code, not native Android configuration
- The old package name was cached in the build artifacts
- `flutter clean` removes all cached build files
- `flutter run` rebuilds everything from scratch with the new package name

## Expected Result After Rebuild
✅ Google Sign-In should work without "clientId != null" error
✅ OAuth client will be loaded from `google-services.json`
✅ Firebase Authentication will work properly
✅ MySQL sync will work (if MySQL is configured)

## If Still Not Working After Rebuild
1. Check that `google-services.json` is in `android/app/` folder (not `android/`)
2. Verify package name in Firebase Console matches: `com.example.essential_homes`
3. Verify SHA-1 fingerprint is added in Firebase Console: `DD:C4:80:99:9D:D5:0E:0D:55:DD:85:3F:4D:7A:0D:2B:9F:91:B6:B0`
4. Check that you downloaded the latest `google-services.json` from Firebase Console after adding SHA-1

## Current Configuration Status
✅ Package name: `com.example.essential_homes`
✅ MainActivity location: `android/app/src/main/kotlin/com/example/essential_homes/MainActivity.kt`
✅ google-services.json: `android/app/google-services.json` (correct location)
✅ OAuth client configured with SHA-1 certificate hash
✅ Firebase Authentication enabled
✅ MySQL service ready (optional, commented out in main.dart)

---

**DO NOT use hot restart or hot reload for this change. You MUST do a full rebuild.**
