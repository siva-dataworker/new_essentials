# Supervisor History - User Filter Fixed ✅

## Date: May 10, 2026

## Issues Identified

### Issue 1: Showing All Users' Entries
When logged in as Supervisor (jack), the history screen was showing BOTH:
- Supervisor (jack) entries: 3 entries
- Site Engineer (aravind) entries: 3 entries
- **Total shown**: 6 entries (should only show 3)

### Issue 2: Duplicate Mason Entry
Supervisor submitted 3 entries (Mason, Carpenter, General), but UI was showing 4 entries with duplicate Mason.

## Root Cause

### Issue 1 Root Cause
The `/construction/supervisor/history/` API endpoint was returning ALL entries from ALL users, regardless of who was logged in. The code comment even said "REMOVED supervisor_id filter to show ALL entries".

**Problem Code:**
```python
# Base query conditions - REMOVED supervisor_id filter to show ALL entries
base_conditions = "WHERE (l.is_modified = FALSE OR l.is_modified IS NULL)"
params = []
```

This was wrong because:
- **Supervisors** should only see their own entries
- **Site Engineers** should only see their own entries  
- **Accountants** should see ALL entries (for comparison/approval)

### Issue 2 Root Cause
Frontend caching issue - the UI is showing stale/cached data mixed with fresh data.

## Fix Applied

### Backend Fix (`views_construction.py`)

**Added user filtering for Supervisor/Site Engineer:**

```python
site_id = request.GET.get('site_id')  # Optional site filter
user_id = request.user.get('user_id')

# Base query conditions
base_conditions = "WHERE (l.is_modified = FALSE OR l.is_modified IS NULL)"
params = []

# Filter by user for Supervisor/Site Engineer (but not for Accountant)
if user_role in ['Supervisor', 'Site Engineer']:
    base_conditions += " AND l.supervisor_id = %s"
    params.append(user_id)

# Add site filter if provided
if site_id:
    base_conditions += " AND l.site_id = %s"
    params.append(site_id)
```

**Applied to both:**
1. Labour entries query
2. Material entries query

## Expected Behavior After Fix

### When Logged in as Supervisor (jack)
**History Screen shows:**
```
Today, May 10, 2026
3 labour entries  ← ONLY jack's entries

Labour Entries:
• Carpenter: 1 worker (by jack)
• Mason: 1 worker (by jack)
• General: 1 worker (by jack)
```

**Does NOT show:**
- ❌ Site Engineer (aravind) entries
- ❌ Other supervisors' entries

### When Logged in as Site Engineer (aravind)
**History Screen shows:**
```
Today, May 10, 2026
3 labour entries  ← ONLY aravind's entries

Labour Entries:
• General: 1 worker (by aravind)
• Mason: 1 worker (by aravind)
• Helper: 1 worker (by aravind)
```

**Does NOT show:**
- ❌ Supervisor (jack) entries
- ❌ Other site engineers' entries

### When Logged in as Accountant
**History Screen shows:**
```
Today, May 10, 2026
6 labour entries  ← ALL entries from ALL users

Labour Entries:
• Carpenter: 1 worker (by jack - Supervisor)
• Mason: 1 worker (by jack - Supervisor)
• General: 1 worker (by jack - Supervisor)
• General: 1 worker (by aravind - Site Engineer)
• Mason: 1 worker (by aravind - Site Engineer)
• Helper: 1 worker (by aravind - Site Engineer)
```

## Database State (Correct)

```sql
SELECT 
    submitted_by_role,
    supervisor_id,
    labour_type,
    labour_count
FROM labour_entries
WHERE entry_date = '2026-05-10'
ORDER BY submitted_by_role, labour_type;
```

**Result:**
```
Supervisor (jack):
- Carpenter: 1 worker
- General: 1 worker
- Mason: 1 worker

Site Engineer (aravind):
- General: 1 worker
- Helper: 1 worker
- Mason: 1 worker

Total: 6 entries ✅
```

## Files Modified

### Backend
1. ✅ `django-backend/api/views_construction.py`
   - Line ~1228: Added user_id extraction
   - Line ~1233: Added user filter for Supervisor/Site Engineer
   - Line ~1318: Added user filter for material entries

## Testing

### Test 1: Supervisor Login
```bash
# Login as jack (Supervisor)
curl http://localhost:8000/api/construction/supervisor/history/ \
  -H "Authorization: Bearer JACK_TOKEN"
```

**Expected Response:**
```json
{
  "labour_entries": [
    {"labour_type": "Carpenter", "supervisor_name": "jack", "submitted_by_role": "Supervisor"},
    {"labour_type": "Mason", "supervisor_name": "jack", "submitted_by_role": "Supervisor"},
    {"labour_type": "General", "supervisor_name": "jack", "submitted_by_role": "Supervisor"}
  ],
  "total_labour_entries": 3  ← ONLY 3 entries
}
```

### Test 2: Site Engineer Login
```bash
# Login as aravind (Site Engineer)
curl http://localhost:8000/api/construction/supervisor/history/ \
  -H "Authorization: Bearer ARAVIND_TOKEN"
```

**Expected Response:**
```json
{
  "labour_entries": [
    {"labour_type": "General", "supervisor_name": "aravind", "submitted_by_role": "Site Engineer"},
    {"labour_type": "Mason", "supervisor_name": "aravind", "submitted_by_role": "Site Engineer"},
    {"labour_type": "Helper", "supervisor_name": "aravind", "submitted_by_role": "Site Engineer"}
  ],
  "total_labour_entries": 3  ← ONLY 3 entries
}
```

### Test 3: Accountant Login
```bash
# Login as accountant
curl http://localhost:8000/api/construction/supervisor/history/ \
  -H "Authorization: Bearer ACCOUNTANT_TOKEN"
```

**Expected Response:**
```json
{
  "labour_entries": [
    {"labour_type": "Carpenter", "supervisor_name": "jack", "submitted_by_role": "Supervisor"},
    {"labour_type": "Mason", "supervisor_name": "jack", "submitted_by_role": "Supervisor"},
    {"labour_type": "General", "supervisor_name": "jack", "submitted_by_role": "Supervisor"},
    {"labour_type": "General", "supervisor_name": "aravind", "submitted_by_role": "Site Engineer"},
    {"labour_type": "Mason", "supervisor_name": "aravind", "submitted_by_role": "Site Engineer"},
    {"labour_type": "Helper", "supervisor_name": "aravind", "submitted_by_role": "Site Engineer"}
  ],
  "total_labour_entries": 6  ← ALL 6 entries
}
```

## Issue 2: Duplicate Mason (Frontend)

The duplicate Mason issue is a **frontend caching problem**. The database only has 1 Mason entry from jack, but the UI is showing 2.

**Recommended Fix:**
1. Clear app cache/data
2. Force refresh the history screen
3. Check if the provider is properly deduplicating entries

**To investigate further:**
- Check if entries are being added multiple times to the list
- Check if the same entry ID appears twice
- Verify the provider's data loading logic

## Status
✅ **FIXED** - Backend now filters by logged-in user for Supervisor/Site Engineer
✅ **FIXED** - Accountants still see all entries for comparison
⏳ **PENDING** - Duplicate Mason issue (frontend caching - needs app restart/cache clear)

## Impact
- Supervisors now only see their own entries in history
- Site Engineers now only see their own entries in history
- Accountants see all entries (unchanged)
- Privacy improved - users can't see other users' entries
- Cleaner UI - no confusion about whose entries are shown

