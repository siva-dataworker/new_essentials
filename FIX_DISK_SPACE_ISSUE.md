# Fix Disk Space Issue - Quick Guide

## Problem
Flutter build failed with: **"There is not enough space on the disk"**

Your C: drive is full and Flutter can't create temporary build files.

## Quick Fix (Choose One)

### Option 1: Clean Temp Files (Fastest)
1. Close all Flutter/Android Studio/VS Code windows
2. Press `Win + R`
3. Type: `%temp%` and press Enter
4. Select all files (Ctrl+A)
5. Delete (Shift+Delete for permanent)
6. Skip any files that can't be deleted

### Option 2: Disk Cleanup (Recommended)
1. Press `Win + R`
2. Type: `cleanmgr` and press Enter
3. Select C: drive
4. Check all boxes (especially "Temporary files")
5. Click OK and confirm

### Option 3: Free Up Space Manually
Delete these if you have them:
- Old downloads
- Recycle Bin (empty it)
- Browser cache
- Old Windows updates: `C:\Windows\SoftwareDistribution\Download`

### Option 4: Move Flutter Build to Another Drive (If you have D: or E:)

**Set environment variable:**
```powershell
# In PowerShell (as Admin)
[System.Environment]::SetEnvironmentVariable('FLUTTER_STORAGE_BASE_URL', 'D:\flutter_temp', 'User')
```

Then restart your terminal.

## After Freeing Space

Run these commands:
```bash
cd otp_phone_auth

# Clean Flutter cache
flutter clean

# Get dependencies
flutter pub get

# Run on your phone
flutter run -d ZN42279PDM
```

## How Much Space Do You Need?

- **Minimum**: 2-3 GB free on C: drive
- **Recommended**: 5+ GB free

## Check Your Disk Space

```powershell
Get-PSDrive C | Select-Object Used,Free
```

Or just open File Explorer → This PC → Check C: drive.

## Alternative: Build APK Instead

If you keep having issues, build an APK file and install manually:

```bash
cd otp_phone_auth

# Build release APK
flutter build apk --release

# APK will be at: build\app\outputs\flutter-apk\app-release.apk
# Copy to phone and install
```

This uses less temp space.

---

## Quick Commands Summary

```bash
# 1. Clean Flutter
flutter clean

# 2. Clean temp (close all apps first)
# Go to %temp% and delete files

# 3. Run Disk Cleanup
cleanmgr

# 4. Try building again
flutter run -d ZN42279PDM
```

---

**After freeing up space, the app should build successfully!**
