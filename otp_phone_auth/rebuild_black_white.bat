@echo off
echo ========================================
echo Forcing Complete Rebuild for Black/White Theme
echo ========================================
echo.

echo Step 1: Cleaning build cache...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Running app with no cache...
flutter run -d ZN42279PDM --no-cache-dir

pause
