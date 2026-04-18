# Fix Render Database Connection Error - IPv6 Issue SOLVED

## The Problem

Render logs show:
```
[DB ERROR] connection is bad: connection to server at "2406:da14:271:990b:19d6:6f08:6af7:e69d" 
port 5432 failed: Network is unreachable
[LOGIN] User not found: admin
```

**Root Cause**: Render is trying to connect via IPv6 address which fails. Supabase direct connection uses IPv6 by default, but Render doesn't support it.

## ✅ SOLUTION: Use Supabase Session Pooler (IPv4)

Supabase provides a Session Pooler that uses IPv4 and works perfectly with Render.

### Step 1: Update Render Environment Variables

Go to Render Dashboard → Your Service → Environment tab

Update these variables:

```
DB_HOST=aws-0-ap-south-1.pooler.supabase.com
DB_PORT=5432
DB_USER=postgres.ctwthgjuccioxivnzifb
DB_PASSWORD=Appdevlopment@2026
DB_NAME=postgres
```

**Key Changes**:
- `DB_HOST` changed from `db.ctwthgjuccioxivnzifb.supabase.co` to `aws-0-ap-south-1.pooler.supabase.com`
- `DB_USER` changed from `postgres` to `postgres.ctwthgjuccioxivnzifb`
- `DB_PORT` stays `5432` (Session mode, NOT 6543 transaction mode)

### Step 2: Redeploy Render Service

After updating environment variables:

1. Click "Manual Deploy" → "Deploy latest commit"
2. OR click the three dots menu → "Restart Service"

This forces Render to reload environment variables and reconnect to database.

### Step 3: Verify in Logs

After redeployment, check logs. You should see:
- ✅ No more IPv6 errors
- ✅ No more "Network is unreachable"
- ✅ "Your service is live 🎉"

### Step 4: Test Login

Try logging in with:
- Username: `Siva` Password: `Test123`
- OR Username: `admin` Password: `admin123`

Should work now!

---

## Why This Works

- **Direct Connection**: Uses IPv6 by default → Render doesn't support IPv6 → Connection fails
- **Session Pooler**: Uses IPv4 → Render supports IPv4 → Connection works ✅

The Session Pooler is specifically designed for persistent servers like Render that need IPv4 connectivity.

---

## Troubleshooting

### If you still see errors after updating:

1. **Verify environment variables are saved**:
   - Go to Render Dashboard → Environment
   - Check all 5 variables are there
   - Click "Save Changes" if needed

2. **Check you redeployed**:
   - Environment changes require a redeploy
   - Look for "Deploy in progress" message
   - Wait for "Your service is live 🎉"

3. **Test in Render Shell**:
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

4. **Check Supabase Dashboard**:
   - Go to Project Settings → Database
   - Verify Session Pooler connection string matches
   - Should be: `aws-0-ap-south-1.pooler.supabase.com:5432`

---

## Alternative: Transaction Mode Pooler (Port 6543)

If Session mode doesn't work, try Transaction mode:

```
DB_HOST=aws-0-ap-south-1.pooler.supabase.com
DB_PORT=6543
DB_USER=postgres.ctwthgjuccioxivnzifb
DB_PASSWORD=Appdevlopment@2026
DB_NAME=postgres
```

**Note**: Transaction mode (port 6543) doesn't support prepared statements. You may need to disable them in Django settings.

---

## Summary

✅ **The Fix**: Use Supabase Session Pooler instead of direct connection

**3 Simple Steps**:
1. Update Render environment variables (use pooler host and modified username)
2. Redeploy Render service
3. Test login

The IPv6 error will be gone and database connection will work!
