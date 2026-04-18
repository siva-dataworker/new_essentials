# Run Flutter on Mobile - Complete Guide

## Quick Start

### Option 1: Use the Batch File (Easiest)
```bash
run_on_mobile.bat
```

This will automatically:
1. Clean Flutter cache
2. Clean Gradle cache
3. Delete build folders
4. Get dependencies
5. Run on connected device

### Option 2: Manual Steps

```bash
# Navigate to project
cd essential/essential/construction_flutter/otp_phone_auth

# Clean everything
flutter clean

# Clean Gradle (Windows)
cd android
rmdir /s /q .gradle
rmdir /s /q app\build
gradlew clean
cd ..

# Get dependencies
flutter pub get

# Run on mobile
flutter run
```

## What We Fixed

### 1. Updated gradle.properties
Added these settings to fix Kotlin daemon issues:

```properties
# Enable Gradle daemon
org.gradle.daemon=true

# Enable parallel builds
org.gradle.parallel=true

# Enable configuration cache
org.gradle.configuration-cache=true

# Kotlin daemon options
kotlin.daemon.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G

# Enable incremental compilation
kotlin.incremental=true
```

### 2. Increased Memory Allocation
Already configured with high memory:
- Gradle JVM: 8GB
- Kotlin daemon: 4GB
- MetaSpace: 4GB

## Troubleshooting

### Error: "Daemon compilation failed"

**Solution 1: Kill Gradle Daemon**
```bash
cd android
gradlew --stop
cd ..
flutter clean
flutter run
```

**Solution 2: Delete Gradle Cache**
```bash
# Delete these folders:
android\.gradle
android\app\build
build
.dart_tool
```

**Solution 3: Restart Computer**
Sometimes the Gradle daemon gets stuck and needs a full restart.

### Error: "No devices found"

**Check connected devices:**
```bash
flutter devices
```

**Enable USB Debugging on Android:**
1. Go to Settings → About Phone
2. Tap "Build Number" 7 times
3. Go to Settings → Developer Options
4. Enable "USB Debugging"
5. Connect phone via USB
6. Accept debugging prompt on phone

### Error: "Gradle build failed"

**Update Gradle wrapper:**
```bash
cd android
gradlew wrapper --gradle-version=8.0
cd ..
flutter run
```

### Error: "Kotlin version mismatch"

**Check android/build.gradle:**
```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

## Performance Tips

### 1. Use Release Mode for Testing
```bash
flutter run --release
```
Much faster than debug mode.

### 2. Use Profile Mode for Performance Testing
```bash
flutter run --profile
```

### 3. Hot Reload During Development
After app is running, press:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

## Expected Build Time

- **First build**: 5-10 minutes (downloads dependencies)
- **Clean build**: 2-5 minutes
- **Incremental build**: 30-60 seconds
- **Hot reload**: 1-3 seconds

## Verify Theme Changes

After the app runs, check these accountant pages:

### 1. Reports Screen
- ✅ White background (not dark blue)
- ✅ Dark blue buttons
- ✅ Black text

### 2. Entry Screen (Site Selection)
- ✅ White background (not dark blue)
- ✅ White cards
- ✅ Dark blue selected chips

### 3. Entry Screen (Site Content)
- ✅ White background (not dark blue)
- ✅ Dark blue role chips when selected
- ✅ Dark blue tab chips when selected

### 4. All Accountant Pages
- ✅ White backgrounds
- ✅ Black primary text
- ✅ Grey secondary text
- ✅ Dark blue buttons
- ✅ Dark blue selected states

## Alternative: Run on Emulator

### Start Android Emulator
```bash
# List available emulators
flutter emulators

# Start an emulator
flutter emulators --launch <emulator_id>

# Run on emulator
flutter run
```

### Create New Emulator
1. Open Android Studio
2. Tools → Device Manager
3. Create Device
4. Select device (e.g., Pixel 6)
5. Download system image
6. Finish

## Commands Reference

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run in release mode
flutter run --release

# Run in profile mode
flutter run --profile

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle

# Install APK
flutter install

# Check Flutter setup
flutter doctor -v

# Upgrade Flutter
flutter upgrade

# Stop Gradle daemon
cd android && gradlew --stop && cd ..
```

## Summary

**Easiest way to run:**
```bash
run_on_mobile.bat
```

**Manual way:**
```bash
flutter clean
flutter pub get
flutter run
```

**If build fails:**
1. Delete `android\.gradle` folder
2. Delete `android\app\build` folder
3. Delete `build` folder
4. Run `flutter clean`
5. Run `flutter pub get`
6. Run `flutter run`

The theme changes (white backgrounds, dark blue buttons) are now ready to test on mobile!
