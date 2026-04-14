# Notification System Testing Guide

## Current Status

✅ **Database**: 4 notifications created successfully
✅ **Backend API**: Fixed role column issue (using role_id instead of role)
✅ **Flutter Service**: Implemented with debug logging
✅ **Admin UI**: Implemented with notification cards

## Notifications in Database

```
📊 Total: 4 notifications
📬 Unread: 4 notifications

All notifications are for Material Balance entries submitted outside 4-7 PM window:
1. 2026-03-31 06:29 AM - Paint (53 L)
2. 2026-03-28 01:51 PM - Paint (37 L)
3. 2026-03-27 09:22 AM - Paint (76 L)
4. 2026-03-26 06:04 AM - Paint (112 L)
```

## Testing Steps

### Step 1: Verify Django Server is Running
```bash
# Check if server is running on port 8000
netstat -an | findstr 8000

# If not running, start it:
cd essential/construction_flutter/django-backend
python manage.py runserver 0.0.0.0:8000
```

### Step 2: Test API Directly (Optional)
```bash
# Get admin token first by logging in
# Then test the endpoint:
curl -X GET "http://192.168.31.228:8000/api/notifications/" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
  "success": true,
  "notifications": [
    {
      "id": "uuid",
      "site_name": "6 22 Ibrahim",
      "supervisor_name": "jack",
      "entry_type": "material",
      "message": "Material balance submitted too early...",
      "actual_time": "2026-03-31T06:29:53+05:30",
      "created_at": "2026-03-31T09:33:01+05:30",
      "is_read": false
    }
  ],
  "total": 4,
  "unread_count": 4
}
```

### Step 3: Test in Flutter App

1. **Open Flutter app**
2. **Login as admin**
   - Username: admin (or your admin username)
   - Password: your admin password

3. **Navigate to Alerts tab** (bottom navigation)

4. **Check Flutter Console** for debug logs:
   ```
   🔍 [NOTIFICATIONS] Loading notifications...
   🔍 [NOTIFICATION_SERVICE] GET http://192.168.31.228:8000/api/notifications/
   🔍 [NOTIFICATION_SERVICE] Status: 200
   🔍 [NOTIFICATIONS] Result: true
   🔍 [NOTIFICATIONS] Notifications count: 4
   ✅ [NOTIFICATIONS] Loaded 4 notifications
   ```

5. **Expected UI**:
   - Header showing "Notifications" with unread count badge (4)
   - "Mark all read" button
   - Refresh icon
   - List of 4 notification cards with:
     - Green icon (Material Balance)
     - Orange warning box with message
     - Site name: "6 22 Ibrahim"
     - Supervisor name: "jack"
     - Submission time
     - Red dot indicator (unread)

### Step 4: Test Mark as Read

1. **Tap on a notification card**
2. **Observe**:
   - Red dot disappears
   - Card background changes to gray
   - Unread count decreases by 1

3. **Check console**:
   ```
   🔍 [NOTIFICATION_SERVICE] POST http://192.168.31.228:8000/api/notifications/<uuid>/read/
   ✅ Notification marked as read
   ```

### Step 5: Test Mark All as Read

1. **Tap "Mark all read" button**
2. **Observe**:
   - All red dots disappear
   - All cards turn gray
   - Unread count becomes 0
   - Success snackbar appears

## Troubleshooting

### Issue: Empty notifications list

**Check 1: Django server running?**
```bash
netstat -an | findstr 8000
```

**Check 2: Notifications in database?**
```bash
cd essential/construction_flutter/django-backend
python check_notifications.py
```

**Check 3: Flutter console logs**
Look for error messages in console:
- Authentication errors (401)
- Permission errors (403)
- Server errors (500)
- Network errors

**Check 4: Admin user role**
```bash
python -c "
import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()
from django.db import connection
cursor = connection.cursor()
cursor.execute('SELECT username, role_id FROM users WHERE username = \\'admin\\'')
print(cursor.fetchone())
"
```
Should show: `('admin', 1)` - role_id must be 1

### Issue: 403 Forbidden

**Cause**: User is not admin (role_id != 1)

**Fix**: Verify admin user has role_id = 1:
```sql
UPDATE users SET role_id = 1 WHERE username = 'admin';
```

### Issue: 401 Unauthorized

**Cause**: JWT token expired or invalid

**Fix**: 
1. Logout from app
2. Login again as admin
3. Try accessing notifications again

### Issue: Network error

**Cause**: Flutter app can't reach Django server

**Fix**:
1. Check Django server is running
2. Check IP address matches: `192.168.31.228:8000`
3. Check firewall allows connections
4. Try accessing from browser: `http://192.168.31.228:8000/api/notifications/`

## Debug Commands

### Check notifications in database
```bash
python check_notifications.py
```

### Create test notifications
```bash
python create_notifications_for_existing_entries.py
```

### Check user roles
```bash
python check_user_roles_data.py
```

### Test API endpoint
```bash
python test_notifications_api.py
```

## Expected Behavior

### When notifications exist:
- ✅ Notifications tab shows list of cards
- ✅ Unread count badge visible
- ✅ "Mark all read" button visible
- ✅ Pull-to-refresh works
- ✅ Tap card marks as read
- ✅ Visual distinction between read/unread

### When no notifications:
- ✅ Empty state with bell icon
- ✅ "Work Notifications" message
- ✅ "Refresh Notifications" button
- ✅ No error messages

## Next Steps

1. ✅ Hot restart Flutter app to load new debug logs
2. ✅ Login as admin
3. ✅ Navigate to Alerts tab
4. ✅ Check console for debug output
5. ✅ Verify notifications appear
6. ✅ Test mark as read functionality

## Success Criteria

- [ ] 4 notifications visible in Alerts tab
- [ ] Unread count shows "4"
- [ ] Each notification shows correct information
- [ ] Tapping notification marks it as read
- [ ] "Mark all read" clears all notifications
- [ ] No errors in console
- [ ] UI matches design (color-coded, icons, etc.)
