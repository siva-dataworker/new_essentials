@echo off
echo ========================================
echo Starting Django Backend Server
echo ========================================
echo.

cd django-backend

echo Checking database connection...
python -c "from api.database import fetch_one; print('✅ Database connected')" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Database connection failed!
    echo Please check your .env file and PostgreSQL service
    pause
    exit /b 1
)
echo.

echo Starting server on http://localhost:8000
echo Press Ctrl+C to stop
echo.
python manage.py runserver

pause
