@echo off
echo ========================================
echo Flutter Screens Migration Script
echo ========================================
echo.
echo This script will update all screens to use Provider pattern
echo with auto-refresh and smart caching.
echo.
echo Backups will be created automatically.
echo.
pause

python update_all_screens.py lib/screens

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Review the changes in each file
echo 2. Follow the TODO comments
echo 3. Test each screen
echo.
echo See QUICK_START_GUIDE.md for examples
echo.
pause
