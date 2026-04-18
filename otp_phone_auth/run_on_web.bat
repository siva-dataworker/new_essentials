@echo off
echo ========================================
echo Running Flutter on Web (Chrome)
echo ========================================
echo.
echo This avoids Android build issues!
echo.

echo Step 1: Cleaning...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Running on Chrome...
call flutter run -d chrome

pause
