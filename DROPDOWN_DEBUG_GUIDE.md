# Dropdown Not Working - Debug Guide

## Issue
Sites dropdown in the Sites tab is not working - can't select sites.

## Changes Made

### 1. Backend API Fix
**File**: `django-backend/api/views_admin.py`
**Change**: Removed filter that was hiding sites with NULL/empty names

**Before**:
```python
WHERE site_name IS NOT NULL AND site_name != ''
```

**After**:
```python
# No WHERE clause - returns ALL sites
# Sites without names show as "Site [ID]"
```

### 2. Flutter Debug Logging
**File**: `otp_phone_auth/lib/screens/simple_budget_screen.dart`
**Added**: Debug print statements to see what's happening

### 3. Better Error Display
**Added**: Warning message when no sites are loaded

## How to Debug

### Step 1: Check Flutter Console
When you open the Sites tab, you should see:
```
Loading sites with token: eyJ...
Sites API response status: 200
Sites API response body: {"sites":[...]}
Loaded X sites
```

### Step 2: Check for Errors
Look for error messages in console:
- "Failed to load sites: 401" → Token expired, login again
- "Failed to load sites: 500" → Backend error
- "Error loading sites: ..." → Network or parsing error

### Step 3: Verify Backend is Running
```bash
cd django-backend
python manage.py runserver
```

Should see:
```
Starting development server at http://127.0.0.1:8000/
```

### Step 4: Test API Directly
Open browser or use curl:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://192.168.1.2:8000/api/admin/sites/
```

Should return:
```json
{
  "sites": [
    {
      "id": "uuid-here",
      "site_name": "Site Name",
      "location": "Area Street City",
      "created_at": "2024-01-01T00:00:00"
    }
  ]
}
```

### Step 5: Check Network
Make sure:
- Backend is running on `192.168.1.2:8000`
- Phone/emulator can reach that IP
- No firewall blocking

## Common Issues

### Issue 1: No Sites Showing
**Symptom**: Dropdown shows "No sites available"
**Causes**:
1. Backend not running
2. Wrong IP address in `baseUrl`
3. No sites in database
4. Token expired

**Fix**:
1. Start backend: `python manage.py runserver 0.0.0.0:8000`
2. Check IP in `simple_budget_screen.dart` line 11
3. Check database has sites
4. Re-login to get new token

### Issue 2: Dropdown Not Clickable
**Symptom**: Can see dropdown but can't tap it
**Causes**:
1. Widget is loading
2. Sites list is empty
3. UI overlay blocking

**Fix**:
1. Wait for loading to finish
2. Check console for "Loaded X sites"
3. Restart app

### Issue 3: Sites Load But Can't Select
**Symptom**: Dropdown opens but selecting doesn't work
**Causes**:
1. Site ID format mismatch
2. Error in onChanged callback

**Fix**:
1. Check console for errors when selecting
2. Verify site IDs are strings

## Quick Fixes

### Fix 1: Restart Everything
```bash
# Stop backend (Ctrl+C)
# Stop Flutter app (Ctrl+C)

# Start backend
cd django-backend
python manage.py runserver 0.0.0.0:8000

# Start Flutter
cd otp_phone_auth
flutter run
```

### Fix 2: Clear App Data
```bash
flutter clean
flutter pub get
flutter run
```

### Fix 3: Check Base URL
In `simple_budget_screen.dart` line 11:
```dart
static const String baseUrl = 'http://192.168.1.2:8000/api';
```

Make sure this matches your backend IP!

### Fix 4: Re-login
Sometimes token expires:
1. Logout from app
2. Login again
3. Go to Sites tab

## What to Check in Console

### Good Output
```
Loading sites with token: eyJ...
Sites API response status: 200
Sites API response body: {"sites":[{"id":"...","site_name":"Downtown",...}]}
Loaded 5 sites
```

### Bad Output - No Token
```
Loading sites with token: null
Sites API response status: 401
Failed to load sites: 401
```
**Fix**: Re-login

### Bad Output - Network Error
```
Loading sites with token: eyJ...
Error loading sites: SocketException: Failed host lookup
```
**Fix**: Check backend IP and network

### Bad Output - Backend Error
```
Loading sites with token: eyJ...
Sites API response status: 500
Sites API response body: {"error":"..."}
Failed to load sites: 500
```
**Fix**: Check backend logs

## Testing Steps

1. **Open app** → Login as admin
2. **Tap Sites tab** → Should see loading indicator
3. **Check console** → Should see "Loading sites..."
4. **Wait** → Should see "Loaded X sites"
5. **Look at screen** → Should see dropdown with sites
6. **Tap dropdown** → Should open list of sites
7. **Select site** → Should load site data

## If Still Not Working

1. Take screenshot of:
   - Flutter console output
   - Backend console output
   - App screen

2. Check:
   - Backend running? `http://192.168.1.2:8000/admin/`
   - Can access from browser?
   - Token valid?

3. Try:
   - Different site
   - Re-login
   - Restart backend
   - Restart app

## Files to Check

1. `otp_phone_auth/lib/screens/simple_budget_screen.dart` - Frontend
2. `django-backend/api/views_admin.py` - Backend API
3. Backend console - Error messages
4. Flutter console - Debug output

---

**Status**: Debug logging added
**Next**: Check console output when opening Sites tab
