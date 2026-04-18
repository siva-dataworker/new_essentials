# Fix Login Issue - Users Exist But Can't Login

## The Problem

Users exist in the database, but you're getting "Invalid username or password" error.

## Root Cause

The passwords in the database might not match what you're trying. Your backend uses a custom `users` table (not Django's default `auth_user`).

## Quick Fix (2 minutes)

### Option 1: Try These Credentials

Based on your test scripts, try logging in with:

1. **Siva** / **Test123**
2. **admin** / **admin123**
3. **balut** / **balut123**
4. **client4** / **client4**

### Option 2: Reset All Passwords on Render

1. **Go to Render Dashboard**
   - https://dashboard.render.com
   - Select: `new-essentials`

2. **Open Shell**
   - Click "Shell" tab

3. **Run Password Check**
   ```bash
   cd django-backend
   python check_and_fix_passwords.py
   ```
   
   This shows all users and their passwords (if found).

4. **Reset All Passwords**
   ```bash
   python check_and_fix_passwords.py fix
   ```
   
   This sets standard passwords:
   - admin → admin123
   - Siva → siva123
   - balut → balut123
   - client4 → client123
   - etc.

5. **Test Login**
   - Try logging in with: **admin** / **admin123**

## What the Script Does

### Check Passwords:
```bash
python check_and_fix_passwords.py
```

Output:
```
👤 admin
   Role: Admin
   Status: APPROVED
   Active: True
   ✅ Password: admin123

👤 Siva
   Role: Accountant
   Status: APPROVED
   Active: True
   ✅ Password: Test123
```

### Fix Passwords:
```bash
python check_and_fix_passwords.py fix
```

Sets these passwords:
- admin → admin123
- Siva → siva123
- balut → balut123
- client4 → client123
- Any supervisor → supervisor123
- Any architect → architect123
- Any accountant → accountant123
- Others → test123

## Manual Password Reset (Alternative)

If you want to set a specific password for a user:

```bash
cd django-backend
python manage.py shell
```

Then:
```python
from django.contrib.auth.hashers import make_password
from api.db_utils import execute_query

# Set password for admin
password_hash = make_password('admin123')
execute_query(
    "UPDATE users SET password_hash = %s WHERE username = 'admin'",
    (password_hash,)
)
print("Password updated!")
```

## Test Login from Command Line

```bash
curl -X POST https://new-essentials.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Should return:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "...",
    "username": "admin",
    "role": "Admin",
    ...
  }
}
```

## Common Issues

### Issue 1: "User not found"
- Username is case-sensitive
- Try: `Siva` not `siva`
- Check exact username in database

### Issue 2: "Invalid password"
- Password might be different than expected
- Run check script to see actual passwords
- Or reset all passwords with fix script

### Issue 3: "User not active"
- Check `is_active` column in database
- Update: `UPDATE users SET is_active = true WHERE username = 'admin'`

### Issue 4: "User not approved"
- Check `status` column
- Update: `UPDATE users SET status = 'APPROVED' WHERE username = 'admin'`

## Verify Database Connection

Check Render is connected to correct database:

```bash
cd django-backend
python manage.py shell
```

Then:
```python
from api.db_utils import fetch_all
users = fetch_all("SELECT username, email FROM users LIMIT 5")
for user in users:
    print(f"{user['username']} - {user['email']}")
```

Should show your users from Supabase.

## Summary

1. ✅ Users exist in database
2. ✅ Backend is running
3. ✅ Database is connected
4. ❌ Passwords don't match

**Solution**: Run the password fix script on Render Shell, then login will work!

```bash
cd django-backend
python check_and_fix_passwords.py fix
```

Then login with: **admin** / **admin123**
