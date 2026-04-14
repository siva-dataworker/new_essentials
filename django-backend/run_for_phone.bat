@echo off
echo ========================================
echo Starting Django Backend for Phone Access
echo ========================================
echo.
echo Backend will be accessible at:
echo http://192.168.1.7:8000
echo.
echo Make sure:
echo 1. Phone and computer are on same WiFi
echo 2. Windows Firewall allows Python
echo 3. Database credentials are correct in .env
echo.
echo ========================================
echo.

python manage.py runserver 0.0.0.0:8000
