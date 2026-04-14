# 📋 HOW TO APPROVE USERS - STEP BY STEP

## METHOD 1: Using Supabase Dashboard (EASIEST)

### Step 1: Open Supabase
1. Go to: **https://supabase.com/dashboard**
2. Login with your account
3. Click on your project (the one with ID: `ctwthgjuccioxivnzifb`)

### Step 2: Open Table Editor
1. Look at the left sidebar
2. Click on **"Table Editor"** (icon looks like a table/grid)
3. You'll see a list of tables

### Step 3: Open Users Table
1. Find and click on **"users"** table
2. You'll see all registered users in a spreadsheet-like view

### Step 4: Find Pending User
1. Look for the row where **status** column shows **"PENDING"**
2. You'll see columns: id, username, email, phone, password_hash, full_name, role_id, **status**, created_at

### Step 5: Change Status to APPROVED
1. Click on the **status** cell that shows "PENDING"
2. A dropdown or text field will appear
3. Change it to: **APPROVED** (all caps)
4. Press Enter or click outside to save
5. You should see a green checkmark or success message

### Step 6: Done!
- The user can now login
- Go back to your app and try logging in

---

## METHOD 2: Using SQL Editor (ALTERNATIVE)

### Step 1: Open SQL Editor
1. Go to Supabase Dashboard
2. Click **"SQL Editor"** in the left sidebar
3. Click **"New query"**

### Step 2: View All Pending Users
Copy and paste this query:
```sql
SELECT id, username, email, phone, full_name, role_id, status 
FROM users 
WHERE status = 'PENDING';
```
Click **"Run"** to see all pending users.

### Step 3: Approve a Specific User
Copy this query and **replace 'USERNAME'** with the actual username:
```sql
UPDATE users 
SET status = 'APPROVED' 
WHERE username = 'USERNAME';
```

Example:
```sql
UPDATE users 
SET status = 'APPROVED' 
WHERE username = 'john_doe';
```

Click **"Run"** to approve the user.

### Step 4: Verify
Run this query to confirm:
```sql
SELECT username, status FROM users WHERE username = 'USERNAME';
```

You should see status = 'APPROVED'

---

## METHOD 3: Approve ALL Pending Users at Once

If you want to approve everyone who's waiting:

```sql
UPDATE users 
SET status = 'APPROVED' 
WHERE status = 'PENDING';
```

This will approve all pending users in one go.

---

## 🔍 QUICK REFERENCE

### Your Supabase Details:
- **Dashboard**: https://supabase.com/dashboard
- **Project ID**: ctwthgjuccioxivnzifb
- **Database**: postgres
- **Table**: users
- **Column to change**: status
- **Change from**: PENDING
- **Change to**: APPROVED

### Status Values:
- `PENDING` - User registered, waiting for approval
- `APPROVED` - User can login and use the app
- `REJECTED` - User cannot login

---

## 📱 AFTER APPROVAL

Once you change status to APPROVED:

1. **Go to your phone app**
2. **Try to login** with:
   - Username: (the one you registered)
   - Password: (the one you registered)
3. **You should see**: Supervisor Dashboard
4. **You can now**: Select site and enter labour/material data

---

## ⚠️ TROUBLESHOOTING

### Can't find the users table?
- Make sure you applied the database schema first
- Go to SQL Editor and run the content from: `django-backend/construction_management_schema.sql`

### Status won't change?
- Make sure you type exactly: `APPROVED` (all caps)
- Try using SQL Editor method instead

### Still can't login after approval?
- Verify status changed: Run `SELECT username, status FROM users;`
- Make sure backend is running: http://192.168.1.7:8000/api/auth/roles/
- Check if you're using the correct username/password

---

## 🎯 FASTEST WAY (RECOMMENDED)

1. Open: https://supabase.com/dashboard
2. Click: Table Editor → users
3. Find: Row with status = "PENDING"
4. Click: On the "PENDING" text
5. Type: APPROVED
6. Press: Enter
7. Done! ✅

Now go login in your app!
