# 🤖 Run on Android Instead of Web

## Issue
Your app is running on **web** (localhost:53056) but Google Sign-In needs additional web configuration.

For your construction management app, you should run on **Android** device/emulator.

---

## ✅ Solution: Run on Android

### Step 1: Check Available Devices

```cmd
flutter devices
```

This will show:
- Android emulators
- Connected Android phones
- Chrome (web)
- Windows desktop

### Step 2: Start Android Emulator (if needed)

If no Android device is shown, start an emulator from Android Studio or run:

```cmd
flutter emulators
flutter emulators --launch <emulator-id>
```

### Step 3: Run on Android

```cmd
flutter run -d <device-id>
```

Or simply:
```cmd
flutter run
```

Then select the Android device from the list.

---

## Quick Fix: Disable Web

To prevent Flutter from running on web by default, you can:

### Option 1: Specify Android Device

```cmd
flutter run -d android
```

### Option 2: Close Chrome

Close the Chrome window and Flutter will ask you to select another device.

---

## Why Android Instead of Web?

1. **Google Sign-In** works better on mobile
2. **Camera/Photos** - Your app needs image picker
3. **Native Features** - Better performance
4. **Real Testing** - Test on actual target platform

---

## If You Must Use Web

You need to add web client ID to `web/index.html`:

```html
<meta name="google-signin-client-id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

But **Android is recommended** for your construction app!

---

## Commands Summary

```cmd
# Check devices
flutter devices

# Run on Android
flutter run -d android

# Or run and select device
flutter run
```

---

**Run this now:**
```cmd
flutter devices
```

Then run on Android device! 🤖
