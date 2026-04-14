# Troubleshooting: Admin Notifications Empty

## Problem
Material balance was updated outside allowed time (not between 4-7 PM), but admin notifications screen is empty.

## Root Cause Analysis

The notification system has 3 parts that must all work:
1. ✅ **Database** - notifications table created
2. ⚠️ **Backend API** - Django server needs restart to load new views
3. ⚠️ **Flutter App** - Must successfully send notification

## Solution Steps

### Step 1: Restart Django Server (CRITICAL)

The new notification views won't work until Django is restarted.

```bash
cd essential/construction_flutter/django-backend
python manage.py runserver 0.0.0.0:8000
```

**Why?** Django loads views at startup. The new `views_notifications.py` file won't be active until restart.

### Step 2: Test Material Submission

1. Open Flutter app
2. Go to a site
3. Submit material balance at a time OUTSIDE 4:00 PM - 7:00 PM
   - Example: Submit at 11:59 AM or 8:00 PM
4. Watch the Flutter console output

### Step 3: Check Flutter Console Logs

You should see these logs:

```
🕒 [MATERIAL] Current IST time: 2026-03-31 11:59:00.000
🕒 [MATERIAL] Is on time: false
🕒 [MATERIAL] Time window: 4:00 PM - 7:00 PM IST
📧 [MATERIAL] Sending late entry notification to admin...
📧 [MATERIAL] Notification result: true
```

**If you see:**
- `Notification result: true` ✅ - Notification sent successfully
- `Notification result: false` ❌ - Check error message
- No notification logs at all ❌ - Time validation not working

### Step 4: Check Django Server Logs

In the Django server terminal, you should see:

```
POST /api/notifications/late-entry/ 201
```

**If you see:**
- `201` ✅ - Notification created successfully
- `400` ❌ - Missing required fields
- `401` ❌ - Authentication failed
- `403` ❌ - Permission denied
- `500` ❌ - Server error

### Step 5: Verify Database

Check if notification was created:

```bash
cd django-backend
python -c "import psycopg2; from dotenv import load_dotenv; import os; load_dotenv(); conn = psycopg2.connect(host=os.getenv('DB_HOST'), database=os.getenv('DB_NAME'), user=os.getenv('DB_USER'), password=os.getenv('DB_PASSWORD')); cursor = conn.cursor(); cursor.execute('SELECT * FROM notifications ORDER BY created_at DESC LIMIT 5'); print('Recent notifications:'); [print(f'{row}') for row in cursor.fetchall()]; conn.close()"
```

Or use a simpler script:

```python
# check_notifications.py
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)
cursor = conn.cursor()
cursor.execute('SELECT id, entry_type, message, created_at FROM notifications ORDER BY created_at DESC LIMIT 5')
print("Recent notifications:")
for row in cursor.fetchall():
    print(f"  {row[1]}: {row[2][:50]}... ({row[3]})")
conn.close()
```

### Step 6: Test Admin API

Check if admin can retrieve notifications:

```bash
# Get admin token first by logging in
# Then test the API
curl -X GET "http://192.168.31.228:8000/api/notifications/" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## Common Issues & Fixes

### Issue 1: Django Server Not Restarted
**Symptom:** No logs in Django terminal when submitting
**Fix:** Restart Django server

### Issue 2: Authentication Error
**Symptom:** Flutter logs show 401 or 403 error
**Fix:** Check token is valid, user is logged in

### Issue 3: Wrong Time Calculation
**Symptom:** `Is on time: true` when it should be false
**Fix:** Check system time, IST calculation in TimeValidator

### Issue 4: Network Error
**Symptom:** Flutter logs show connection refused
**Fix:** Check Django server is running on correct IP/port

### Issue 5: Admin Screen Not Refreshing
**Symptom:** Notifications in database but not showing in app
**Fix:** 
- Tap "Refresh Notifications" button
- Check admin screen is calling correct API endpoint
- Verify admin has correct role in database

## Verification Checklist

- [ ] Django server restarted after migration
- [ ] Notifications table exists in database
- [ ] Material submitted outside 4-7 PM window
- [ ] Flutter console shows "Is on time: false"
- [ ] Flutter console shows "Sending late entry notification"
- [ ] Flutter console shows "Notification result: true"
- [ ] Django server logs show POST /api/notifications/late-entry/ 201
- [ ] Database has notification record
- [ ] Admin can retrieve notifications via API
- [ ] Admin screen shows notifications

## Quick Debug Commands

```bash
# 1. Check if table exists
python -c "from api.database import get_db_connection; conn = get_db_connection(); cursor = conn.cursor(); cursor.execute(\"SELECT COUNT(*) FROM notifications\"); print(f'Notifications count: {cursor.fetchone()[0]}'); conn.close()"

# 2. Check recent notifications
python check_notifications.py

# 3. Test API endpoint
curl http://192.168.31.228:8000/api/notifications/

# 4. Check Django server is running
curl http://192.168.31.228:8000/api/health/
```

## Still Not Working?

1. Check Flutter app console for exact error message
2. Check Django server terminal for error logs
3. Verify system time is correct
4. Ensure IST calculation is working
5. Test with a simple curl command to isolate issue

## Expected Flow

```
User submits material at 11:59 AM
    ↓
TimeValidator.isMaterialEntryOnTime() returns false
    ↓
Flutter app calls NotificationService.sendLateEntryNotification()
    ↓
POST /api/notifications/late-entry/ with site_id, message, etc.
    ↓
Django creates record in notifications table
    ↓
Returns success: true
    ↓
Admin opens notifications screen
    ↓
GET /api/notifications/ returns list
    ↓
Admin sees notification
```

If any step fails, the notification won't appear!
