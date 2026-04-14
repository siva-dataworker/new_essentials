# Flutter OTP Phone Authentication with Firebase

A complete Flutter application for phone number verification using Firebase Authentication.

## Features

- 📱 Phone number input with country code selection
- 🔐 OTP verification with 6-digit PIN input
- ✅ Firebase Authentication integration
- 🎨 Clean and modern UI
- 🔄 Loading states and error handling

## Prerequisites

- Flutter SDK (3.0+)
- Firebase account
- Node.js (for Firebase CLI)

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or use your existing project
3. Follow the setup wizard

### 2. Enable Phone Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Phone** provider
3. Add your test phone numbers if needed (for development)

### 3. Configure Firebase for Flutter

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Navigate to project directory
cd otp_phone_auth

# Configure Firebase
flutterfire configure
```

This will automatically:
- Create/update `firebase_options.dart`
- Configure Android and iOS apps
- Download necessary config files

#### Option B: Manual Configuration

**For Android:**

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Update `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

4. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // Required for Firebase Auth
    }
}
```

**For iOS:**

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` in Xcode
3. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

### 4. Android SHA-1 Configuration (Important!)

For phone authentication to work on Android, you need to add SHA-1 fingerprint:

```bash
# Get debug SHA-1
cd android
./gradlew signingReport

# Or on Windows
gradlew.bat signingReport
```

Copy the SHA-1 and add it in Firebase Console:
- Go to Project Settings > Your Android App
- Add the SHA-1 fingerprint

## Installation

1. Clone or navigate to the project:
```bash
cd otp_phone_auth
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
└── screens/
    ├── phone_auth_screen.dart         # Phone number input
    ├── otp_verification_screen.dart   # OTP verification
    └── home_screen.dart               # Success screen
```

## Testing

### Test Phone Numbers

For development, add test phone numbers in Firebase Console:
- Go to Authentication > Sign-in method > Phone
- Add test phone numbers with verification codes

Example:
- Phone: +1 650-555-1234
- Code: 123456

## Common Issues

### 1. "An internal error has occurred"
- Ensure SHA-1 is added to Firebase Console
- Check if Phone Authentication is enabled
- Verify `google-services.json` is in the correct location

### 2. SMS not received
- Check phone number format (include country code)
- Verify Firebase project has billing enabled (required for SMS)
- Use test phone numbers for development

### 3. iOS build issues
- Run `cd ios && pod install`
- Ensure minimum iOS version is 12.0+

## Dependencies

```yaml
firebase_core: ^3.8.1        # Firebase core functionality
firebase_auth: ^5.3.3        # Firebase authentication
pinput: ^5.0.0               # OTP input widget
intl_phone_field: ^3.2.0     # Phone number input with country codes
```

## Optional: Django Backend Integration

If you need a Django backend for additional user management:

### Django Setup

1. Create Django project:
```bash
django-admin startproject backend
cd backend
python manage.py startapp users
```

2. Install Firebase Admin SDK:
```bash
pip install firebase-admin djangorestframework
```

3. Create Firebase verification middleware:
```python
# users/middleware.py
from firebase_admin import auth, credentials, initialize_app
import firebase_admin

if not firebase_admin._apps:
    cred = credentials.Certificate('path/to/serviceAccountKey.json')
    initialize_app(cred)

def verify_firebase_token(id_token):
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except Exception as e:
        return None
```

4. Create API endpoint:
```python
# users/views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .middleware import verify_firebase_token

@api_view(['POST'])
def verify_user(request):
    token = request.headers.get('Authorization')
    user = verify_firebase_token(token)
    if user:
        # Save user to database or perform other operations
        return Response({'status': 'success', 'uid': user['uid']})
    return Response({'status': 'error'}, status=401)
```

## License

MIT License

## Support

For issues and questions:
- Firebase Documentation: https://firebase.google.com/docs/auth/flutter/phone-auth
- Flutter Documentation: https://flutter.dev/docs
