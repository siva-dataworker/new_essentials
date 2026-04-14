# 🔍 WHERE TO MANAGE USERS - IMPORTANT!

## ⚠️ CONFUSION CLARIFIED

You're looking at the **Django Admin Page** (http://192.168.1.7:8000/admin/)
But users are managed in **Supabase Dashboard** (https://supabase.com/dashboard)

---

## 🎯 TWO DIFFERENT ADMIN PANELS

### 1. Django Admin (http://192.168.1.7:8000/admin/)
- **Purpose**: Manage Django's internal models
- **What you see**: Only `sites` table (from old code)
- **NOT for user management**: Users table is NOT registered here
- **You DON'T need this**: This is for Django framework, not your app

### 2. Supabase Dashboard (https://supabase.com/dashboard) ✅
- **Purpose**: Manage your actual database
- **What you see**: ALL tables (users, sites, labour_entries, etc.)
- **THIS is your admin panel**: Manage users here
- **You NEED this**: This is where you approve users

---

## ✅ CORRECT WAY TO MANAGE USERS

### Go to Supabase Dashboard:
1. **Open browser**
2. **Go to**: https://supabase.com/dashboard
3. **Login** with your Supabase account
4. **Select project**: `ctwthgjuccioxivnzifb`
5. **Click**: Table Editor (left sidebar)
6. **Click**: `users` table
7. **You'll see**: All registered users with their details

---

## 📊 WHAT YOU'LL SEE IN SUPABASE

### Users Table:
| id | username | email | phone | full_name | role_id | status | created_at |
|----|----------|-------|-------|-----------|---------|--------|------------|
| uuid | admin | admin@... | 999... | System Admin | 1 | APPROVED | 2025-12-23 |
| uuid | nsjskakaka | sivabalan... | 545... | hshshsh | 2 | APPROVED | 2025-12-23 |
| uuid | nsnwjw | sbalan... | 878... | shhsjs | 2 | APPROVED | 2025-12-23 |

**Role IDs:**
- 1 = Admin
- 2 = Supervisor
- 3 = Site Engineer
- 4 = Accountant
- 5 = Architect
- 6 = Owner

---

## 🔧 HOW TO APPROVE USERS IN SUPABASE

### Step-by-Step:

1. **Go to Supabase Dashboard**
   - URL: https://supabase.com/dashboard
   - Login with your account

2. **Select Your Project**
   - Project ID: `ctwthgjuccioxivnzifb`
   - Project Name: (your project name)

3. **Open Table Editor**
   - Click "Table Editor" in left sidebar
   - You'll see list of tables

4. **Open Users Table**
   - Click on "users" table
   - You'll see all users in a spreadsheet view

5. **Find Pending Users**
   - Look for rows where `status = 'PENDING'`
   - These are users waiting for approval

6. **Approve User**
   - Click on the `status` cell
   - Change from `PENDING` to `APPROVED`
   - Press Enter or click outside
   - User is now approved!

---

## 🚫 DON'T USE DJANGO ADMIN

### Why Django Admin Shows Only Sites:
The Django admin at http://192.168.1.7:8000/admin/ only shows models that are registered in `django-backend/api/admin.py`.

Currently, only the old `sites` model is registered there. The new `users` table is in Supabase, not in Django models.

### What to Do:
- ❌ **Don't use**: http://192.168.1.7:8000/admin/
- ✅ **Use instead**: https://supabase.com/dashboard

---

## 📱 COMPLETE WORKFLOW

### 1. User Registers (Mobile App)
```
User fills form:
- Username: john_doe
- Email: john@example.com
- Phone: 9876543210
- Password: ********
- Role: Supervisor
```

### 2. Data Goes to Supabase
```
Database: Supabase PostgreSQL
Table: users
Status: PENDING
```

### 3. Admin Approves (Supabase Dashboard)
```
Admin logs into: https://supabase.com/dashboard
Opens: Table Editor → users
Finds: john_doe with status = PENDING
Changes: status to APPROVED
Saves
```

### 4. User Can Login (Mobile App)
```
User tries to login
System checks Supabase: status = APPROVED ✅
User gets access to dashboard
```

---

## 🔗 QUICK ACCESS LINKS

### For Admin:
- **Supabase Dashboard**: https://supabase.com/dashboard
- **Project ID**: `ctwthgjuccioxivnzifb`
- **Database Host**: `aws-1-ap-northeast-1.pooler.supabase.com`

### For Reference (Don't Need):
- Django Admin: http://192.168.1.7:8000/admin/ (not used for users)

---

## 💡 WHY TWO ADMIN PANELS?

### Django Admin:
- Built-in Django feature
- For Django's internal models
- We're not using it for this app
- Only shows old `sites` model

### Supabase Dashboard:
- Your actual database admin panel
- Shows ALL your tables
- This is where your data lives
- This is what you should use

---

## ✅ SUMMARY

**To manage users:**
1. ❌ Don't go to: http://192.168.1.7:8000/admin/
2. ✅ Go to: https://supabase.com/dashboard
3. ✅ Open: Table Editor → users
4. ✅ Change: status from PENDING to APPROVED

**That's it!**

---

## 🎯 NEXT STEPS

1. **Open Supabase Dashboard** now
2. **Login** with your Supabase account
3. **Select your project**
4. **Go to Table Editor**
5. **Click on users table**
6. **You'll see all 3 users** (admin, nsjskakaka, nsnwjw)

Try it now and let me know what you see!
