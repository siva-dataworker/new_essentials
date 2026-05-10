@echo off
echo ========================================
echo Starting Flutter App
echo ========================================
echo.

cd otp_phone_auth

echo Checking Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter not found!
    echo Please install Flutter: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Starting Flutter app...
echo This may take a few minutes on first run...
echo.
flutter run

pause
