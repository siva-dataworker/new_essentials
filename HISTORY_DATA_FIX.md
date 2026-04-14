# History Data Not Showing - Fix Guide

## Problem
Supervisor entries and accountant data not showing in history/dashboard.

## Root Cause
The `labour_entries` table had a `UNIQUE(site_id, entry_date)` constraint that prevented multiple labour types from being submitted for the same site on the same day.

## Solution Applied

### 1. Database Schema Fix
**File**: `django-backend/construction_management_schema.sql`
- Removed `UNIQUE(site_id, entry_date)` constraint from labour_entries table
- This allows multiple labour entries (Carpenter, Mason, etc.) per site per day

### 2. Backend API Fix
**File**: `django-backend/api/views_construction.py`
- Removed the duplicate check that prevented multiple submissions
- Fixed table name from `material_balance` to `material_balances`
- Fixed column references to match schema (`entry_time` instead of `created_at`)
- Added proper data serialization for history APIs

### 3. Database Migration Required
Run this SQL to fix existing database:
```sql
ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS labour_entries_site_id_entry_date_key;
```

Or run the provided script:
```bash
cd django-backend
psql -h <host> -U <user> -d <database> -f fix_unique_constraint.sql
```

## Steps to Fix

### Step 1: Update Database Constraint
You need to remove the UNIQUE constraint from your Supabase database:

1. Go to Supabase Dashboard → SQL Editor
2. Run this command:
```sql
ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS labour_entries_site_id_entry_date_key;
```

### Step 2: Restart Django Backend
```bash
cd django-backend
python manage.py runserver 192.168.1.7:8000
```

### Step 3: Test the Flow
1. Login as Supervisor (username: `nsjskakaka`, password: `Test123`)
2. Select a site from the feed
3. Tap the + button
4. Add multiple labour types (Carpenter: 2, Mason: 3, etc.)
5. Submit
6. Check History tab - should show all entries
7. Login as Accountant and check dashboard - should see all entries with supervisor names

## API Endpoints

### Supervisor History
```
GET /api/construction/supervisor/history/
```
Returns:
- `labour_entries`: Array of labour entries with site info
- `material_entries`: Array of material entries with site info

### Accountant All Entries
```
GET /api/construction/accountant/all-entries/
```
Returns:
- `labour_entries`: Array with supervisor names
- `material_entries`: Array with supervisor names

## Verification

After fixing, you should see:
- ✅ Supervisor can submit multiple labour types per day
- ✅ Supervisor History tab shows all submitted entries
- ✅ Accountant dashboard shows all entries from all supervisors
- ✅ Each entry displays supervisor name
- ✅ Entries grouped by date (Today, Yesterday, etc.)

## Common Issues

### Issue 1: "Labour count already submitted for today"
**Cause**: Old backend code still running
**Fix**: Restart Django backend

### Issue 2: Empty history/dashboard
**Cause**: UNIQUE constraint still exists in database
**Fix**: Run the SQL command to drop constraint

### Issue 3: "Table material_balance does not exist"
**Cause**: Wrong table name in query
**Fix**: Already fixed in views_construction.py (uses `material_balances`)

### Issue 4: Backend not loading new code
**Cause**: Django dev server needs restart
**Fix**: Stop (Ctrl+C) and restart: `python manage.py runserver 192.168.1.7:8000`

## Files Modified
1. `django-backend/construction_management_schema.sql` - Removed UNIQUE constraint
2. `django-backend/api/views_construction.py` - Fixed APIs and removed duplicate check
3. `django-backend/fix_unique_constraint.sql` - SQL script to fix existing database

## Next Steps
1. Drop the UNIQUE constraint in Supabase
2. Restart Django backend
3. Test supervisor submission
4. Verify history shows data
5. Verify accountant sees all data
