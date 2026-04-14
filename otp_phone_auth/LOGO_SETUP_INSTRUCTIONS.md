# Logo Setup Instructions

## Step 1: Save the Logo Image

1. Create the folder structure:
   ```
   otp_phone_auth/
   └── assets/
       └── images/
           └── essential_homes_logo.png
   ```

2. Save your Essential Homes logo image as `essential_homes_logo.png` in the `assets/images/` folder

## Step 2: The code has been updated

The following files have been updated to use the logo:
- `pubspec.yaml` - Added assets configuration
- `lib/screens/splash_screen.dart` - Uses logo image
- `lib/screens/google_auth_screen.dart` - Uses logo image

## Step 3: Run Flutter commands

After placing the logo image, run:
```bash
flutter pub get
flutter clean
flutter run
```

## Logo Requirements

- Format: PNG (with transparent background recommended)
- Recommended size: 512x512 pixels or higher
- The logo will be automatically resized in the app
