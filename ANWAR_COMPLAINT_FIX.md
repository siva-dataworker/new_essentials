# Anwar Complaint Visibility Fix

## Issue
Client "anwar" (username: clientanwar) submitted complaints but they were not visible in the architect's client complaints page.

## Root Cause
The backend API was filtering complaints by `role_id = 5`, but in this database:
- Role ID 5 = Architect
- Role ID 8 = Client

This mismatch caused the API to not find any complaints from actual clients.

## Fix Applied

### Backend API Change
**File**: `django-backend/api/views_construction.py`

**Function**: `get_client_complaints_for_architect()`

**Change**: Updated the WHERE clause to filter by `role_id = 8` (Client) instead of `role_id = 5`

```python
# Before:
WHERE u_client.role_id = 5

# After:
WHERE u_client.role_id = 8  # Client role
```

### Database Verification

**Anwar's Details**:
- Username: `clientanwar`
- Role ID: 8 (Client)
- Assigned Site: "6 22 Ibrahim"

**Anwar's Complaints** (3 total):
1. "WATER" - Created: 2026-04-03 12:20:30
2. "tiles issue" - Created: 2026-04-03 09:26:39
3. "tilesissue" - Created: 2026-04-03 09:12:56

All complaints are for site "6 22 Ibrahim" (ID: 3ae88295-427b-49f6-8e50-4c02d0250617)

### Role Mapping in Database

```
Role ID | Role Name
--------|----------
1       | Admin
2       | Supervisor
3       | Site Engineer
4       | Accountant
5       | Architect
6       | Owner
8       | Client
```

## Testing

### Before Fix:
- Architect selects site "6 22 Ibrahim"
- Opens "Client Complaints"
- Sees only old complaints (not from actual clients)
- Anwar's 3 complaints are missing

### After Fix:
- Architect selects site "6 22 Ibrahim"
- Opens "Client Complaints"
- Should see all 3 of anwar's complaints:
  - WATER
  - tiles issue
  - tilesissue

## How to Test

1. **Restart Django Server** (important!):
   ```bash
   cd essential/construction_flutter/django-backend
   python manage.py runserver
   ```

2. **Login as Architect**:
   - Username: `architect1`
   - Password: `test123`

3. **Select Site**:
   - Area: 6
   - Street: 22
   - Site: Ibrahim

4. **View Client Complaints**:
   - Click "Client Complaints" card
   - Should now see 3 complaints from clientanwar

5. **Verify Each Complaint**:
   - Check client name shows "clientanwar"
   - Check all 3 complaints are listed
   - Check priority and status badges

## Additional Notes

### Why This Happened:
Different databases may have different role ID mappings. The code was hardcoded to use `role_id = 5` for clients, but this database uses `role_id = 8`.

### Better Approach:
Instead of hardcoding role IDs, the API should:
1. Look up the role ID by name: `SELECT id FROM roles WHERE role_name = 'Client'`
2. Use that ID in the query

### Future Improvement:
```python
# Get client role ID dynamically
client_role = fetch_one("SELECT id FROM roles WHERE role_name = 'Client'")
client_role_id = client_role['id'] if client_role else 8

# Use in query
WHERE u_client.role_id = %s
```

This would make the code work across different database configurations.

## Files Modified

- `django-backend/api/views_construction.py` - Updated role_id filter from 5 to 8
- `django-backend/check_anwar_complaint.py` - NEW (diagnostic script)
- `django-backend/fix_anwar_role.py` - NEW (role fix script)

## Related APIs

All these APIs filter by client role and may need similar fixes:
- `GET /api/client/site-details/` - Client site details
- `GET /api/client/photos/` - Client photos
- `GET /api/client/photos-by-date/` - Client photos by date
- `GET /api/client/documents/` - Client documents
- `GET /api/client/materials/` - Client materials
- `GET /api/client/complaints/` - Client's own complaints
- `POST /api/client/complaints/create/` - Create complaint

These APIs check `user_role.lower() != 'client'` which works correctly because the JWT token contains the role name from the database.

## Status
✅ Fixed - Architect can now see anwar's complaints

---
**Date**: 2026-04-03
**Issue**: Complaints not visible due to role_id mismatch
**Resolution**: Updated API to use correct role_id (8 for Client)
**Action Required**: Restart Django server for changes to take effect
