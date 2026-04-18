@echo off
echo ========================================
echo FORCE CLEAN AND REBUILD
echo ========================================

echo.
echo This will delete ALL build caches and rebuild from scratch.
echo Press Ctrl+C to cancel, or
pause

echo.
echo Step 1: Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..

echo.
echo Step 2: Deleting Flutter build cache...
if exist build (
    echo Deleting build folder...
    rmdir /s /q build
)
if exist .dart_tool (
    echo Deleting .dart_tool folder...
    rmdir /s /q .dart_tool
)

echo.
echo Step 3: Deleting Gradle caches...
cd android
if exist .gradle (
    echo Deleting .gradle folder...
    rmdir /s /q .gradle
)
if exist .kotlin (
    echo Deleting .kotlin folder...
    rmdir /s /q .kotlin
)
if exist build (
    echo Deleting android/build folder...
    rmdir /s /q build
)
if exist app\build (
    echo Deleting app/build folder...
    rmdir /s /q app\build
)
cd ..

echo.
echo Step 4: Deleting global Gradle cache (optional)...
echo This will delete %USERPROFILE%\.gradle\caches
set /p CLEAN_GLOBAL="Delete global Gradle cache? (y/n): "
if /i "%CLEAN_GLOBAL%"=="y" (
    if exist "%USERPROFILE%\.gradle\caches" (
        echo Deleting global Gradle cache...
        rmdir /s /q "%USERPROFILE%\.gradle\caches"
    )
)

echo.
echo Step 5: Running flutter clean...
call flutter clean

echo.
echo Step 6: Getting dependencies...
call flutter pub get

echo.
echo Step 7: Running flutter doctor...
call flutter doctor

echo.
echo Step 8: Checking connected devices...
call flutter devices

echo.
echo ========================================
echo Clean complete! Now trying to build...
echo ========================================
echo.

echo Step 9: Building APK (this may take 5-10 minutes)...
call flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Now running on device...
    call flutter run
) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
    echo Common solutions:
    echo 1. Restart your computer
    echo 2. Update Android Studio
    echo 3. Run: flutter doctor -v
    echo 4. Check Java version: java -version
    echo.
)

pause
