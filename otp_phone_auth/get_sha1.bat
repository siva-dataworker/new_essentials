@echo off
echo Getting SHA-1 and SHA-256 keys for Google Sign-In setup...
echo.
echo ========================================
echo DEBUG KEYSTORE (for development)
echo ========================================
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
echo.
echo ========================================
echo Copy the SHA-1 and SHA-256 values above
echo and add them to Google Cloud Console
echo ========================================
pause
