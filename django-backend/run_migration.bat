@echo off
echo ========================================
echo Adding Extra Cost Columns to Database
echo ========================================
echo.

REM Run SQL migration using Django's dbshell
echo Running SQL migration...
python manage.py dbshell < add_extra_cost_columns.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Migration completed successfully!
    echo ========================================
    echo.
    echo Extra cost columns have been added to:
    echo - labour_entries table
    echo - material_balances table
    echo.
    echo Next step: Restart your Django backend
    echo.
) else (
    echo.
    echo ========================================
    echo Migration failed!
    echo ========================================
    echo.
    echo Please check the error message above.
    echo.
)

pause
