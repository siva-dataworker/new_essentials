# Google Sign-In Setup Guide

## Overview
This app now uses Google Sign-In instead of phone authentication for a better user experience.

## Prerequisites
- Google Cloud Console project
- Supabase project with Google OAuth enabled

---

## Step 1: Get SHA-1 and SHA-256 Keys

### For Debug Build (Development):
```cmd
cd otp_phone_auth\android
gradlew signingReport
```

Or using keytool:
```cmd
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Copy the SHA-1 and SHA-256 fingerprints from the output.

### For Release Build (Production):
```cmd
keytool -list -v -keystore path\to\your\release.keystore -alias your_alias
```

---

## Step 2: Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project or create a new one
3. Enable **Google+ API** (if not already enabled)
4. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**

### Create Android OAuth Client:
- Application type: **Android**
- Name: `Essential Homes Android`
- Package name: `com.example.essential_homes`
- SHA-1 certificate fingerprint: (paste your SHA-1 from Step 1)
- Click **Create**

### Create Web OAuth Client (for Supabase):
- Application type: **Web application**
- Name: `Essential Homes Web`
- Authorized redirect URIs: `https://YOUR_SUPABASE_PROJECT_ID.supabase.co/auth/v1/callback`
- Click **Create**
- **Save the Client ID and Client Secret** - you'll need these for Supabase

---

## Step 3: Configure Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Go to **Authentication** → **Providers**
4. Find **Google** and enable it
5. Enter the **Client ID** and **Client Secret** from the Web OAuth Client (Step 2)
6. Click **Save**

---

## Step 4: Update Android Configuration

The package name is already set to `com.example.essential_homes` in:
- `android/app/build.gradle.kts`

No additional changes needed unless you want to customize the package name.

---

## Step 5: Install Dependencies

```cmd
cd otp_phone_auth
flutter pub get
```

---

## Step 6: Test the Implementation

1. Run the app:
```cmd
flutter run
```

2. Click "Continue with Google"
3. Select your Google account
4. Complete the profile form (for new users)
5. You should be signed in!

---

## Troubleshooting

### Error: "Sign in failed: PlatformException"
- Make sure SHA-1 is correctly added to Google Cloud Console
- Verify package name matches: `com.example.essential_homes`
- Try cleaning and rebuilding:
```cmd
flutter clean
flutter pub get
flutter run
```

### Error: "No ID Token found"
- Check that Google OAuth is enabled in Supabase
- Verify Client ID and Secret are correct in Supabase settings

### Error: "Developer Error" on Google Sign-In screen
- SHA-1 fingerprint is missing or incorrect in Google Cloud Console
- Package name doesn't match

### Sign-In works but profile not created
- Check Supabase database permissions
- Verify `users` table exists with correct schema

---

## Production Checklist

Before releasing to production:

1. ✅ Generate release keystore
2. ✅ Get SHA-1 from release keystore
3. ✅ Add release SHA-1 to Google Cloud Console
4. ✅ Update Supabase redirect URIs if needed
5. ✅ Test sign-in with release build
6. ✅ Configure proper signing in `android/app/build.gradle.kts`

---

## Files Modified

- ✅ `pubspec.yaml` - Added `google_sign_in` package
- ✅ `lib/screens/google_auth_screen.dart` - New Google Sign-In screen
- ✅ `lib/services/google_auth_service.dart` - Google authentication service
- ✅ `lib/screens/splash_screen.dart` - Updated to use Google auth
- ✅ Old phone auth screens remain for reference but are not used

---

## Next Steps

1. Get your SHA-1 key (see Step 1)
2. Configure Google Cloud Console (Step 2)
3. Configure Supabase (Step 3)
4. Run `flutter pub get`
5. Test the app!

Need help? Check the troubleshooting section above.
