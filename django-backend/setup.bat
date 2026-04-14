@echo off
echo ========================================
echo Django Backend Setup
echo ========================================
echo.

echo Step 1: Creating virtual environment...
python -m venv venv
echo ✓ Virtual environment created
echo.

echo Step 2: Activating virtual environment...
call venv\Scripts\activate.bat
echo ✓ Virtual environment activated
echo.

echo Step 3: Installing dependencies...
pip install -r requirements.txt
echo ✓ Dependencies installed
echo.

echo Step 4: Running migrations...
python manage.py makemigrations
python manage.py migrate
echo ✓ Database migrations complete
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo To start the server, run: run.bat
echo.
pause
