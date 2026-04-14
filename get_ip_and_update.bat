@echo off
echo ========================================
echo Getting your current IP address...
echo ========================================
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
    goto :found
)

:found
set IP=%IP:~1%
echo Your IP address: %IP%
echo.
echo ========================================
echo.
set /p CONFIRM="Use this IP address? (Y/N): "

if /i "%CONFIRM%"=="Y" (
    echo.
    echo Updating IP address to %IP%...
    powershell -ExecutionPolicy Bypass -File change_ip.ps1 %IP%
) else (
    echo.
    set /p CUSTOM_IP="Enter IP address manually: "
    echo.
    echo Updating IP address to !CUSTOM_IP!...
    powershell -ExecutionPolicy Bypass -File change_ip.ps1 !CUSTOM_IP!
)

echo.
echo ========================================
echo Done!
echo ========================================
pause
