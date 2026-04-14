# All Users and Passwords

## Current Users in Database

### 1. Admin User
- **Username**: `admin`
- **Password**: `admin123`
- **Email**: admin@construction.com
- **Phone**: 1234567890
- **Full Name**: System Administrator
- **Role**: Admin
- **Status**: APPROVED
- **Access**: Full admin dashboard with user management

---

### 2. Supervisor User
- **Username**: `nsjskakaka`
- **Password**: `Test123`
- **Email**: supervisor@test.com
- **Phone**: 9876543210
- **Full Name**: Test Supervisor
- **Role**: Supervisor
- **Status**: APPROVED
- **Access**: Supervisor dashboard with labour count and material balance entry

---

### 3. Site Engineer User
- **Username**: `nsnwjw`
- **Password**: `Test123`
- **Email**: engineer@test.com
- **Phone**: 9876543211
- **Full Name**: Test Engineer
- **Role**: Site Engineer
- **Status**: APPROVED
- **Access**: Site Engineer dashboard with work updates and photo uploads

---

## Quick Login Reference

| Role | Username | Password | Status |
|------|----------|----------|--------|
| Admin | `admin` | `admin123` | ✅ APPROVED |
| Supervisor | `nsjskakaka` | `Test123` | ✅ APPROVED |
| Site Engineer | `nsnwjw` | `Test123` | ✅ APPROVED |

---

## How to Create New Users

### Option 1: Register via App
1. Open the app
2. Click "Register" on login screen
3. Fill in all details:
   - Username (unique)
   - Email
   - Phone
   - Password (minimum 6 characters)
   - Full Name
   - Select Role
4. Submit registration
5. Wait for admin approval
6. Login after approval

### Option 2: Direct Database Insert (For Testing)

Run this SQL in Supabase SQL Editor:

```sql
-- Insert a new user (replace values as needed)
INSERT INTO users (
    id, 
    username, 
    email, 
    phone, 
    password_hash, 
    full_name, 
    role_id, 
    status
)
VALUES (
    gen_random_uuid(),
    'new_username',
    'email@example.com',
    '1234567890',
    'pbkdf2_sha256$870000$...',  -- Use Django password hash
    'Full Name',
    (SELECT id FROM roles WHERE role_name = 'Supervisor'),
    'APPROVED'
);
```

**Note**: For password hash, use the Python script below.

---

## Generate Password Hash (Python Script)

Create `generate_password.py` in `django-backend/`:

```python
from django.contrib.auth.hashers import make_password

# Generate password hash
password = "YourPassword123"
password_hash = make_password(password)

print(f"Password: {password}")
print(f"Hash: {password_hash}")
```

Run:
```bash
cd django-backend
python generate_password.py
```

---

## Available Roles

1. **Admin** - User management, system oversight
2. **Supervisor** - Labour count, material balance, site selection
3. **Site Engineer** - Work updates, photo uploads, complaint handling
4. **Accountant** - Bills, labour verification, payments
5. **Architect** - Plans, designs, estimations, complaints
6. **Owner** - Full view access, reports, P&L

---

## User Approval Workflow

### For New Registrations:

1. **User registers** → Status: PENDING
2. **Admin reviews** in Admin Dashboard → Users tab → New Users
3. **Admin approves/rejects**:
   - ✅ Approve → Status: APPROVED → User can login
   - ❌ Reject → Status: REJECTED → User cannot login

### Admin Dashboard Access:
- Login as `admin` / `admin123`
- Go to "Users" tab
- Toggle between "New Users" and "All Users"
- Approve or reject pending users

---

## Password Reset (Manual Method)

If a user forgets their password, admin can reset it:

### Method 1: Using Python Script

Create `reset_password.py` in `django-backend/`:

```python
import os
import django
import psycopg2
from django.contrib.auth.hashers import make_password

# Django setup
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

# Database connection
from api.database import get_db_connection

def reset_user_password(username, new_password):
    """Reset password for a user"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Generate new password hash
        password_hash = make_password(new_password)
        
        # Update password
        cursor.execute("""
            UPDATE users 
            SET password_hash = %s 
            WHERE username = %s
        """, (password_hash, username))
        
        conn.commit()
        print(f"✅ Password reset successful for user: {username}")
        print(f"New password: {new_password}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

# Usage
if __name__ == "__main__":
    username = input("Enter username: ")
    new_password = input("Enter new password: ")
    reset_user_password(username, new_password)
```

Run:
```bash
cd django-backend
python reset_password.py
```

### Method 2: Direct SQL in Supabase

```sql
-- Generate hash using Django (run in Python first)
-- Then update in SQL:
UPDATE users 
SET password_hash = 'pbkdf2_sha256$870000$...'
WHERE username = 'username_here';
```

---

## Testing Credentials Summary

### For Development/Testing:

**Admin Access:**
```
URL: http://192.168.1.7:8000/api/auth/login/
Username: admin
Password: admin123
```

**Supervisor Access:**
```
Username: nsjskakaka
Password: Test123
```

**Site Engineer Access:**
```
Username: nsnwjw
Password: Test123
```

---

## Security Notes

⚠️ **IMPORTANT FOR PRODUCTION:**

1. **Change default passwords** before deploying to production
2. **Use strong passwords** (minimum 12 characters, mix of letters, numbers, symbols)
3. **Enable password complexity** requirements
4. **Implement password expiry** (force change every 90 days)
5. **Add two-factor authentication** for admin users
6. **Log all password changes** in audit logs
7. **Never share passwords** via insecure channels
8. **Use environment variables** for admin credentials

---

## Password Policy Recommendations

For production, enforce:
- Minimum 12 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character
- No common passwords (password123, admin123, etc.)
- No username in password
- Password history (can't reuse last 5 passwords)

---

## Troubleshooting Login Issues

### "Invalid username or password"
- Check username spelling (case-sensitive)
- Check password (case-sensitive)
- Verify user status is APPROVED
- Check user is_active = true

### "Account pending approval"
- User status is PENDING
- Admin needs to approve in Admin Dashboard

### "Account rejected"
- User status is REJECTED
- Contact admin for re-approval

### Backend not responding
- Check Django is running: `http://192.168.1.7:8000/api/health/`
- Check database connection
- Check network connectivity

---

## Quick Commands

### Check all users in database:
```bash
cd django-backend
python -c "from api.database import fetch_all; users = fetch_all('SELECT username, role_id, status FROM users'); print(users)"
```

### Count users by status:
```sql
SELECT status, COUNT(*) 
FROM users 
GROUP BY status;
```

### List all approved users:
```sql
SELECT u.username, u.email, r.role_name, u.status
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.status = 'APPROVED'
ORDER BY u.created_at DESC;
```

---

## Contact

For password resets or account issues:
- Contact System Administrator
- Email: admin@construction.com
- Or use the Admin Dashboard for user management

---

**Last Updated**: December 24, 2025
**Total Users**: 3 (1 Admin, 1 Supervisor, 1 Site Engineer)
**All users are APPROVED and ready to use**
