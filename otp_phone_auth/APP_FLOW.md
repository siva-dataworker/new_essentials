# App Flow Diagram

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter OTP Phone Auth                       │
└─────────────────────────────────────────────────────────────────┘

1. PHONE INPUT SCREEN (phone_auth_screen.dart)
   ┌──────────────────────────────────────┐
   │  📱 Enter Your Phone Number          │
   │  ┌────────────────────────────────┐  │
   │  │ Country: +1 (US)              │  │
   │  │ Phone: [_______________]      │  │
   │  └────────────────────────────────┘  │
   │  ┌────────────────────────────────┐  │
   │  │      [Send OTP Button]        │  │
   │  └────────────────────────────────┘  │
   └──────────────────────────────────────┘
                    │
                    │ User enters phone & clicks Send OTP
                    ▼
   ┌──────────────────────────────────────┐
   │   Firebase.verifyPhoneNumber()       │
   │   - Sends SMS with 6-digit code      │
   │   - Returns verificationId           │
   └──────────────────────────────────────┘
                    │
                    │ Navigate to OTP screen
                    ▼

2. OTP VERIFICATION SCREEN (otp_verification_screen.dart)
   ┌──────────────────────────────────────┐
   │  💬 Verification Code                │
   │  Enter code sent to +1 234-567-8900  │
   │  ┌────────────────────────────────┐  │
   │  │  [_] [_] [_] [_] [_] [_]      │  │
   │  └────────────────────────────────┘  │
   │  ┌────────────────────────────────┐  │
   │  │      [Verify Button]          │  │
   │  └────────────────────────────────┘  │
   └──────────────────────────────────────┘
                    │
                    │ User enters OTP code
                    ▼
   ┌──────────────────────────────────────┐
   │   Firebase.signInWithCredential()    │
   │   - Verifies OTP code                │
   │   - Creates user session             │
   └──────────────────────────────────────┘
                    │
                    │ Success → Navigate to Home
                    ▼

3. HOME SCREEN (home_screen.dart)
   ┌──────────────────────────────────────┐
   │  ✅ Phone Verified Successfully!     │
   │                                      │
   │  Phone: +1 234-567-8900             │
   │                                      │
   │  ┌────────────────────────────────┐  │
   │  │      [Sign Out Button]        │  │
   │  └────────────────────────────────┘  │
   └──────────────────────────────────────┘
                    │
                    │ User clicks Sign Out
                    ▼
   ┌──────────────────────────────────────┐
   │   Firebase.signOut()                 │
   │   - Clears user session              │
   └──────────────────────────────────────┘
                    │
                    │ Navigate back to Phone Input
                    ▼
              (Back to Step 1)
```

## Firebase Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                        Firebase Services                         │
└─────────────────────────────────────────────────────────────────┘

Firebase Core (firebase_core)
    │
    ├─► Firebase Auth (firebase_auth)
    │       │
    │       ├─► verifyPhoneNumber()
    │       │   - Sends SMS
    │       │   - Returns verificationId
    │       │
    │       ├─► signInWithCredential()
    │       │   - Verifies OTP
    │       │   - Creates user session
    │       │
    │       └─► signOut()
    │           - Ends user session
    │
    └─► Firebase Options (firebase_options.dart)
        - Platform-specific configuration
        - API keys and project IDs
```

## Optional: Django Backend Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                    Backend Integration Flow                      │
└─────────────────────────────────────────────────────────────────┘

Flutter App                    Django Backend
    │                               │
    │ 1. User verifies OTP          │
    │ ──────────────────────────►   │
    │                               │
    │ 2. Get Firebase ID Token      │
    │ ──────────────────────────►   │
    │                               │
    │ 3. POST /api/users/verify/    │
    │    Authorization: Bearer <token>
    │ ──────────────────────────►   │
    │                               │
    │                          4. Verify token
    │                          with Firebase Admin SDK
    │                               │
    │                          5. Create/Update user
    │                          in database
    │                               │
    │ 6. Return user data           │
    │ ◄──────────────────────────   │
    │                               │
    │ 7. Navigate to Home Screen    │
    │                               │
```

## File Structure

```
otp_phone_auth/
│
├── lib/
│   ├── main.dart                      # App entry point
│   ├── firebase_options.dart          # Firebase config
│   │
│   ├── screens/
│   │   ├── phone_auth_screen.dart     # Phone input
│   │   ├── otp_verification_screen.dart # OTP verification
│   │   └── home_screen.dart           # Success screen
│   │
│   └── services/
│       └── backend_service.dart       # Optional backend API
│
├── android/
│   └── app/
│       ├── google-services.json       # Firebase Android config
│       └── build.gradle               # Android build config
│
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist   # Firebase iOS config
│
├── django_backend/                    # Optional backend
│   ├── requirements.txt
│   ├── users_app_example.py
│   └── README.md
│
└── Documentation/
    ├── README.md
    ├── SETUP_INSTRUCTIONS.md
    ├── COMPLETE_SETUP_GUIDE.md
    └── APP_FLOW.md (this file)
```

## State Management

```
User State Flow:

┌─────────────────┐
│  Not Signed In  │ ──► Phone Input Screen
└─────────────────┘
        │
        │ verifyPhoneNumber()
        ▼
┌─────────────────┐
│  OTP Sent       │ ──► OTP Verification Screen
└─────────────────┘
        │
        │ signInWithCredential()
        ▼
┌─────────────────┐
│  Signed In      │ ──► Home Screen
└─────────────────┘
        │
        │ signOut()
        ▼
┌─────────────────┐
│  Not Signed In  │ ──► Phone Input Screen
└─────────────────┘
```

## Error Handling

```
Error Scenarios:

1. Invalid Phone Number
   ├─► Show validation error
   └─► Stay on Phone Input Screen

2. SMS Send Failed
   ├─► Show error dialog
   └─► Allow retry

3. Invalid OTP
   ├─► Show error dialog
   └─► Allow re-entry

4. Network Error
   ├─► Show error dialog
   └─► Allow retry

5. Firebase Auth Error
   ├─► Show specific error message
   └─► Log error for debugging
```

## Testing Flow

```
Development Testing:

1. Add Test Phone Numbers in Firebase Console
   ├─► Phone: +1 650 555 1234
   └─► Code: 123456

2. Enter test phone in app
   └─► No SMS sent (instant)

3. Enter test code
   └─► Instant verification

4. Success!
   └─► Navigate to Home Screen

Production Testing:

1. Enter real phone number
   └─► SMS sent (costs apply)

2. Receive SMS with code
   └─► Enter in app

3. Verification
   └─► Navigate to Home Screen
```
