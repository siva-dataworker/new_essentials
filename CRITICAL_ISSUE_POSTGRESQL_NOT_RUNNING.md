# CRITICAL ISSUE: PostgreSQL Not Running

## Problem
The PostgreSQL database server is not running, which prevents:
- Checking material entries in the database
- Verifying if notifications were created
- Running any database queries

## Error Message
```
psycopg2.OperationalError: connection to server at "localhost" (::1), port 5432 failed: Connection refused
Is the server running on that host and accepting TCP/IP connections?
```

## Solution Steps

### 1. Start PostgreSQL Service

#### On Windows:
```powershell
# Option 1: Using Services
services.msc
# Find "postgresql-x64-XX" service and click Start

# Option 2: Using Command Line (as Administrator)
net start postgresql-x64-XX

# Option 3: Using pg_ctl
pg_ctl -D "C:\Program Files\PostgreSQL\XX\data" start
```

#### On Linux/Mac:
```bash
# Ubuntu/Debian
sudo service postgresql start

# Or
sudo systemctl start postgresql

# Mac (Homebrew)
brew services start postgresql
```

### 2. Verify PostgreSQL is Running

```powershell
# Check if PostgreSQL is listening on port 5432
netstat -an | findstr 5432

# Or try connecting
psql -U postgres -d construction_db
```

### 3. Run the Material Entries Check

Once PostgreSQL is running:

```bash
cd essential/construction_flutter/django-backend
python check_material_entries_outside_time.py
```

This will show:
- All material entries in the database
- Which ones were submitted outside the 4-7 PM window
- How many should have triggered notifications

### 4. Check Notifications Table

```bash
python check_notifications.py
```

This will show if any notifications were actually created.

## Expected Results

### If Material Entries Exist Outside Time Window BUT No Notifications:

This confirms the issue: Material entries were submitted late, but notifications weren't sent.

**Root Cause**: Django server needs to be restarted after adding the notification API.

**Solution**:
```bash
# Stop the current Django server (Ctrl+C)
# Then restart it
python manage.py runserver 0.0.0.0:8000
```

### If No Material Entries Outside Time Window:

The time validation is working correctly - all entries were submitted within the allowed window.

**To Test**: Submit a material entry outside 4-7 PM and verify:
1. Flutter console shows notification logs
2. Notification appears in database
3. Admin can see the notification

## Database Tables

### Material Data
- **Table**: `material_usage`
- **Key Fields**: `created_at`, `usage_date`, `material_type`, `quantity_used`
- **API Endpoint**: `/construction/material-balance/`

### Notification Data
- **Table**: `notifications`
- **Key Fields**: `created_at`, `notification_type`, `message`, `is_read`
- **API Endpoint**: `/notifications/create/`

## Quick Reference

### Time Windows (IST)
- Labour entries: Before 12:00 PM
- Material entries: 4:00 PM - 7:00 PM
- Morning photos: Before 11:00 AM
- Evening photos: 4:00 PM - 7:30 PM

### Files to Check
- Flutter notification service: `lib/services/notification_service.dart`
- Flutter time validator: `lib/utils/time_validator.dart`
- Django notification API: `api/views_notifications.py`
- Django material submission: `api/views_construction.py`

## Next Steps

1. ✅ Start PostgreSQL service
2. ✅ Run `check_material_entries_outside_time.py`
3. ✅ Run `check_notifications.py`
4. ✅ Restart Django server if needed
5. ✅ Test by submitting material outside time window
6. ✅ Verify notification in database and admin UI
