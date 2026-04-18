@echo off
echo ========================================
echo Safe Screen Migration Script
echo ========================================
echo.
echo This script will:
echo - Add provider imports to all screens
echo - Wrap build methods with Consumer
echo - Replace state variables conservatively
echo - Keep StatefulWidget functionality intact
echo - Create backups (.backup3 extension)
echo.
echo Press Ctrl+C to cancel, or
pause

cd /d "%~dp0"
python safe_migration.py lib/screens

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter analyze
echo 3. Fix any remaining errors manually
echo 4. Run: flutter run -d chrome
echo 5. Test the screens
echo.
pause
