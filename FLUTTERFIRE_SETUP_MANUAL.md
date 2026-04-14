# 🔥 FlutterFire Manual Setup Guide

## Current Situation

FlutterFire CLI is installed but couldn't find the project `construction-4a98c`. This could be because:
1. The project doesn't exist yet
2. You're logged in with a different Google account
3. The project is under a different account

## Solution: Create Firebase Project Manually

### Step 1: Create Firebase Project in Console

1. Go to: https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**
3. **Project name**: Essential Homes (or any name you want)
4. **Project ID**: Will be auto-generated (like `essential-homes-xxxxx`)
5. Click **Continue**
6. Disable Google Analytics (optional)
7. Click **Create project**
8. Wait for project creation
9. Click **Continue**

### Step 2: Add Android App

1. In Firebase Console, click **Android icon** (or "Add app")
2. **Android package name**: `com.example.otp_phone_auth`
3. **App nickname**: Essential Homes (optional)
4. Click **"Register app"**

### Step 3: Get SHA-1 Fingerprint

Open a new terminal and run:
```cmd
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth
get_sha1.bat
```

Copy the SHA-1 output and paste it in Firebase Console, then click **"Register app"**

### Step 4: Download google-services.json

1. Click **"Download google-services.json"**
2. Save the file
3. Move it to: `otp_phone_auth\android\app\google-services.json`

### Step 5: Configure FlutterFire with Your New Project

Once you have the project ID from Step 1, run:

```cmd
cd otp_phone_auth
C:\Users\Admin\AppData\Local\Pub\Cache\bin\flutterfire configure --project=YOUR-PROJECT-ID
```

Replace `YOUR-PROJECT-ID` with the actual project ID from Firebase Console.

### Step 6: Enable Google Sign-In

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Click **"Sign-in method"** tab
4. Click **Google**
5. Toggle **Enable**
6. Select support email
7. Click **Save**

### Step 7: Update pubspec.yaml

Already done! ✅ Firebase dependencies are added.

### Step 8: Update main.dart

Replace `otp_phone_auth/lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/supabase_service.dart';
import 'config/supabase_config.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essential Homes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
```

### Step 9: Get Dependencies

```cmd
flutter pub get
```

### Step 10: Run Your App!

```cmd
flutter run
```

---

## Alternative: Use Existing Project

If you already have a Firebase project:

1. Go to: https://console.firebase.google.com/
2. Find your project
3. Note the **Project ID** (shown in project settings)
4. Run:
   ```cmd
   cd otp_phone_auth
   C:\Users\Admin\AppData\Local\Pub\Cache\bin\flutterfire configure --project=YOUR-ACTUAL-PROJECT-ID
   ```

---

## Quick Commands

```cmd
# 1. Get SHA-1
cd otp_phone_auth
get_sha1.bat

# 2. Configure FlutterFire (after creating project)
C:\Users\Admin\AppData\Local\Pub\Cache\bin\flutterfire configure --project=YOUR-PROJECT-ID

# 3. Get dependencies
flutter pub get

# 4. Run app
flutter run
```

---

## Troubleshooting

### "Project not found"
- Make sure you're logged in with the correct Google account
- Verify the project ID is correct
- Check that the project exists in Firebase Console

### "FlutterFire command not found"
Use the full path:
```cmd
C:\Users\Admin\AppData\Local\Pub\Cache\bin\flutterfire configure --project=YOUR-PROJECT-ID
```

### "Permission denied"
Run PowerShell as Administrator

---

## Next Steps

1. Create Firebase project in console
2. Get the project ID
3. Run flutterfire configure with that project ID
4. Download google-services.json
5. Enable Google Sign-In
6. Update main.dart
7. Run app!

---

**Start here: https://console.firebase.google.com/** 🚀
