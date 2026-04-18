@echo off
echo ========================================
echo Fixing Gradle Build Issues
echo ========================================

echo.
echo Step 1: Cleaning Flutter build...
call flutter clean

echo.
echo Step 2: Cleaning Gradle cache...
cd android
call gradlew clean
cd ..

echo.
echo Step 3: Getting dependencies...
call flutter pub get

echo.
echo Step 4: Building for Android...
call flutter build apk --debug

echo.
echo ========================================
echo Build fix complete!
echo ========================================
echo.
echo If the build still fails, try:
echo 1. Restart Android Studio
echo 2. Invalidate Caches and Restart
echo 3. Delete android/.gradle folder
echo 4. Run: flutter doctor -v
echo.
pause
