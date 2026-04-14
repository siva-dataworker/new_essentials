# Complete Setup Guide - Flutter OTP Phone Authentication

## 🚀 Quick Start (5 Minutes)

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Configure Firebase
```bash
cd otp_phone_auth
flutterfire configure
```
- Select your Firebase project: **constructionsite-8d964**
- Select platforms: Android, iOS (use spacebar to select)
- This will automatically generate `firebase_options.dart`

### Step 3: Enable Phone Authentication in Firebase
1. Open [Firebase Console](https://console.firebase.google.com/u/6/project/constructionsite-8d964/overview)
2. Go to **Authentication** → **Sign-in method**
3. Click **Phone** → **Enable** → **Save**

### Step 4: Add SHA-1 for Android (Required!)
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 fingerprint and add it:
1. Firebase Console → Project Settings → Your Android App
2. Click "Add fingerprint"
3. Paste SHA-1

### Step 5: Update Android Min SDK
Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21  // Change from flutter.minSdkVersion
}
```

### Step 6: Run the App
```bash
flutter run
```

---

## 📱 Testing the App

### Option 1: Use Test Phone Numbers (No SMS Cost)
1. Firebase Console → Authentication → Sign-in method → Phone
2. Scroll to "Phone numbers for testing"
3. Add:
   - Phone: `+1 650 555 1234`
   - Code: `123456`
4. Use these in the app (no real SMS sent)

### Option 2: Use Real Phone Numbers
- Requires Firebase Blaze (pay-as-you-go) plan
- SMS charges apply
- Works with any valid phone number

---

## 🔧 Detailed Configuration

### Firebase Console Setup

#### 1. Project Overview
Your project: `constructionsite-8d964`
- Project ID: constructionsite-8d964
- Location: us-central

#### 2. Authentication Setup
```
Authentication → Sign-in method → Phone
✓ Enable Phone provider
✓ Add test phone numbers (optional)
```

#### 3. Android App Configuration
```
Project Settings → Your apps → Android
- Package name: com.example.otp_phone_auth
- Download google-services.json → Place in android/app/
- Add SHA-1 certificate fingerprint
```

#### 4. iOS App Configuration (if needed)
```
Project Settings → Your apps → iOS
- Bundle ID: com.example.otpPhoneAuth
- Download GoogleService-Info.plist → Add to ios/Runner/
```

### Android Configuration Files

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        applicationId "com.example.otp_phone_auth"
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

### iOS Configuration (if needed)

**ios/Podfile:**
```ruby
platform :ios, '12.0'
```

Run:
```bash
cd ios
pod install
```

---

## 🎯 App Features

### 1. Phone Number Input Screen
- Country code selector (default: US +1)
- Phone number validation
- Loading state during OTP send

### 2. OTP Verification Screen
- 6-digit PIN input
- Auto-submit on completion
- Resend OTP option
- Error handling

### 3. Home Screen
- Display verified phone number
- Sign out functionality
- Success confirmation

---

## 🐛 Troubleshooting

### Error: "An internal error has occurred"
**Solution:**
1. Add SHA-1 to Firebase Console
2. Ensure `google-services.json` is in `android/app/`
3. Run `flutter clean && flutter pub get`

### Error: "This app is not authorized"
**Solution:**
1. Check package name matches Firebase Console
2. Verify `google-services.json` is correct
3. Rebuild the app

### SMS Not Received
**Solution:**
1. Use test phone numbers for development
2. Check Firebase billing is enabled for production
3. Verify phone number format includes country code

### Build Errors
**Solution:**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
flutter run
```

### iOS Build Issues
**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

---

## 📦 Dependencies Used

```yaml
firebase_core: ^3.8.1          # Firebase SDK
firebase_auth: ^5.3.3          # Phone authentication
pinput: ^5.0.0                 # OTP input widget
intl_phone_field: ^3.2.0       # Phone number input
```

---

## 🔐 Security Best Practices

1. **Never commit Firebase config files to public repos**
   - Add to `.gitignore`
   - Use environment variables for sensitive data

2. **Use test phone numbers during development**
   - Avoid SMS costs
   - Faster testing

3. **Enable App Check (Production)**
   - Prevents abuse
   - Protects against unauthorized access

4. **Implement rate limiting**
   - Prevent spam
   - Use Firebase Security Rules

---

## 🌐 Optional: Django Backend Integration

If you need additional user management, see:
- `django_backend/README.md` - Setup instructions
- `django_backend/users_app_example.py` - Implementation examples

---

## 📚 Additional Resources

- [Firebase Phone Auth Docs](https://firebase.google.com/docs/auth/flutter/phone-auth)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

---

## ✅ Checklist

Before running the app, ensure:

- [ ] FlutterFire CLI installed
- [ ] Firebase project configured (`flutterfire configure`)
- [ ] Phone authentication enabled in Firebase Console
- [ ] SHA-1 added to Firebase Console (Android)
- [ ] `google-services.json` in `android/app/` (Android)
- [ ] Min SDK set to 21 in `android/app/build.gradle`
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Test phone numbers added (optional)

---

## 🎉 You're Ready!

Run the app:
```bash
flutter run
```

Test with:
- Phone: +1 650 555 1234
- OTP: 123456

Enjoy your OTP authentication app! 🚀
