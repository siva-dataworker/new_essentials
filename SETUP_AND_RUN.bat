@echo off
echo ========================================
echo Construction Management System Setup
echo ========================================
echo.

echo This script will:
echo 1. Create cash_entries table
echo 2. Verify database setup
echo 3. Start Django backend
echo 4. Start Flutter app
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul
echo.

REM Step 1: Create cash_entries table
echo ========================================
echo Step 1: Creating cash_entries table
echo ========================================
cd django-backend
python create_cash_entries_table.py
if %errorlevel% neq 0 (
    echo.
    echo ❌ Failed to create table!
    echo Please check:
    echo   - PostgreSQL is running
    echo   - Database credentials in .env file
    echo   - Database exists
    echo.
    pause
    exit /b 1
)
echo.
echo ✅ Table created successfully!
echo.
timeout /t 2 /nobreak >nul

REM Step 2: Verify setup
echo ========================================
echo Step 2: Verifying database setup
echo ========================================
python verify_cash_entries_table.py
echo.
timeout /t 3 /nobreak >nul

REM Step 3: Start Django
echo ========================================
echo Step 3: Starting Django Backend
echo ========================================
echo Backend will run on http://localhost:8000
echo Opening in new window...
start cmd /k "cd django-backend && python manage.py runserver"
timeout /t 5 /nobreak >nul
echo.

REM Step 4: Start Flutter
echo ========================================
echo Step 4: Starting Flutter App
echo ========================================
echo Opening in new window...
cd ..
start cmd /k "cd otp_phone_auth && flutter run"
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Django Backend: http://localhost:8000
echo Flutter App: Running in separate window
echo.
echo Two new windows have opened:
echo   1. Django Backend Server
echo   2. Flutter App
echo.
echo You can close this window now.
echo Press any key to exit...
pause >nul
