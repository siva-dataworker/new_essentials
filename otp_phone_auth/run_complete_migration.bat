@echo off
echo ========================================
echo Complete Screen Migration Script
echo ========================================
echo.
echo This will automatically implement the 4-step migration:
echo 1. Wrap build method with Consumer
echo 2. Replace local variables with provider data
echo 3. Add pull-to-refresh
echo 4. Remove old initState/setState code
echo.
echo Press Ctrl+C to cancel, or
pause

cd /d "%~dp0"
python complete_migration.py lib/screens

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter run -d chrome
echo 3. Test each screen
echo.
pause
