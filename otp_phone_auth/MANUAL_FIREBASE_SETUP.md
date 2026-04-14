# Manual Firebase Setup Guide

Since FlutterFire CLI requires Firebase CLI installation, follow these manual steps:

## 📱 Step-by-Step Manual Configuration

### Step 1: Register Android App in Firebase

1. Open Firebase Console: https://console.firebase.google.com/u/6/project/constructionsite-8d964/overview

2. Click the **Android icon** (or "Add app" if you see it)

3. Fill in the form:
   - **Android package name:** `com.example.otp_phone_auth`
   - **App nickname:** `OTP Phone Auth` (optional)
   - **Debug signing certificate SHA-1:** (we'll add this in Step 3)

4. Click **"Register app"**

5. **Download `google-services.json`**

6. **Place the file here:** `otp_phone_auth/android/app/google-services.json`

### Step 2: Update firebase_options.dart

Open the `google-services.json` file you just downloaded and find these values:

```json
{
  "project_info": {
    "project_id": "YOUR_PROJECT_ID",
    "project_number": "YOUR_PROJECT_NUMBER"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_APP_ID"
      },
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ]
    }
  ]
}
```

Then update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',  // from google-services.json
  appId: 'YOUR_APP_ID',    // mobilesdk_app_id
  messagingSenderId: 'YOUR_PROJECT_NUMBER',  // project_number
  projectId: 'constructionsite-8d964',  // project_id
  storageBucket: 'constructionsite-8d964.appspot.com',
);
```

### Step 3: Get SHA-1 Certificate

Open a **NEW** PowerShell window (close the current one if flutterfire is still running):

```powershell
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth\android
.\gradlew.bat signingReport
```

Look for output like this:
```
Variant: debug
Config: debug
Store: C:\Users\Admin\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
SHA-256: XX:XX:XX:...
```

**Copy the SHA1 line** (the long string with colons)

### Step 4: Add SHA-1 to Firebase

1. Go to Firebase Console → Project Settings
2. Scroll down to "Your apps" section
3. Find your Android app
4. Click "Add fingerprint"
5. Paste the SHA-1 you copied
6. Click "Save"

### Step 5: Enable Phone Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Sign-in method"** tab
3. Find **"Phone"** in the list
4. Click on it
5. Toggle **"Enable"**
6. Click **"Save"**

### Step 6: Add Test Phone Numbers (Optional but Recommended)

1. Still in Authentication → Sign-in method → Phone
2. Scroll down to **"Phone numbers for testing"**
3. Click **"Add phone number"**
4. Enter:
   - Phone number: `+1 650 555 1234`
   - Verification code: `123456`
5. Click **"Add"**

### Step 7: Run the App

```powershell
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth
flutter run
```

### Step 8: Test

1. Enter phone: `+1 650 555 1234`
2. Click "Send OTP"
3. Enter code: `123456`
4. Success! 🎉

---

## 🔧 Alternative: Install Firebase CLI (For Future Use)

If you want to use FlutterFire CLI in the future:

### Option 1: Using npm (if you have Node.js)
```powershell
npm install -g firebase-tools
```

### Option 2: Using Standalone Binary
1. Download from: https://firebase.google.com/docs/cli#windows-standalone-binary
2. Extract and add to PATH
3. Run: `firebase login`

Then you can use:
```powershell
flutterfire configure
```

---

## ✅ Verification Checklist

- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] `firebase_options.dart` updated with correct values
- [ ] SHA-1 certificate generated
- [ ] SHA-1 added to Firebase Console
- [ ] Phone authentication enabled
- [ ] Test phone number added
- [ ] App runs without errors

---

## 🐛 Troubleshooting

### "An internal error has occurred"
→ Make sure SHA-1 is added to Firebase Console

### "This app is not authorized"
→ Verify `google-services.json` is in `android/app/`

### Build errors
→ Run: `flutter clean && flutter pub get`

---

## 📞 Need Help?

If you get stuck, share:
1. The error message you're seeing
2. Which step you're on
3. Screenshot if helpful

I'll help you resolve it!
    