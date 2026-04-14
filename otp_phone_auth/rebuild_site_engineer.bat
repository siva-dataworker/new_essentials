@echo off
echo ========================================
echo Rebuilding Site Engineer Dashboard
echo ========================================
echo.

echo Step 1: Cleaning Flutter build cache...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building APK...
flutter build apk --debug

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Now install the APK on your device:
echo The APK is located at: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Or run directly with:
echo flutter run
echo.
pause
