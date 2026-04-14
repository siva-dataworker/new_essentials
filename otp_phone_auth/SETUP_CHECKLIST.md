# Setup Checklist ✅

Use this checklist to track your setup progress.

## 📋 Pre-Setup

- [ ] Flutter SDK installed and working (`flutter doctor`)
- [ ] Android Studio or Xcode installed
- [ ] Firebase account created
- [ ] Firebase project exists (constructionsite-8d964)

## 🔧 Firebase Configuration

- [ ] FlutterFire CLI installed
  ```bash
  dart pub global activate flutterfire_cli
  ```

- [ ] Firebase configured for Flutter
  ```bash
  cd otp_phone_auth
  flutterfire configure
  ```

- [ ] Selected Firebase project: constructionsite-8d964
- [ ] Selected platforms: Android, iOS
- [ ] `firebase_options.dart` generated successfully

## 🔐 Firebase Console Setup

- [ ] Opened Firebase Console
- [ ] Navigated to Authentication section
- [ ] Clicked "Sign-in method" tab
- [ ] Enabled "Phone" provider
- [ ] Clicked "Save"

## 📱 Android Configuration

- [ ] Generated SHA-1 certificate
  ```bash
  cd android
  ./gradlew signingReport
  ```

- [ ] Copied SHA-1 fingerprint
- [ ] Opened Firebase Console → Project Settings
- [ ] Selected Android app
- [ ] Clicked "Add fingerprint"
- [ ] Pasted SHA-1 and saved

- [ ] Downloaded `google-services.json` (if not auto-generated)
- [ ] Placed in `android/app/` directory
- [ ] Verified `minSdkVersion = 21` in `android/app/build.gradle.kts`
- [ ] Verified Google services plugin added

## 🍎 iOS Configuration (if building for iOS)

- [ ] Downloaded `GoogleService-Info.plist`
- [ ] Added to `ios/Runner/` in Xcode
- [ ] Verified minimum iOS version is 12.0
- [ ] Run `cd ios && pod install`

## 🧪 Test Phone Numbers (Optional but Recommended)

- [ ] Opened Firebase Console → Authentication
- [ ] Clicked "Sign-in method" → Phone
- [ ] Scrolled to "Phone numbers for testing"
- [ ] Added test phone number: `+1 650 555 1234`
- [ ] Added verification code: `123456`
- [ ] Clicked "Add"

## 📦 Dependencies

- [ ] Installed Flutter dependencies
  ```bash
  flutter pub get
  ```

- [ ] Verified all packages downloaded successfully
- [ ] No dependency conflicts

## 🏗️ Build Verification

- [ ] Cleaned project
  ```bash
  flutter clean
  ```

- [ ] Got dependencies again
  ```bash
  flutter pub get
  ```

- [ ] Checked for errors
  ```bash
  flutter analyze
  ```

## 🚀 First Run

- [ ] Connected device or started emulator
- [ ] Verified device is detected
  ```bash
  flutter devices
  ```

- [ ] Run the app
  ```bash
  flutter run
  ```

- [ ] App launched successfully
- [ ] No build errors
- [ ] Phone input screen displayed

## ✅ Functionality Testing

- [ ] Entered test phone number: +1 650 555 1234
- [ ] Clicked "Send OTP"
- [ ] Navigated to OTP screen
- [ ] Entered test code: 123456
- [ ] Clicked "Verify"
- [ ] Successfully navigated to Home screen
- [ ] Phone number displayed correctly
- [ ] Clicked "Sign Out"
- [ ] Returned to Phone Input screen

## 🔄 Real Phone Testing (Optional)

- [ ] Firebase Blaze plan enabled (for SMS)
- [ ] Entered real phone number
- [ ] Received SMS with OTP
- [ ] Entered OTP code
- [ ] Successfully verified
- [ ] Signed out successfully

## 📊 Production Readiness (When Ready)

- [ ] Updated app name and package ID
- [ ] Added app icon
- [ ] Added splash screen
- [ ] Configured release signing (Android)
- [ ] Added release SHA-1 to Firebase
- [ ] Configured iOS signing (if applicable)
- [ ] Tested release build
- [ ] Set up Firebase App Check
- [ ] Implemented rate limiting
- [ ] Added analytics (optional)
- [ ] Added crash reporting (optional)

## 🐛 Troubleshooting Completed

If you encountered issues, mark them as resolved:

- [ ] Fixed "Internal error occurred" (SHA-1 issue)
- [ ] Fixed "App not authorized" (google-services.json issue)
- [ ] Fixed build errors (flutter clean)
- [ ] Fixed SMS not received (test numbers or billing)
- [ ] Fixed iOS build issues (pod install)

## 📚 Documentation Review

- [ ] Read README.md
- [ ] Read SETUP_INSTRUCTIONS.md
- [ ] Read COMPLETE_SETUP_GUIDE.md
- [ ] Reviewed APP_FLOW.md
- [ ] Bookmarked QUICK_REFERENCE.md

## 🎯 Optional: Django Backend

If setting up Django backend:

- [ ] Python installed
- [ ] Created virtual environment
- [ ] Installed requirements
  ```bash
  pip install -r django_backend/requirements.txt
  ```
- [ ] Created Django project
- [ ] Downloaded Firebase service account key
- [ ] Configured Django settings
- [ ] Created users app
- [ ] Run migrations
- [ ] Tested API endpoints
- [ ] Integrated with Flutter app

## ✨ Final Verification

- [ ] App runs without errors
- [ ] Phone authentication works
- [ ] OTP verification works
- [ ] Sign out works
- [ ] UI looks good
- [ ] No console errors
- [ ] Tested on multiple devices (if available)
- [ ] Ready for further development

---

## 📝 Notes

Use this space to track any custom changes or issues:

```
Date: _______________
Notes:
_____________________
_____________________
_____________________
```

---

## 🎉 Completion

When all items are checked:

**Status:** ✅ Setup Complete!

**Next Steps:**
1. Customize UI/UX as needed
2. Add additional features
3. Implement business logic
4. Prepare for production deployment

---

**Setup Date:** _______________
**Completed By:** _______________
**Time Taken:** _______________
