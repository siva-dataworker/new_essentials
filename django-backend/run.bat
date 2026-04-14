@echo off
echo ========================================
echo Essential Homes - Django Backend
echo ========================================
echo.

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo.
echo Starting Django development server...
echo Server will be available at: http://localhost:8000
echo.
echo Press Ctrl+C to stop the server
echo.

python manage.py runserver 8000
