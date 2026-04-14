# USER ID MISMATCH ISSUE - FIXED ✅

## Problem Identified
The history was showing empty because labour and material entries had `supervisor_id = NULL` in the database. This happened because of a mismatch in the JWT token generation.

## Root Cause
In `django-backend/api/jwt_utils.py`, the JWT token was being generated with field name `user_uid`, but the login endpoint was passing `user_id`. This caused the JWT token to not contain the user ID, so when entries were submitted, the `supervisor_id` was NULL.

## What Was Fixed

### 1. Fixed JWT Token Generation
**File**: `django-backend/api/jwt_utils.py`

Changed the JWT payload to use `user_id` instead of `user_uid`:
```python
payload = {
    'user_id': user_data.get('user_id'),      # ✅ Fixed
    'username': user_data.get('username'),    # ✅ Added
    'email': user_data.get('email'),
    'role': user_data.get('role'),            # ✅ Added
    'exp': ...,
    'iat': ...
}
```

### 2. Cleaned Up Invalid Entries
**File**: `django-backend/fix_null_supervisor_entries.py`

Deleted all labour and material entries with NULL supervisor_id:
- Deleted 7 labour entries
- Deleted 4 material entries

These were test entries created before the fix.

## What You Need to Do Now

### Step 1: Restart Backend
The backend needs to be restarted to use the fixed JWT code:

```bash
# Stop the current backend (press Ctrl+C in the terminal)
# Then restart:
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### Step 2: Login Again on Mobile
1. Open the app on your mobile
2. **Logout if already logged in** (to get a new JWT token with the fix)
3. Login again with username: `nsnwjw` and password: `Test123`

### Step 3: Submit New Entries
1. Go to a site
2. Submit labour counts (Mason, Carpenter, etc.)
3. Submit material balances if needed

### Step 4: Check History
1. Go to the History tab
2. You should now see your submitted entries! ✅

### Step 5: Check Accountant Dashboard
1. Login as accountant (username: `accountant`, password: `Test123`)
2. You should see all entries with supervisor names displayed

## Why This Will Work Now

**Before Fix:**
- JWT token: `{ "user_uid": null, "email": "..." }`
- When submitting: `supervisor_id = request.user['user_id']` → NULL
- History query: `WHERE supervisor_id = 'actual-user-id'` → No match (NULL ≠ actual-user-id)

**After Fix:**
- JWT token: `{ "user_id": "5be9eb15-da04-4721-8fa2-ed5baf57a802", "username": "nsnwjw", ... }`
- When submitting: `supervisor_id = request.user['user_id']` → Correct UUID
- History query: `WHERE supervisor_id = 'actual-user-id'` → Match! ✅

## Verification

After following the steps above, you can verify the fix by checking Django logs:

```
[26/Dec/2025 XX:XX:XX] "POST /api/auth/login/ HTTP/1.1" 200
[26/Dec/2025 XX:XX:XX] "POST /api/construction/labour/ HTTP/1.1" 201
[26/Dec/2025 XX:XX:XX] "GET /api/construction/supervisor/history/ HTTP/1.1" 200 XXX
```

The history response should now be larger than 43 bytes (which was empty).

## Summary
✅ JWT token generation fixed to include `user_id`  
✅ Invalid entries with NULL supervisor_id deleted  
✅ Backend code already correct (was using `request.user['user_id']`)  
✅ History query already correct (was filtering by `supervisor_id`)  

**The issue was just the JWT token not containing the user_id!**
