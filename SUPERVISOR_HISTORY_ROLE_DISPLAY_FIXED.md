# Supervisor History - Role Display Fixed ✅

## Date: May 9, 2026

## Issue
The supervisor history screen was displaying "Supervisor: aravind" for all entries, even when aravind (Site Engineer) submitted the entries. This caused the Compare Screen to collapse both Supervisor and Site Engineer entries together because it thought they were all from Supervisors.

## Root Cause
1. **Backend API**: The `/construction/supervisor/history/` endpoint was NOT returning the `submitted_by_role` field from the `labour_entries` table
2. **Frontend Display**: The supervisor history screen was hardcoding the label as "Supervisor" instead of using the `submitted_by_role` field

## Database State (Correct)
```
Supervisor (jack): 4 entries
- General: 1 worker
- Carpenter: 1 worker
- Helper: 1 worker
- Mason: 1 worker

Site Engineer (aravind): 3 entries
- General: 1 worker
- Mason: 1 worker
- Helper: 1 worker

Total: 7 entries ✅
```

## Fix Applied

### 1. Backend API (`views_construction.py`)

**Added `submitted_by_role` to SQL query:**
```python
labour_query = f"""
    SELECT
        l.id,
        l.site_id,
        l.labour_type,
        l.labour_count,
        l.entry_date,
        l.entry_time,
        l.notes,
        l.extra_cost,
        l.extra_cost_notes,
        l.submitted_by_role,  ← ADDED THIS
        s.site_name,
        s.customer_name,
        ...
```

**Added `submitted_by_role` to response:**
```python
'labour_entries': [
    {
        'id': str(e['id']),
        'site_id': str(e['site_id']),
        'labour_type': e['labour_type'],
        ...
        'supervisor_name': e['supervisor_name'],
        'user_role': e.get('user_role', ''),
        'submitted_by_role': e.get('submitted_by_role', e.get('user_role', 'Supervisor')),  ← ADDED THIS
        'daily_rate': float(e['daily_rate']) if e.get('daily_rate') else None,
        ...
    }
    for e in labour_entries
],
```

### 2. Frontend Display (`supervisor_history_screen.dart`)

**Changed from hardcoded "Supervisor" to dynamic role:**

**Before:**
```dart
_buildDetailRow(Icons.person, 'Supervisor', entry['supervisor_name'] ?? 'Unknown'),
```

**After:**
```dart
_buildDetailRow(Icons.person, entry['submitted_by_role'] ?? 'Supervisor', entry['supervisor_name'] ?? 'Unknown'),
```

**Applied to both:**
- Labour entry details (line 647)
- Material entry details (line 701)

## Expected Behavior After Fix

### Supervisor History Screen
```
Mason
Workers: 1
Time: 6:20 PM
Site: Anwar 6 22 Ibrahim
Location: Thiruvettakudy, Gandhi Street
Site Engineer: aravind  ← NOW SHOWS CORRECT ROLE
₹1000/day × 1 = ₹1000
```

### Compare Screen
Now shows **2 separate sections**:

**Section 1: Supervisor Entries**
```
Anwar 6 22 Ibrahim
By: jack
At: 11:44 PM

Labour Details:
• Carpenter: 1
• Helper: 1
• Mason: 1
• General: 1
```

**Section 2: Site Engineer Entries**
```
Anwar 6 22 Ibrahim
By: aravind
At: 6:20 PM

Labour Details:
• General: 1
• Mason: 1
• Helper: 1
```

## Files Modified

### Backend
1. ✅ `django-backend/api/views_construction.py`
   - Line ~1242: Added `l.submitted_by_role` to SELECT clause
   - Line ~1356: Added `'submitted_by_role'` to response dictionary

### Frontend
1. ✅ `otp_phone_auth/lib/screens/supervisor_history_screen.dart`
   - Line 647: Changed labour entry display to use `submitted_by_role`
   - Line 701: Changed material entry display to use `submitted_by_role`

## Testing

### Test 1: Check API Response
```bash
curl http://localhost:8000/api/construction/supervisor/history/ \
  -H "Authorization: Bearer TOKEN"
```

**Expected Response:**
```json
{
  "labour_entries": [
    {
      "id": "uuid",
      "labour_type": "Mason",
      "supervisor_name": "aravind",
      "submitted_by_role": "Site Engineer",  ← SHOULD BE PRESENT
      ...
    },
    {
      "id": "uuid",
      "labour_type": "General",
      "supervisor_name": "jack",
      "submitted_by_role": "Supervisor",  ← SHOULD BE PRESENT
      ...
    }
  ]
}
```

### Test 2: Check Frontend Display
1. Login as Supervisor/Site Engineer/Accountant
2. Navigate to History screen
3. Expand an entry
4. **Expected**: Should show "Site Engineer: aravind" for aravind's entries
5. **Expected**: Should show "Supervisor: jack" for jack's entries

### Test 3: Check Compare Screen
1. Login as Accountant
2. Navigate to Compare screen
3. Select May 9, 2026
4. **Expected**: Should show 2 separate sections (Supervisor and Site Engineer)
5. **Expected**: Should NOT collapse entries together

## Status
✅ **FIXED** - Backend now returns `submitted_by_role` field
✅ **FIXED** - Frontend now displays correct role label
✅ **READY** - Compare Screen will now show separate sections for each role

## Impact
- Supervisor history screen now correctly identifies who submitted each entry
- Compare screen will properly separate Supervisor vs Site Engineer entries
- Accountant can now clearly see which role submitted which data
- No more confusion about entry sources

