# Client Routing Issue - Troubleshooting Guide

## Problem
When logging in as client4, the Supervisor dashboard is displayed instead of the Client dashboard.

## Root Cause
The Flutter app is running OLD code that hasn't picked up the routing changes. Hot reload doesn't always update routing logic.

## Solution: FULL APP RESTART

### Step 1: Stop the Current App
Press `Ctrl+C` in the terminal where Flutter is running, OR click the Stop button in your IDE.

### Step 2: Clean Build (Recommended)
```bash
cd essential/construction_flutter/otp_phone_auth
flutter clean
flutter pub get
```

### Step 3: Restart the App
```bash
flutter run
```

### Step 4: Test Login
1. Login with:
   - Username: `client4`
   - Password: `client4`

2. Check console output for debug messages:
   ```
   🔐 LOGIN SUCCESS
   🔐 User: client4
   🔐 Role: "Client"
   🔐 Normalized role: "client"
   🔐 ✅ Routing to ClientDashboard
   ```

3. Should see ClientDashboard with:
   - Site: "Anwar 6 22 Ibrahim"
   - Labour counts
   - Photos
   - Documents

## If Still Not Working

### Check 1: Verify Role in Database
```bash
cd django-backend
python verify_all_clients.py
```

Should show:
```
Username: client4
Role: Client  ← Must be "Client" (capitalized)
```

### Check 2: Check Login Response
Add this to login_screen.dart after line 66:
```dart
print('🔐 Full user data: $user');
```

This will show the complete user object.

### Check 3: Force Logout
1. Logout from the app
2. Close the app completely
3. Restart the app
4. Login again

### Check 4: Clear App Data (Android)
```bash
# For Android
flutter run --clear-cache
```

Or manually:
1. Go to Settings > Apps > Essential Homes
2. Clear Storage & Cache
3. Restart app

## Expected Console Output

When logging in as client4, you should see:
```
🔐 LOGIN SUCCESS
🔐 User: client4
🔐 Role: "Client"
🔐 Role type: String
🔐 Normalized role: "client"
🔐 ✅ Routing to ClientDashboard
📱 Loading client data...
📱 Response status: 200
📱 Sites count: 1
📱 Site: Anwar 6 22 Ibrahim
📱 Photos: 1
📱 Architect docs: 3
📱 State updated successfully
```

## Common Issues

### Issue 1: Role is lowercase "client"
**Solution:** Already fixed in database. Run `python verify_all_clients.py` to confirm.

### Issue 2: Hot Reload Not Working
**Solution:** Do a FULL restart (flutter clean + flutter run)

### Issue 3: Cached Authentication
**Solution:** Logout and login again, or clear app data

### Issue 4: Wrong Dashboard Imported
**Check:** Ensure ClientDashboard is imported in login_screen.dart:
```dart
import 'client_dashboard.dart';
```

## Verification Steps

1. ✅ Database has Client role (capitalized)
2. ✅ client4 user has Client role
3. ✅ Routing code uses case-insensitive comparison
4. ✅ ClientDashboard is imported
5. ✅ API returns data correctly
6. ⚠️ Flutter app needs FULL RESTART

## Quick Test

Run this to verify the backend is working:
```bash
cd django-backend
python test_api_simple.py
```

Should show site data with photos and documents.

---

**Status:** Code is correct, app needs FULL RESTART
**Last Updated:** Current session
