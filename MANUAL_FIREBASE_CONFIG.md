# 🔧 Manual Firebase Configuration

## Issue
FlutterFire CLI is having trouble connecting to Firebase. Let's configure manually.

## Your Firebase Project
**Project ID**: `site-3de91`

## Manual Setup Steps

### Step 1: Add Android App in Firebase Console

1. Go to: https://console.firebase.google.com/project/site-3de91
2. Click the **Android icon** (or "Add app" if no apps exist)
3. **Android package name**: `com.example.otp_phone_auth`
4. **App nickname**: Essential Homes (optional)
5. Click **"Register app"**

### Step 2: Get SHA-1 Fingerprint

Run this in a NEW terminal:
```cmd
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth
get_sha1.bat
```

Copy the SHA-1 and paste it in Firebase Console, then click **"Register app"**

### Step 3: Download google-services.json

1. Click **"Download google-services.json"**
2. Save the file
3. Move it to: `C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth\android\app\google-services.json`

### Step 4: Add Firebase SDK to Android

Edit `android/build.gradle.kts` - add this to dependencies:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

Edit `android/app/build.gradle.kts` - add at the top after other plugins:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

And add to dependencies:
```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
```

### Step 5: Create firebase_options.dart Manually

Create file: `lib/firebase_options.dart`

```dart
// File generated manually for Firebase project: site-3de91
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'site-3de91',
    authDomain: 'site-3de91.firebaseapp.com',
    storageBucket: 'site-3de91.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'site-3de91',
    storageBucket: 'site-3de91.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'site-3de91',
    storageBucket: 'site-3de91.appspot.com',
    iosBundleId: 'com.example.otpPhoneAuth',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'site-3de91',
    storageBucket: 'site-3de91.appspot.com',
    iosBundleId: 'com.example.otpPhoneAuth',
  );
}
```

**Note**: You'll need to get the actual API keys from Firebase Console → Project Settings → Your apps

### Step 6: Enable Google Sign-In

1. Firebase Console: https://console.firebase.google.com/project/site-3de91
2. Go to **Authentication** → **Get started**
3. Click **Sign-in method** tab
4. Enable **Google**
5. Add support email
6. Click **Save**

### Step 7: Update main.dart

Already have the example in `lib/main_with_firebase.dart.example`

### Step 8: Run

```cmd
flutter pub get
flutter run
```

---

## Easier Alternative: Use Firebase Console Directly

Since FlutterFire CLI is having issues, the easiest way is:

1. **Add Android app** in Firebase Console
2. **Download google-services.json** and place in `android/app/`
3. **Get API keys** from Firebase Console → Project Settings
4. **Create firebase_options.dart** with those keys
5. **Enable Google Sign-In** in Authentication
6. **Run the app**

---

## Get API Keys from Firebase Console

1. Go to: https://console.firebase.google.com/project/site-3de91/settings/general
2. Scroll to **Your apps**
3. Click on your Android app
4. You'll see:
   - **App ID**
   - **API Key**
   - **Sender ID**

Use these values in `firebase_options.dart`

---

**Start here: https://console.firebase.google.com/project/site-3de91** 🚀
