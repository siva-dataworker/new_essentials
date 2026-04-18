@echo off
echo ========================================
echo Running Flutter on Mobile
echo ========================================

echo.
echo Step 1: Cleaning Flutter build cache...
call flutter clean

echo.
echo Step 2: Cleaning Gradle cache...
cd android
if exist .gradle (
    echo Deleting .gradle folder...
    rmdir /s /q .gradle
)
if exist app\build (
    echo Deleting app\build folder...
    rmdir /s /q app\build
)
call gradlew clean
cd ..

echo.
echo Step 3: Deleting build folder...
if exist build (
    rmdir /s /q build
)

echo.
echo Step 4: Getting Flutter dependencies...
call flutter pub get

echo.
echo Step 5: Checking connected devices...
call flutter devices

echo.
echo Step 6: Running on mobile device...
call flutter run

echo.
echo ========================================
echo Done!
echo ========================================
pause
