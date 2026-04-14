# Quick Setup Guide

## Step-by-Step Setup

### 1. Install Dependencies
```bash
cd otp_phone_auth
flutter pub get
```

### 2. Configure Firebase (Choose one method)

#### Method A: FlutterFire CLI (Easiest)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (this will prompt you to select your Firebase project)
flutterfire configure
```

#### Method B: Manual Setup

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project** (constructionsite-8d964 based on your screenshot)
3. **Enable Phone Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Phone" provider

4. **Add Android App**:
   - Click "Add app" → Android
   - Package name: `com.example.otp_phone_auth` (or your custom package)
   - Download `google-services.json`
   - Place in `android/app/`

5. **Get SHA-1 Certificate**:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy SHA-1 and add to Firebase Console (Project Settings → Your App)

6. **Update firebase_options.dart**:
   Replace the placeholder values with your actual Firebase config values from Firebase Console

### 3. Update Android Configuration

Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Change from 16 to 21
    }
}
```

### 4. Run the App
```bash
flutter run
```

## Testing with Test Phone Numbers

1. Go to Firebase Console → Authentication → Sign-in method → Phone
2. Scroll to "Phone numbers for testing"
3. Add test numbers:
   - Phone: +1 234 567 8900
   - Code: 123456

## Important Notes

- **Billing**: Firebase requires Blaze (pay-as-you-go) plan for SMS in production
- **SHA-1**: Required for Android phone auth to work
- **Test Numbers**: Use test phone numbers during development to avoid SMS costs
- **Country Code**: Always include country code (e.g., +1 for US)

## Troubleshooting

### "An internal error has occurred"
→ Add SHA-1 certificate to Firebase Console

### "This app is not authorized to use Firebase Authentication"
→ Ensure `google-services.json` is in `android/app/`

### SMS not received
→ Check Firebase billing is enabled or use test phone numbers

### Build errors
→ Run `flutter clean && flutter pub get`
