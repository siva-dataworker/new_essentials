# Quick Reference Card

## 🚀 One-Command Setup
```bash
cd otp_phone_auth
dart pub global activate flutterfire_cli
flutterfire configure
flutter run
```

## 📋 Essential Commands

### Setup
```bash
flutter pub get                    # Install dependencies
flutterfire configure             # Configure Firebase
```

### Run
```bash
flutter run                       # Run on connected device
flutter run -d chrome             # Run on web
flutter run --release             # Release build
```

### Build
```bash
flutter build apk                 # Build Android APK
flutter build appbundle           # Build Android App Bundle
flutter build ios                 # Build iOS
```

### Debug
```bash
flutter clean                     # Clean build files
flutter doctor                    # Check Flutter setup
flutter pub outdated              # Check for updates
```

### Android
```bash
cd android
./gradlew signingReport           # Get SHA-1
./gradlew clean                   # Clean Android build
```

## 🔑 Test Credentials

Add in Firebase Console → Authentication → Phone → Test numbers:

| Phone Number      | OTP Code |
|-------------------|----------|
| +1 650 555 1234   | 123456   |
| +1 555 123 4567   | 654321   |

## 📱 Package Name

**Android:** `com.example.otp_phone_auth`
**iOS:** `com.example.otpPhoneAuth`

## 🔧 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/firebase_options.dart` | Firebase config (auto-generated) |
| `android/app/google-services.json` | Android Firebase config |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase config |
| `android/app/build.gradle.kts` | Android build config |

## 🐛 Quick Fixes

### "Internal error occurred"
```bash
# Add SHA-1 to Firebase Console
cd android && ./gradlew signingReport
# Copy SHA-1 → Firebase Console → Project Settings → Add fingerprint
```

### "App not authorized"
```bash
# Ensure google-services.json is in android/app/
# Run: flutter clean && flutter pub get
```

### Build errors
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
flutter run
```

## 📊 Firebase Console URLs

- **Project Overview:** https://console.firebase.google.com/project/constructionsite-8d964
- **Authentication:** https://console.firebase.google.com/project/constructionsite-8d964/authentication
- **Project Settings:** https://console.firebase.google.com/project/constructionsite-8d964/settings/general

## 🎯 Key Features

✅ Phone number input with country code
✅ OTP verification (6-digit PIN)
✅ Firebase Authentication
✅ Error handling
✅ Loading states
✅ Sign out functionality

## 📦 Dependencies

```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.3
pinput: ^5.0.0
intl_phone_field: ^3.2.0
```

## 🔐 Security Checklist

- [ ] SHA-1 added to Firebase Console
- [ ] Phone auth enabled in Firebase
- [ ] Test phone numbers configured
- [ ] `.gitignore` includes Firebase configs
- [ ] Min SDK set to 21

## 📞 Support

- **Firebase Docs:** https://firebase.google.com/docs/auth/flutter/phone-auth
- **Flutter Docs:** https://flutter.dev/docs
- **FlutterFire:** https://firebase.flutter.dev

## 💡 Pro Tips

1. Use test phone numbers during development (no SMS cost)
2. Enable Firebase Blaze plan for production SMS
3. Add multiple SHA-1 certificates (debug + release)
4. Implement rate limiting in production
5. Use Firebase App Check for security

## 🎨 UI Screens

1. **Phone Input** → Enter phone number
2. **OTP Verification** → Enter 6-digit code
3. **Home** → Success screen with sign out

## ⚡ Performance

- Cold start: ~2-3 seconds
- OTP send: ~1-2 seconds
- Verification: Instant
- App size: ~20-30 MB

## 🌐 Platform Support

✅ Android (API 21+)
✅ iOS (12.0+)
✅ Web (with limitations)
❌ Desktop (not configured)

---

**Need help?** Check `COMPLETE_SETUP_GUIDE.md` for detailed instructions.
