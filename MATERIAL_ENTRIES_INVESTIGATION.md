# Material Entries Investigation Summary

## Issue
User reported that material balance was updated at 11:59 AM (outside the 4-7 PM window), but no admin notification was sent.

## Investigation Findings

### 1. Database Structure
- Material entries are stored in the `material_usage` table (NOT `daily_material_balance`)
- API endpoint: `/construction/material-balance/`
- Backend handler: `views_construction.submit_material_balance()`

### 2. Time Validation Implementation
✅ **Flutter Side** (Fully Implemented):
- Time validator: `lib/utils/time_validator.dart`
- Notification service: `lib/services/notification_service.dart`
- Material submission: `lib/screens/site_detail_screen.dart` (lines 3054-3150)
- Visual indicators showing green (on time) or orange (late)
- IST time display in UI

✅ **Backend Side** (Fully Implemented):
- Notification API: `api/views_notifications.py`
- Database table: `notifications` (created and verified)
- 4 API endpoints: create, get, mark read, mark all read
- Migration completed successfully

### 3. Current Status

#### ❌ Cannot Verify Database Entries
**Problem**: PostgreSQL service is not running

**Error**:
```
psycopg2.OperationalError: connection to server at "localhost" (::1), port 5432 failed
```

**Impact**:
- Cannot check which material entries were submitted outside time window
- Cannot verify if notifications were created in database
- Cannot run diagnostic queries

#### ⚠️ Django Server May Need Restart
The notification API was added after the Django server was started. Django needs to be restarted to load the new views.

## Required Actions

### STEP 1: Start PostgreSQL ⚠️ CRITICAL
```bash
# Windows (as Administrator)
net start postgresql-x64-16

# Or use the batch file
START_POSTGRESQL.bat

# Or use Services (Win+R → services.msc)
```

### STEP 2: Check Material Entries
```bash
cd essential/construction_flutter/django-backend
python check_material_entries_outside_time.py
```

This will show:
- All material entries with timestamps
- Which entries were outside 4-7 PM window
- How many should have triggered notifications

### STEP 3: Check Notifications
```bash
python check_notifications.py
```

This will show:
- Total notifications in database
- Unread notifications
- Recent notifications with details

### STEP 4: Restart Django Server
```bash
# Stop current server (Ctrl+C)
python manage.py runserver 0.0.0.0:8000
```

### STEP 5: Test the System
1. Submit material entry outside 4-7 PM window
2. Check Flutter console for logs:
   ```
   📧 [MATERIAL] Sending late entry notification to admin...
   📧 [MATERIAL] Notification result: {success: true}
   ```
3. Verify notification in database:
   ```bash
   python check_notifications.py
   ```
4. Check admin UI for notification

## Time Windows (IST)

| Entry Type | Allowed Time | Late Entry Action |
|------------|--------------|-------------------|
| Labour | Before 12:00 PM | Send notification to admin |
| Material | 4:00 PM - 7:00 PM | Send notification to admin |
| Morning Photos | Before 11:00 AM | Send notification to admin |
| Evening Photos | 4:00 PM - 7:30 PM | Send notification to admin |

## Code Flow

### Material Submission Flow
1. User fills material quantities in `_MaterialEntrySheet`
2. User clicks "Submit Material Balance"
3. `_submit()` method checks time using `TimeValidator.isMaterialEntryOnTime()`
4. Material data sent to backend via `ConstructionService.submitMaterialBalance()`
5. Backend saves to `material_usage` table
6. If late entry AND submission successful:
   - `NotificationService.sendLateEntryNotification()` called
   - Notification sent to `/notifications/create/` endpoint
   - Admin receives notification

### Notification API Flow
1. Flutter app sends POST to `/notifications/create/`
2. Backend validates JWT token
3. Creates notification in `notifications` table
4. Returns success/error response
5. Admin can view via `/notifications/get/` endpoint

## Files Modified

### Flutter
- `lib/utils/time_validator.dart` - Time validation logic
- `lib/services/notification_service.dart` - Notification API calls
- `lib/screens/site_detail_screen.dart` - Material submission with time checks

### Backend
- `api/views_notifications.py` - Notification CRUD endpoints
- `api/urls.py` - Notification routes
- `api/views_construction.py` - Material submission handler

### Database
- `create_notifications_system.sql` - Notification table schema
- `run_notifications_migration.py` - Migration script

### Diagnostic Scripts
- `check_material_entries_outside_time.py` - Check material entries
- `check_notifications.py` - Check notification records
- `START_POSTGRESQL.bat` - Helper to start PostgreSQL

## Troubleshooting

### If No Notifications Despite Late Entries

**Possible Causes**:
1. Django server not restarted after adding notification API
2. Authentication token issues
3. Network connectivity problems
4. Backend error not logged

**Debug Steps**:
1. Check Flutter console for notification logs
2. Check Django server logs for errors
3. Verify JWT token is valid
4. Test notification endpoint directly:
   ```bash
   curl -X POST http://localhost:8000/api/notifications/create/ \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"notification_type":"late_entry","message":"Test","site_id":"SITE_ID"}'
   ```

### If PostgreSQL Won't Start

1. Check if another instance is running
2. Check PostgreSQL logs: `C:\Program Files\PostgreSQL\XX\data\log\`
3. Verify port 5432 is not in use: `netstat -an | findstr 5432`
4. Reinstall PostgreSQL if corrupted

## Next Steps

1. ✅ Start PostgreSQL service
2. ✅ Run diagnostic scripts to check database
3. ✅ Restart Django server
4. ✅ Test material submission outside time window
5. ✅ Verify notification creation
6. ✅ Test admin notification viewing

## Success Criteria

- [ ] PostgreSQL running and accessible
- [ ] Material entries visible in database
- [ ] Late entries identified (if any)
- [ ] Django server restarted with notification API loaded
- [ ] Test submission creates notification
- [ ] Admin can view notifications
- [ ] Flutter app shows appropriate UI feedback
