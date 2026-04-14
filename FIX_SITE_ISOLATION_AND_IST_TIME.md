# 🔧 Fix: Site Isolation & IST Time Issues

## 🐛 Problems Identified

### Problem 1: IST Time Showing Wrong (6:18 AM instead of 11:54 AM)
**Root Cause**: Database storing UTC time (06:18) instead of IST time (11:48)
- Time difference: 5 hours 30 minutes (IST = UTC + 5:30)
- When you submitted at 11:48 AM IST, it stored as 06:18 AM UTC

### Problem 2: Supervisor Seeing All Sites' Data
**Root Cause**: Frontend not passing `site_id` parameter to history endpoint
- Backend correctly filters by site_id when provided
- Frontend needs to pass the selected site_id

---

## ✅ Fixes Applied

### Fix 1: IST Time Storage (BACKEND)

**File**: `django-backend/api/time_utils.py`

**Changed**:
```python
def get_ist_now():
    """Get current time in IST timezone - timezone aware"""
    from django.utils import timezone
    # Get current UTC time and convert to IST
    utc_now = timezone.now()
    return utc_now.astimezone(IST)
```

**What this does**:
- Gets Django's timezone-aware UTC time
- Converts to IST properly
- Ensures database stores correct IST timestamps

---

## 🧪 Test the Fix

### 1. Restart Backend
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### 2. Test IST Time
```bash
curl http://localhost:8000/api/construction/current-ist-time/
```

**Expected Output**:
```json
{
  "current_time_ist": "2026-01-27 11:59:00 IST",
  "day_of_week": "Tuesday",
  "current_hour": 11
}
```

### 3. Submit a Test Entry (Between 8 AM - 1 PM)
```bash
curl -X POST http://localhost:8000/api/construction/labour/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "site_id": "YOUR_SITE_ID",
    "labour_count": 5,
    "labour_type": "Test"
  }'
```

**Check the response** - it should show correct IST time in `entry_date` and `day_of_week`.

### 4. Verify Time in Database
```bash
cd django-backend
python fix_site_isolation_and_time.py
```

Look for the "TIME STORAGE VERIFICATION" section - times should now show correct IST hours (not 6:18 AM).

---

## 🔧 Fix 2: Site Isolation (FRONTEND NEEDED)

### Problem
Supervisor is seeing entries from all sites instead of just the selected site.

### Backend Status
✅ Backend is **already correct** - it filters by site_id when provided:
- Endpoint: `GET /api/construction/supervisor/history/?site_id=xxx`
- If `site_id` is provided, only returns entries for that site
- If `site_id` is NOT provided, returns all supervisor's entries

### Frontend Fix Needed

**File**: `otp_phone_auth/lib/screens/supervisor_history_screen.dart`

**Current Issue**: Probably calling history without site_id parameter

**Fix**: Ensure the history API call includes the selected site_id:

```dart
// WRONG - Shows all sites
final response = await http.get(
  Uri.parse('$baseUrl/construction/supervisor/history/'),
  headers: headers,
);

// CORRECT - Shows only selected site
final response = await http.get(
  Uri.parse('$baseUrl/construction/supervisor/history/?site_id=$selectedSiteId'),
  headers: headers,
);
```

---

## 📋 Verification Checklist

### Backend (IST Time Fix)
- [x] Updated `time_utils.py` to use Django timezone
- [ ] Restart backend
- [ ] Test `/api/construction/current-ist-time/` endpoint
- [ ] Submit new entry and verify time is correct
- [ ] Check database shows IST time (not UTC)

### Frontend (Site Isolation Fix)
- [ ] Find where history API is called
- [ ] Add `site_id` parameter to the API call
- [ ] Test: Select Site A, should only see Site A entries
- [ ] Test: Select Site B, should only see Site B entries
- [ ] Test: Switch between sites, data should update

---

## 🔍 How to Debug

### Check What Site ID is Being Sent

Add logging in Flutter:
```dart
print('Fetching history for site_id: $selectedSiteId');
final response = await http.get(
  Uri.parse('$baseUrl/construction/supervisor/history/?site_id=$selectedSiteId'),
  headers: headers,
);
print('Response: ${response.body}');
```

### Check Backend Logs

When you call the history endpoint, backend logs will show:
```
GET /api/construction/supervisor/history/?site_id=xxx
```

If you don't see `?site_id=xxx`, then Flutter is not sending it.

### Test Backend Directly

```bash
# Get all entries (no site filter)
curl "http://localhost:8000/api/construction/supervisor/history/" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get only Site A entries
curl "http://localhost:8000/api/construction/supervisor/history/?site_id=SITE_A_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get only Site B entries
curl "http://localhost:8000/api/construction/supervisor/history/?site_id=SITE_B_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Compare the results - they should be different.

---

## 📊 Current Database Status

From verification script:

**Supervisor "shhsjs" has entries in 4 sites**:
1. Site: 1 18 Sasikumar (Kasakudy, Saudha Garden) - 2 labour entries
2. Site: 2 20 Abdul (Kasakudy, Saudha Garden) - 9 labour entries, 4 material entries
3. Site: 6 22 Ibrahim (Thiruvettakudy, Gandhi Street) - 7 labour entries
4. Site: 7 20 Murugan (Thiruvettakudy, Gandhi Street) - 1 labour entry

**This is CORRECT** - a supervisor can work on multiple sites.

**The issue is**: When supervisor selects "Site 1", they should only see the 2 entries for Site 1, not all 19 entries.

---

## 🎯 Solution Summary

### IST Time Issue
**Status**: ✅ Fixed in backend
**Action**: Restart backend and test

### Site Isolation Issue
**Status**: ⏳ Needs Flutter fix
**Action**: Update Flutter to pass `site_id` parameter

---

## 🚀 Quick Fix Steps

### Step 1: Fix Backend Time (NOW)
```bash
# Backend is already updated, just restart
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### Step 2: Test Backend Time
```bash
# Should show correct IST time (around 12:00 PM, not 6:30 AM)
curl http://localhost:8000/api/construction/current-ist-time/
```

### Step 3: Find Flutter History Call
Search in `otp_phone_auth/lib/screens/supervisor_history_screen.dart` for:
- `construction/supervisor/history`
- Or wherever the history API is called

### Step 4: Add site_id Parameter
Change from:
```dart
'/construction/supervisor/history/'
```

To:
```dart
'/construction/supervisor/history/?site_id=$selectedSiteId'
```

### Step 5: Hot Restart Flutter
```bash
# In your Flutter terminal
r  # Hot restart
```

### Step 6: Test
1. Login as supervisor
2. Select Site A
3. View history - should only show Site A entries
4. Select Site B
5. View history - should only show Site B entries

---

## 📞 Need Help?

### If Time Still Wrong
1. Check system clock: `date` (Linux/Mac) or `time` (Windows)
2. Check Django settings: `TIME_ZONE = 'Asia/Kolkata'`
3. Check database timezone settings
4. Run: `python fix_site_isolation_and_time.py` to see actual stored times

### If Site Isolation Still Not Working
1. Check Flutter logs for the API URL being called
2. Check backend logs to see what parameters are received
3. Test backend directly with curl (see debug section above)
4. Verify `selectedSiteId` variable has correct value in Flutter

---

**Status**: 
- ✅ Backend IST time fix applied
- ⏳ Backend restart needed
- ⏳ Flutter site_id parameter needed

**Last Updated**: January 27, 2026, 12:00 PM IST
