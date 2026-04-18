# Render Database Setup Guide

## Issue
Getting "Invalid username or password" even with correct credentials because the Render database is empty.

## Solution
Run migrations and create users on Render.

## Step-by-Step Setup

### Method 1: Using Render Shell (Recommended)

1. **Go to Render Dashboard**
   - Visit https://dashboard.render.com
   - Select your service: `new-essentials`

2. **Open Shell**
   - Click on "Shell" tab in the left sidebar
   - This opens a terminal connected to your deployed service

3. **Navigate to Django Directory**
   ```bash
   cd django-backend
   ```

4. **Run Migrations**
   ```bash
   python manage.py migrate
   ```
   
   This creates all database tables.

5. **Create Superuser**
   ```bash
   python manage.py createsuperuser
   ```
   
   Enter:
   - Username: `admin`
   - Email: `admin@essentialhomes.com`
   - Password: `admin123`
   - Password (again): `admin123`

6. **Run Setup Script (Optional - Creates Multiple Users)**
   ```bash
   python setup_production_db.py
   ```
   
   This creates:
   - admin / admin123 (Admin)
   - siva / siva123 (Admin)
   - accountant1 / accountant123 (Accountant)
   - supervisor1 / supervisor123 (Supervisor)
   - architect1 / architect123 (Architect)
   - client1 / client123 (Client)

### Method 2: Add to Build Command

Update your Render service build command to run migrations automatically:

1. **Go to Render Dashboard**
2. **Select your service**
3. **Go to Settings**
4. **Update Build Command**:
   ```bash
   pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate
   ```

5. **Add Post-Deploy Script** (if available):
   ```bash
   python django-backend/setup_production_db.py
   ```

### Method 3: Using Render API (Advanced)

If you have Render API access, you can run commands via API:

```bash
curl -X POST https://api.render.com/v1/services/YOUR_SERVICE_ID/shell \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"command": "cd django-backend && python manage.py migrate"}'
```

## Verify Setup

### Test API
```bash
curl https://new-essentials.onrender.com/api/
```

Should return JSON with API endpoints.

### Test Login
```bash
curl -X POST https://new-essentials.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Should return:
```json
{
  "token": "...",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "admin",
    ...
  }
}
```

### Test in Flutter App
1. Open app
2. Login with: `admin` / `admin123`
3. Should successfully login and show dashboard

## Default Users Created

After running `setup_production_db.py`:

| Username | Password | Role | Access |
|----------|----------|------|--------|
| admin | admin123 | Admin | Full access |
| siva | siva123 | Admin | Full access |
| accountant1 | accountant123 | Accountant | Bills, reports |
| supervisor1 | supervisor123 | Supervisor | Site entries |
| architect1 | architect123 | Architect | Plans, documents |
| client1 | client123 | Client | View only |

## Troubleshooting

### "No module named 'construction'"
- Make sure you're in the `django-backend` directory
- Run: `cd django-backend`

### "Database connection error"
- Check environment variables in Render
- Verify Supabase credentials:
  - DB_HOST
  - DB_NAME
  - DB_USER
  - DB_PASSWORD
  - DB_PORT

### "Table doesn't exist"
- Run migrations first: `python manage.py migrate`
- Then run setup script

### "User already exists"
- This is fine, it means users are already created
- Try logging in with existing credentials

### Shell not available in Render
- Free tier might have limited shell access
- Use Method 2 (build command) instead
- Or upgrade to paid plan for shell access

## Important Notes

### Change Passwords in Production!
The default passwords are for testing only. Change them:

```bash
python manage.py changepassword admin
```

Or in Django admin:
1. Go to https://new-essentials.onrender.com/admin
2. Login with admin credentials
3. Change passwords for all users

### Database Persistence
- Supabase database is persistent
- Users and data will remain after Render restarts
- You only need to run setup once

### Automatic Migrations
Add to your `render.yaml`:

```yaml
services:
  - type: web
    name: new-essentials
    buildCommand: pip install -r requirements.txt && python manage.py migrate && python manage.py collectstatic --noinput
    startCommand: gunicorn backend.wsgi:application
```

This runs migrations on every deployment.

## Quick Fix (Right Now)

**Fastest solution**:

1. Go to https://dashboard.render.com
2. Select `new-essentials` service
3. Click "Shell" tab
4. Run these commands:
   ```bash
   cd django-backend
   python manage.py migrate
   python manage.py createsuperuser
   # Enter: admin / admin@essentialhomes.com / admin123
   ```

5. Test login in your Flutter app

That's it! Your database will be set up and you can login.

## Summary

The issue is that Render deployed your code but didn't run migrations or create users. Use Render Shell to run migrations and create a superuser, then you'll be able to login.

✅ Run migrations
✅ Create superuser
✅ Test login
✅ Done!
