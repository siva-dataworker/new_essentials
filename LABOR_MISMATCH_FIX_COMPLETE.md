# Labor Entry Mismatch Detection - Issue Fixed ✅

## Problem Identified

The labor mismatch detection was showing incorrect results because:

1. **Database Structure Issue**: Both Supervisor and Site Engineer entries are stored in the same `labour_entries` table, differentiated by the `submitted_by_role` column
2. **Missing Field in Backend**: The `submit_labour_count` function wasn't setting the `submitted_by_role` field when inserting new entries
3. **Incorrect Existing Data**: Existing entries by aravind (Site Engineer) were incorrectly marked as "Supervisor"

## Root Cause

When labor entries were submitted, the backend code didn't include the `submitted_by_role` field in the INSERT statement. This caused:
- All entries to have NULL or default "Supervisor" role
- aravind's entries (who is a Site Engineer) were marked as "Supervisor"
- Mismatch detection couldn't differentiate between Supervisor and Site Engineer entries

## Solution Implemented

### 1. Backend Code Fix (views_construction.py)

**Added user role extraction from JWT token:**
```python
user_id = request.user['user_id']
user_role = request.user.get('role', 'Supervisor')  # Get user role from JWT token
```

**Updated INSERT statement to include submitted_by_role:**
```python
execute_query("""
    INSERT INTO labour_entries 
    (id, site_id, supervisor_id, labour_count, labour_type, entry_date, entry_time, 
     day_of_week, notes, extra_cost, extra_cost_notes, submitted_by_role)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
""", (entry_id, site_id, user_id, labour_count, labour_type, entry_date, entry_time, 
      day_of_week, notes, extra_cost, extra_cost_notes, user_role))
```

### 2. Mismatch Detection Fix (views_labor_mismatch.py)

**Updated queries to filter by submitted_by_role:**
- Supervisor entries: `WHERE l.submitted_by_role = 'Supervisor'`
- Site Engineer entries: `WHERE l.submitted_by_role = 'Site Engineer'`

**Removed reference to non-existent table:**
- Changed from querying `site_engineer_entries` table (doesn't exist)
- To querying `labour_entries` table with role filter

### 3. Database Fix (apply_role_fix.py)

**Fixed existing entries:**
```sql
UPDATE labour_entries l
SET submitted_by_role = r.role_name
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE l.supervisor_id = u.id
AND (l.submitted_by_role IS NULL OR l.submitted_by_role != r.role_name)
```

## Verification Results

### Before Fix:
```
❌ Electrician: Supervisor (shhsjs) - 2 workers, marked as "Supervisor"
❌ Plumber: Supervisor (aravind) - 2 workers, marked as "Supervisor" (WRONG!)
```

### After Fix:
```
✅ Electrician: Supervisor (shhsjs) - 2 workers, marked as "Supervisor"
✅ Plumber: Site Engineer (aravind) - 2 workers, marked as "Site Engineer"
```

### Mismatch Detection Now Shows:
```
✗ MISSING SITE ENGINEER ENTRY: Electrician on 2026-02-14
  Supervisor (shhsjs): 2 workers
  Site Engineer: No entry

✗ MISSING SUPERVISOR ENTRY: Plumber on 2026-02-14
  Supervisor: No entry
  Site Engineer (aravind): 2 workers

Total mismatches: 2
```

## User Roles Confirmed

From database:
- **shhsjs**: role_id = 2 (Supervisor) ✅
- **aravind**: role_id = 3 (Site Engineer) ✅

## Files Modified

1. `django-backend/api/views_construction.py` - Added submitted_by_role field to labor entry submission
2. `django-backend/api/views_labor_mismatch.py` - Fixed mismatch detection to use correct table and role filtering
3. `django-backend/apply_role_fix.py` - Script to fix existing database entries

## Testing

The fix has been applied and verified:
- ✅ Database entries corrected
- ✅ Backend code updated
- ✅ Mismatch detection working correctly
- ✅ Backend restarted on Process ID: 4

## Next Steps

1. Hot restart the Flutter app (press 'R' in terminal)
2. Test the mismatch detection in the accountant view
3. The warning icon should now show accurate mismatches

## Expected Behavior

When you click the warning icon in the accountant view, you should see:
- **Electrician**: Missing Site Engineer Entry (only Supervisor shhsjs submitted)
- **Plumber**: Missing Supervisor Entry (only Site Engineer aravind submitted)

This is the CORRECT behavior - it shows that for each labor type, only one role submitted an entry, and the other role's entry is missing.
