@echo off
echo ========================================
echo Running Day of Week Migration
echo ========================================
echo.
echo This will add day_of_week column to:
echo - labour_entries table
echo - material_entries table
echo.
echo ========================================
echo.

python run_day_of_week_migration.py

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Restart backend: python manage.py runserver 0.0.0.0:8000
echo 2. Test endpoints with Flutter app
echo.
pause
