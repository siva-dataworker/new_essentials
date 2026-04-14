# Notification Role Column Fix

## Issue
Admin notification API was failing with error:
```
column "role" does not exist
LINE 2: SELECT role FROM users WHERE id = $1
```

## Root Cause
The `users` table uses `role_id` (integer) to reference the `roles` table, not a `role` (varchar) column.

### Database Structure
```sql
-- Roles table
roles:
  - id: 1 = Admin
  - id: 2 = Supervisor
  - id: 3 = Site Engineer
  - id: 4 = Accountant
  - id: 5 = Architect
  - id: 6 = Owner
  - id: 8 = Client

-- Users table
users:
  - id: UUID
  - username: VARCHAR
  - role_id: INTEGER (references roles.id)
  - full_name: VARCHAR
  - ...
```

## Fix Applied

Updated `api/views_notifications.py` to use `role_id` instead of `role`:

### Before:
```python
cursor.execute("""
    SELECT role FROM users WHERE id = %s
""", (user_id,))
user_role = cursor.fetchone()

if not user_role or user_role[0] != 'admin':
    # Deny access
```

### After:
```python
cursor.execute("""
    SELECT role_id FROM users WHERE id = %s
""", (user_id,))
user_role = cursor.fetchone()

# role_id 1 = Admin
if not user_role or user_role[0] != 1:
    # Deny access
```

## Changes Made

### File: `api/views_notifications.py`

1. **get_notifications()** - Line ~104
   - Changed: `SELECT role FROM users` → `SELECT role_id FROM users`
   - Changed: `user_role[0] != 'admin'` → `user_role[0] != 1`

2. **mark_notification_read()** - Line ~201
   - Changed: `SELECT role FROM users` → `SELECT role_id FROM users`
   - Changed: `user_role[0] != 'admin'` → `user_role[0] != 1`

3. **mark_all_notifications_read()** - Line ~255
   - Changed: `SELECT role FROM users` → `SELECT role_id FROM users`
   - Changed: `user_role[0] != 'admin'` → `user_role[0] != 1`

4. **create_late_entry_notification()** - Line ~70
   - Changed: `SELECT id FROM users WHERE role = 'admin'` → `SELECT id FROM users WHERE role_id = 1`

## Testing

### Before Fix:
```
GET /api/notifications/
Response: 500 Internal Server Error
Error: column "role" does not exist
```

### After Fix:
```
GET /api/notifications/
Response: 200 OK
{
  "success": true,
  "notifications": [...],
  "total": 6,
  "unread_count": 6
}
```

## Verification Steps

1. ✅ Restart Django server
2. ✅ Login as admin in Flutter app
3. ✅ Navigate to Alerts tab
4. ✅ Verify notifications load successfully
5. ✅ Verify no "role does not exist" error

## Role ID Reference

For future development, use these role_id values:

| Role | role_id |
|------|---------|
| Admin | 1 |
| Supervisor | 2 |
| Site Engineer | 3 |
| Accountant | 4 |
| Architect | 5 |
| Owner | 6 |
| Client | 8 |

## Related Files

- `api/views_notifications.py` - Fixed role checks
- `check_user_role_column.py` - Diagnostic script
- `check_user_roles_data.py` - Diagnostic script

## Status

✅ **FIXED** - Admin notification API now works correctly with role_id
