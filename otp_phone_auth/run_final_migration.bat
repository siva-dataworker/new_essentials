@echo off
echo ========================================
echo Final Screen Migration Script
echo ========================================
echo.
echo This will update all 60+ screens to use:
echo - Consumer pattern for auto-refresh
echo - Provider data instead of local state
echo - Comment out old initState and load methods
echo.
echo All original files will be backed up with .backup2 extension
echo.
echo Press Ctrl+C to cancel, or
pause

cd /d "%~dp0"
python migrate_screens_final.py lib/screens

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter analyze (check for errors)
echo 3. Run: flutter run -d chrome
echo 4. Test the screens
echo.
pause
