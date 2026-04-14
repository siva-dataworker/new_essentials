# ✅ Site-Specific Change Requests - COMPLETE

## What Changed

### Problem
- Change request button was on the main history page
- Accountant saw all change requests mixed together
- No way to see which requests belonged to which site

### Solution
- Moved "Request Change" functionality inside site-specific history
- Added "Requests" tab to accountant site detail screen
- Backend now filters change requests by site_id

## Implementation Details

### 1. Supervisor Side

**File:** `otp_phone_auth/lib/screens/supervisor_history_screen.dart`

- Added `showRequestButton` parameter (default: false)
- Request Change button only appears when `showRequestButton = true`
- Main history page: No request buttons (clean view)
- Site-specific history: Request buttons enabled

**File:** `otp_phone_auth/lib/screens/site_detail_screen.dart`

- When opening history from site detail, passes `showRequestButton: true`
- Supervisor can only request changes for entries from that specific site

### 2. Accountant Side

**File:** `otp_phone_auth/lib/screens/accountant_site_detail_screen.dart`

- Added 3rd tab: "Requests" (shows count badge if pending)
- Displays only change requests for that specific site
- Accountant can handle requests directly from site detail
- Same dialog interface for handling requests

### 3. Backend API

**File:** `django-backend/api/views_construction.py`

- Updated `get_pending_change_requests()` endpoint
- Now includes `site_id` in response
- Added optional `site_id` query parameter for filtering
- Returns site information (site_name, area, street) with each request

## User Flow

### Supervisor Flow
```
1. Open site card from dashboard
2. Click History icon (or + → View History)
3. See entries for that site only
4. Click "Request Change" on any entry
5. Enter reason for change
6. Request sent to accountant FOR THAT SITE
```

### Accountant Flow
```
1. Open site card from dashboard
2. See 3 tabs: Labour | Material | Requests
3. "Requests" tab shows badge if pending (e.g., "Requests (2)")
4. Click Requests tab
5. See only change requests for THIS SITE
6. Handle each request:
   - See who requested it
   - See current value
   - Enter new value
   - Add response message
   - Apply change
```

## Benefits

✅ **Site-Specific Context**: Requests are tied to specific sites
✅ **Better Organization**: Accountant sees requests per site, not all mixed
✅ **Cleaner UI**: Main history page is clean (no request buttons)
✅ **Focused Workflow**: Request changes only when viewing site details
✅ **Visual Indicators**: Badge shows pending request count per site
✅ **Easier Management**: Accountant handles requests in context of the site

## API Changes

### Backend Endpoint Updated
```python
GET /api/construction/pending-change-requests/
Optional query param: site_id

Response includes:
- site_id: ID of the site
- entry_details: {
    site_name, area, street, 
    labour_type/material_type, 
    labour_count/quantity
  }
```

## Testing Steps

### 1. Test Supervisor Request Flow
```
1. Login as supervisor
2. Open a site card
3. Click History icon
4. See "Request Change" buttons on entries
5. Click "Request Change"
6. Enter message: "Wrong count, should be 8"
7. Submit request
8. See "Request Pending" badge on that entry
```

### 2. Test Accountant Handling Flow
```
1. Login as accountant
2. Open the SAME site card
3. See "Requests" tab with badge (e.g., "Requests (1)")
4. Click Requests tab
5. See the pending request
6. Click "Handle Request"
7. Enter new value: 8
8. Enter response: "Updated as requested"
9. Click "Apply Change"
10. Request disappears from list
11. Entry is updated in Labour/Material tab
```

### 3. Test Main History (No Buttons)
```
1. Login as supervisor
2. Go to dashboard
3. Click History from bottom nav (if available)
4. See entries WITHOUT "Request Change" buttons
5. This is the clean, read-only view
```

## Files Modified

### Frontend
- `otp_phone_auth/lib/screens/supervisor_history_screen.dart`
- `otp_phone_auth/lib/screens/site_detail_screen.dart`
- `otp_phone_auth/lib/screens/accountant_site_detail_screen.dart`

### Backend
- `django-backend/api/views_construction.py`

## Status

✅ **Supervisor**: Can request changes from site-specific history
✅ **Accountant**: Can see and handle requests per site
✅ **Backend**: Returns site-specific change requests
✅ **UI**: Clean separation between main history and site history
✅ **Badge**: Shows pending request count on Requests tab

## Next Steps

1. **Restart Django Backend**
   ```bash
   cd django-backend
   python manage.py runserver
   ```

2. **Hot Restart Flutter App**
   - Press `R` (capital R) in terminal

3. **Test the Flow**
   - Login as supervisor → Request change from site
   - Login as accountant → Handle request from same site
   - Verify request appears only for that specific site

---

**Ready to test!** Change requests are now site-specific and much easier to manage.
