@echo off
echo ========================================
echo Starting PostgreSQL Service
echo ========================================
echo.

REM Try to start PostgreSQL service
echo Attempting to start PostgreSQL...
net start postgresql-x64-16 2>nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL started successfully!
    goto :check
)

net start postgresql-x64-15 2>nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL started successfully!
    goto :check
)

net start postgresql-x64-14 2>nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL started successfully!
    goto :check
)

echo ❌ Could not start PostgreSQL automatically
echo.
echo Please start PostgreSQL manually:
echo 1. Press Win+R
echo 2. Type: services.msc
echo 3. Find "postgresql-x64-XX" service
echo 4. Right-click and select "Start"
echo.
pause
exit /b 1

:check
echo.
echo Checking PostgreSQL connection...
python -c "import psycopg2; conn = psycopg2.connect(dbname='construction_db', user='postgres', password='admin', host='localhost', port='5432'); print('✅ Database connection successful!'); conn.close()" 2>nul
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo PostgreSQL is running and accessible!
    echo ========================================
) else (
    echo ❌ PostgreSQL is running but cannot connect to database
    echo Please check your database credentials
)

echo.
pause
