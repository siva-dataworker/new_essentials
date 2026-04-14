# 🔥 Firebase CLI Installation & FlutterFire Setup

## Current Issue

You tried to run `flutterfire configure` but got this error:
```
The FlutterFire CLI currently requires the official Firebase CLI to also be installed
```

## Solution: Install Firebase CLI First

### Option 1: Using npm (Recommended - Fastest)

If you have Node.js installed:

```cmd
npm install -g firebase-tools
```

Verify installation:
```cmd
firebase --version
```

### Option 2: Standalone Installer (No Node.js needed)

1. Download Firebase CLI installer:
   - **Windows**: https://firebase.tools/bin/win/instant/latest

2. Run the downloaded installer

3. Restart your terminal/command prompt

4. Verify:
   ```cmd
   firebase --version
   ```

### Option 3: Using Chocolatey (Windows Package Manager)

If you have Chocolatey:
```cmd
choco install firebase-cli
```

---

## After Installing Firebase CLI

### Step 1: Login to Firebase

```cmd
firebase login
```

This will open your browser to authenticate with Google.

### Step 2: Run FlutterFire Configure

```cmd
cd otp_phone_auth
flutterfire configure --project=construction-4a98c
```

This will:
- ✅ Connect to your Firebase project
- ✅ Auto-generate `lib/firebase_options.dart`
- ✅ Configure Android, iOS, Web, etc.

### Step 3: Add Firebase Dependencies

Update `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  google_sign_in: ^6.2.1  # Already added ✅
```

Run:
```cmd
flutter pub get
```

### Step 4: Initialize Firebase in Your App

Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Supabase
  await SupabaseService.initialize(
    supabaseUrl: SupabaseConfig.supabaseUrl,
    supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}
```

### Step 5: Enable Google Sign-In in Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **construction-4a98c**
3. Click **Authentication** → **Get Started**
4. Click **Sign-in method** tab
5. Enable **Google**
6. Set support email
7. Click **Save**

### Step 6: Get SHA-1 and Add to Firebase

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

### Step 7: Test!

```cmd
flutter run
```

---

## 🎯 Quick Command Summary

```cmd
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login
firebase login

# 3. Configure FlutterFire
cd otp_phone_auth
flutterfire configure --project=construction-4a98c

# 4. Add dependencies
flutter pub get

# 5. Get SHA-1
get_sha1.bat

# 6. Run app
flutter run
```

---

## 🐛 Troubleshooting

### "npm is not recognized"

You need to install Node.js first:
- Download: https://nodejs.org/
- Install the LTS version
- Restart terminal
- Try again: `npm install -g firebase-tools`

### "firebase is not recognized"

After installing Firebase CLI:
1. Close and reopen your terminal
2. Try: `firebase --version`
3. If still not working, restart your computer

### FlutterFire configure fails

Make sure:
- Firebase CLI is installed: `firebase --version`
- You're logged in: `firebase login`
- Project exists: `construction-4a98c`

---

## ✅ What You'll Get

After completing these steps:

- ✅ `lib/firebase_options.dart` - Auto-generated Firebase config
- ✅ Firebase initialized in your app
- ✅ Google Sign-In enabled
- ✅ SHA-1 configured
- ✅ Ready to test authentication!

---

## 📚 Resources

- Firebase CLI Docs: https://firebase.google.com/docs/cli
- FlutterFire Docs: https://firebase.flutter.dev/docs/overview
- Google Sign-In: https://firebase.google.com/docs/auth/flutter/federated-auth

---

## Next Steps

Once Firebase is configured:
1. Test Google Sign-In in your app
2. Connect authenticated users to Supabase backend
3. Store user data in Django backend
4. Build role-based dashboards
