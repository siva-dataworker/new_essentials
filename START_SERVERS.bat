@echo off
echo ========================================
echo Starting Construction Management System
echo ========================================
echo.

echo Step 1: Creating cash_entries table...
cd django-backend
python create_cash_entries_table.py
if %errorlevel% neq 0 (
    echo.
    echo WARNING: Table creation failed or table already exists
    echo Continuing anyway...
)
echo.

echo Step 2: Starting Django Backend...
echo Backend will run on http://localhost:8000
start cmd /k "cd django-backend && python manage.py runserver"
timeout /t 3 /nobreak >nul
echo.

echo Step 3: Starting Flutter App...
echo Please wait for Flutter to compile...
cd otp_phone_auth
start cmd /k "flutter run"
echo.

echo ========================================
echo Servers Starting!
echo ========================================
echo.
echo Django Backend: http://localhost:8000
echo Flutter App: Will open automatically
echo.
echo Press any key to exit this window...
pause >nul
