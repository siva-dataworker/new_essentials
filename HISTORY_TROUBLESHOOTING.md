# History Not Showing - Troubleshooting Guide

## Issue
History screen shows "No entries yet" even after submitting labour/material entries.

## Root Causes & Solutions

### 1. Backend Not Restarted ⚠️
**Most Common Issue**: Django backend needs restart to load new endpoints.

**Solution**:
```bash
# Stop Django (Ctrl+C in the terminal)
# Then restart:
cd django-backend
python manage.py runserver 192.168.1.7:8000
```

### 2. Check if Data is Being Stored

**Test if submissions are working**:
```bash
# In Django backend terminal, you should see:
POST /api/construction/labour/ - 201 Created
POST /api/construction/material-balance/ - 201 Created
```

**Check database directly**:
```sql
-- Connect to your database and run:
SELECT * FROM labour_entries ORDER BY created_at DESC LIMIT 5;
SELECT * FROM material_balance ORDER BY created_at DESC LIMIT 5;
```

### 3. Check Backend Logs

When you tap History, check Django terminal for:
```
GET /api/construction/supervisor/history/ - 200 OK
```

If you see **404 Not Found**, the endpoint isn't loaded → Restart Django.

### 4. Check Flutter Console

In Flutter terminal, look for errors:
```
Error getting supervisor history: ...
```

### 5. Verify Supervisor ID

The history query filters by `supervisor_id`. Make sure:
- You're logged in as a supervisor
- The supervisor_id is being sent correctly

**Check in Django logs**:
```python
# Add this temporarily to views_construction.py in get_supervisor_history:
print(f"Fetching history for supervisor: {request.user_id}")
```

### 6. Test Backend API Directly

**Get your JWT token** (from Flutter app logs or login response)

**Test the endpoint**:
```bash
curl -X GET http://192.168.1.7:8000/api/construction/supervisor/history/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected response**:
```json
{
  "labour_entries": [...],
  "material_entries": [...]
}
```

## Step-by-Step Debug Process

### Step 1: Verify Data Exists
1. Submit a labour entry from the app
2. Check Django terminal for: `POST /api/construction/labour/ - 201`
3. If you see 201, data is stored ✅

### Step 2: Restart Backend
```bash
# Stop Django (Ctrl+C)
cd django-backend
python manage.py runserver 192.168.1.7:8000
```

### Step 3: Test History Endpoint
1. Tap "History" in the app
2. Check Django terminal for: `GET /api/construction/supervisor/history/`
3. If you see 404 → Backend not restarted properly
4. If you see 200 → Endpoint working ✅

### Step 4: Check Response
Add debug logging to Flutter:
```dart
// In supervisor_history_screen.dart, _loadHistory method:
Future<void> _loadHistory() async {
  setState(() => _isLoading = true);
  final history = await _constructionService.getSupervisorHistory();
  
  print('History response: $history'); // ADD THIS LINE
  
  setState(() {
    _labourEntries = List<Map<String, dynamic>>.from(history['labour_entries'] ?? []);
    _materialEntries = List<Map<String, dynamic>>.from(history['material_entries'] ?? []);
    _isLoading = false;
  });
}
```

## Common Issues

### Issue: Empty Arrays Returned
**Cause**: No entries for this supervisor
**Solution**: Submit new entries, then check history

### Issue: 401 Unauthorized
**Cause**: JWT token expired or invalid
**Solution**: Logout and login again

### Issue: 404 Not Found
**Cause**: Backend not restarted after adding endpoints
**Solution**: Restart Django backend

### Issue: Network Error
**Cause**: Backend not running or wrong IP
**Solution**: 
- Check Django is running on 192.168.1.7:8000
- Check phone and computer on same WiFi

## Quick Fix Commands

```bash
# Terminal 1: Restart Django
cd django-backend
python manage.py runserver 192.168.1.7:8000

# Terminal 2: Restart Flutter (if needed)
cd otp_phone_auth
flutter run -d ZN42279PDM
```

## Verify Everything Works

1. ✅ Django backend running
2. ✅ Flutter app running
3. ✅ Login as supervisor
4. ✅ Submit labour entry → See success message
5. ✅ Tap History → See the entry!

## Still Not Working?

### Check Database Schema
```sql
-- Verify tables exist:
SHOW TABLES LIKE '%labour%';
SHOW TABLES LIKE '%material%';

-- Check table structure:
DESCRIBE labour_entries;
DESCRIBE material_balance;
```

### Check Supervisor ID in Database
```sql
-- Find your supervisor user:
SELECT id, username, full_name, role FROM users WHERE role = 'Supervisor';

-- Check entries for that supervisor:
SELECT * FROM labour_entries WHERE supervisor_id = 'YOUR_SUPERVISOR_ID';
```

---

**Most Likely Fix**: Just restart the Django backend!
