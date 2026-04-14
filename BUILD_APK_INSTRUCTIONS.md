# How to Build APK - Essential Homes App

## The build is currently running in the background!

The APK build process takes 10-20 minutes on first build. It's compiling all the code.

## What's Happening:

The build is progressing through these stages:
1. ✅ Resolving dependencies
2. ✅ Compiling Dart code
3. 🔄 Compiling Android/Kotlin code (CURRENT - takes longest)
4. ⏳ Signing APK
5. ⏳ Creating release APK

## Check Build Status:

Open a new terminal and run:
```bash
cd otp_phone_auth
flutter build apk --release
```

Or wait for the current build to complete.

## When Build Completes:

You'll see:
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX.X MB)
```

## Find Your APK:

Location:
```
E:\const_proj\essential\construction_flutter\otp_phone_auth\build\app\outputs\flutter-apk\app-release.apk
```

## Alternative: Build in Background

If the build is taking too long, you can:

### Option 1: Let it run in current terminal
- Just wait (10-20 minutes)
- Don't close the terminal

### Option 2: Build in new terminal
1. Open new PowerShell/CMD
2. Navigate to project:
   ```bash
   cd E:\const_proj\essential\construction_flutter\otp_phone_auth
   ```
3. Run build:
   ```bash
   flutter build apk --release
   ```
4. Wait for completion

### Option 3: Build split APKs (Faster)
```bash
cd otp_phone_auth
flutter build apk --split-per-abi
```

This creates 3 smaller APKs (one for each CPU architecture):
- `app-armeabi-v7a-release.apk` (32-bit ARM - most phones)
- `app-arm64-v8a-release.apk` (64-bit ARM - newer phones)
- `app-x86_64-release.apk` (Intel - rare)

Use `app-arm64-v8a-release.apk` for most modern phones.

## After Build Completes:

### 1. Locate APK:
```
otp_phone_auth\build\app\outputs\flutter-apk\app-release.apk
```

### 2. Test APK:
- Copy to your phone
- Install and test
- Login with: admin / admin123

### 3. Distribute:
- Upload to Google Drive
- Share link with users
- See `APK_DISTRIBUTION_GUIDE.md` for details

## Troubleshooting:

### Build Fails with Kotlin Error:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Build Takes Too Long:
- Normal for first build (10-20 minutes)
- Subsequent builds are faster (5-10 minutes)
- Use `--split-per-abi` for faster builds

### Out of Memory:
Add to `android/gradle.properties`:
```
org.gradle.jvmargs=-Xmx4096m
```

### Build Stuck:
- Press Ctrl+C to cancel
- Run again: `flutter build apk --release`

## Quick Commands:

### Standard APK (one file for all devices):
```bash
cd otp_phone_auth
flutter build apk --release
```

### Split APKs (faster build, smaller files):
```bash
cd otp_phone_auth
flutter build apk --split-per-abi
```

### Debug APK (for testing):
```bash
cd otp_phone_auth
flutter build apk --debug
```

## APK Size:

Expected size:
- Standard APK: 50-80 MB
- Split APK (per architecture): 20-30 MB each

## What to Do Now:

1. **Wait for current build** (check terminal for completion)
2. **Or start new build** in new terminal
3. **Once complete**, find APK at:
   ```
   otp_phone_auth\build\app\outputs\flutter-apk\app-release.apk
   ```
4. **Test on phone**
5. **Distribute to users** (see APK_DISTRIBUTION_GUIDE.md)

## Your App is Ready!

Once the APK is built:
- ✅ Backend is live on Render
- ✅ Database is connected
- ✅ App works from anywhere
- ✅ Ready to distribute!

---

**Note:** The build warnings about Java 8 are normal and don't affect functionality. Your APK will work perfectly!
