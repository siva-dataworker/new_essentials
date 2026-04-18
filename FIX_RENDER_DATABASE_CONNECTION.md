# Fix Render Database Connection Error

## The Problem

Render logs show:
```
[DB ERROR] connection is bad: connection to server at "2406:da14:271:990b:19d6:6f08:6af7:e69d" 
port 5432 failed: Network is unreachable
[LOGIN] User not found: admin
```

**Root Cause**: Render cannot connect to Supabase database. It's trying IPv6 which is failing.

## Solution: Update Render Environment Variables

### Step 1: Go to Render Dashboard

1. Visit: https://dashboard.render.com
2. Select your service: `new-essentials`
3. Click "Environment" tab in the left sidebar

### Step 2: Verify/Update These Variables

Make sure these environment variables are set correctly:

```
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=Appdevlopment@2026
DB_HOST=db.ctwthgjuccioxivnzifb.supabase.co
DB_PORT=5432
```

### Step 3: Add Connection String (Alternative)

If the above doesn't work, try using a full connection string:

Add this environment variable:
```
DATABASE_URL=postgresql://postgres:Appdevlopment@2026@db.ctwthgjuccioxivnzifb.supabase.co:5432/postgres?sslmode=require
```

### Step 4: Force IPv4 Connection

Add this to force IPv4:
```
PGHOST=db.ctwthgjuccioxivnzifb.supabase.co
PGHOSTADDR=
```

### Step 5: Update Django Settings

The issue might be in how Django connects. Let me update the settings to handle this better.

## Quick Fix: Update settings.py

Update the database configuration to use connection pooling and force IPv4:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME', default='postgres'),
        'USER': config('DB_USER', default='postgres'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST'),
        'PORT': config('DB_PORT', default='5432'),
        'OPTIONS': {
            'sslmode': 'require',
            'client_encoding': 'UTF8',
            'connect_timeout': 10,
        },
        'CONN_MAX_AGE': 600,  # Connection pooling
    }
}
```

## Alternative: Use Supabase Connection Pooler

Supabase provides a connection pooler that works better with serverless:

### Get Pooler URL from Supabase:

1. Go to Supabase Dashboard
2. Project Settings → Database
3. Look for "Connection Pooling" section
4. Copy the "Connection string" (Transaction mode)

It will look like:
```
postgresql://postgres.ctwthgjuccioxivnzifb:[PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
```

### Update Render Environment Variables:

```
DB_HOST=aws-0-ap-south-1.pooler.supabase.com
DB_PORT=6543
DB_USER=postgres.ctwthgjuccioxivnzifb
DB_PASSWORD=Appdevlopment@2026
DB_NAME=postgres
```

## Test Connection from Render Shell

1. Go to Render Dashboard → Shell
2. Run:

```bash
cd django-backend
python manage.py shell
```

Then:
```python
from django.db import connection
cursor = connection.cursor()
cursor.execute("SELECT 1")
print("✅ Database connected!")
```

If this works, the connection is fine.

## Check Supabase Firewall

1. Go to Supabase Dashboard
2. Project Settings → Database
3. Check "Connection Pooling" is enabled
4. Check if there are any IP restrictions

Supabase should allow connections from anywhere by default, but verify.

## Restart Render Service

After updating environment variables:

1. Go to Render Dashboard
2. Click "Manual Deploy" → "Deploy latest commit"
3. Or click "Restart Service"

This forces Render to reload environment variables.

## Verify Environment Variables are Set

In Render Shell:
```bash
echo $DB_HOST
echo $DB_PORT
echo $DB_USER
echo $DB_NAME
```

Should show your Supabase credentials.

## Test Login After Fix

Once database is connected, test:

```bash
curl -X POST https://new-essentials.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Should return JWT token.

## Summary

The issue is Render cannot connect to Supabase. Most likely:

1. ❌ Environment variables not set in Render
2. ❌ IPv6 connection failing
3. ❌ Connection pooler not used

**Quick Fix**:
1. Go to Render Dashboard → Environment
2. Set all DB_* variables
3. Restart service
4. Test connection in Shell

Then login will work!
