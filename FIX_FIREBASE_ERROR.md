# 🔧 Fix Firebase Dependency Error

## Issue
Firebase dependencies were outdated and incompatible with your Flutter/Dart SDK.

## ✅ Fixed
Updated `pubspec.yaml` with latest compatible Firebase versions:
- `firebase_core: ^3.8.1` (was ^2.24.2)
- `firebase_auth: ^5.3.3` (was ^4.16.0)

## 🎯 Run These Commands Now

```cmd
cd otp_phone_auth
flutter clean
flutter pub get
flutter run
```

## What These Commands Do

1. **flutter clean** - Removes old build files
2. **flutter pub get** - Downloads updated Firebase packages
3. **flutter run** - Builds and runs your app

---

## If You Still Get Errors

Try this:

```cmd
flutter pub upgrade
flutter clean
flutter pub get
flutter run
```

---

## Alternative: Run on Android Device/Emulator Only

If web errors persist, run on Android only:

```cmd
flutter run -d <device-id>
```

To see available devices:
```cmd
flutter devices
```

---

**Run this now:**
```cmd
cd otp_phone_auth
flutter clean
flutter pub get
flutter run
```
