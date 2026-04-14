# 🔑 Get SHA-1 Fingerprint

## You're at this step in Firebase Console:

Firebase is asking for SHA-1 fingerprint to enable Google Sign-In.

## How to Get SHA-1

### Option 1: Using get_sha1.bat (Easiest)

Open a **NEW** terminal and run:

```cmd
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth
get_sha1.bat
```

This will output something like:
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

Copy the SHA-1 value.

### Option 2: Using Gradle Command

```cmd
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth\android
gradlew signingReport
```

Look for the **debug** section and copy the SHA1 value.

---

## After Getting SHA-1

1. **Copy the SHA-1** value (the long string with colons)
2. Go back to Firebase Console
3. **Paste it** in the SHA-1 field
4. Click **"Register app"**
5. **Download google-services.json** (you already have this ✅)
6. Click **"Next"** and **"Continue to console"**

---

## Then in Firebase Console

1. Make sure **Google Sign-In is enabled** (toggle should be blue/on)
2. **Public-facing name**: project-127758805754 (already filled ✅)
3. **Support email**: sivabalan.dataworker@gmail.com (already filled ✅)
4. Click **"Save"**

---

## After Saving

Run these commands:

```cmd
cd C:\Users\Admin\Downloads\construction_flutter\otp_phone_auth
flutter pub get
flutter run
```

---

## Quick Summary

1. Run `get_sha1.bat` in otp_phone_auth folder
2. Copy the SHA-1 output
3. Paste in Firebase Console
4. Click "Register app"
5. Enable Google Sign-In (toggle on)
6. Save
7. Run `flutter pub get` and `flutter run`

---

**Your configuration files are correct!** ✅

Just need to add SHA-1 and enable Google Sign-In in Firebase Console.
