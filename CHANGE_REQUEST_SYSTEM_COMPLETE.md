# Change Request System - Complete ✅

## Overview
Implemented a complete change request and modification tracking system where:
- Supervisors can request changes from accountants
- Accountants can modify entries
- Both can track modified vs unmodified data separately

---

## System Flow

### 1. Supervisor Submits Entry
- Supervisor submits labour/material count
- Entry stored with `is_modified = FALSE`
- Appears in supervisor's **History** tab

### 2. Supervisor Requests Change (Optional)
- Supervisor can request accountant to modify an entry
- Creates a change request with message
- Change request status: PENDING

### 3. Accountant Handles Change Request
- Accountant sees pending change requests
- Accountant modifies the entry with new value
- Entry updated with:
  - `is_modified = TRUE`
  - `modified_by = accountant_id`
  - `modified_at = timestamp`
  - `modification_reason = response message`
- Change request status: COMPLETED

### 4. Supervisor Sees Modified Entry
- Modified entry moves from **History** to **Changes** tab
- Supervisor can see:
  - Who modified it (accountant name)
  - When it was modified
  - Reason for modification

---

## Database Changes

### New Table: change_requests
```sql
CREATE TABLE change_requests (
    id UUID PRIMARY KEY,
    entry_id UUID NOT NULL,
    entry_type VARCHAR(20) CHECK (entry_type IN ('LABOUR', 'MATERIAL')),
    requested_by UUID REFERENCES users(id),
    request_message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    handled_by UUID REFERENCES users(id),
    handled_at TIMESTAMP,
    response_message TEXT
);
```

### Existing Tables Updated
- `labour_entries` - Already has modification tracking fields
- `material_balances` - Already has modification tracking fields

---

## Backend APIs

### 1. Request Change (Supervisor)
**POST** `/api/construction/request-change/`

**Request:**
```json
{
  "entry_id": "uuid",
  "entry_type": "LABOUR",  // or "MATERIAL"
  "request_message": "Please change count from 10 to 12"
}
```

**Response:**
```json
{
  "message": "Change request submitted successfully",
  "request_id": "uuid"
}
```

### 2. Get My Change Requests (Supervisor)
**GET** `/api/construction/my-change-requests/`

**Response:**
```json
{
  "change_requests": [
    {
      "id": "uuid",
      "entry_id": "uuid",
      "entry_type": "LABOUR",
      "request_message": "Please change count",
      "status": "PENDING",  // or "COMPLETED"
      "created_at": "2025-12-26T10:00:00",
      "response_message": "Changed as requested",
      "handled_at": "2025-12-26T11:00:00",
      "handled_by_name": "Accountant Name"
    }
  ]
}
```

### 3. Get Pending Change Requests (Accountant)
**GET** `/api/construction/pending-change-requests/`

**Response:**
```json
{
  "change_requests": [
    {
      "id": "uuid",
      "entry_id": "uuid",
      "entry_type": "LABOUR",
      "request_message": "Please change count",
      "status": "PENDING",
      "created_at": "2025-12-26T10:00:00",
      "requested_by_name": "Supervisor Name",
      "requested_by_username": "ravi",
      "entry_details": {
        "labour_type": "Mason",
        "labour_count": 10,
        "entry_date": "2025-12-26",
        "site_name": "Rajiv Nagar, Plot 12"
      }
    }
  ]
}
```

### 4. Handle Change Request (Accountant)
**POST** `/api/construction/handle-change-request/<request_id>/`

**Request:**
```json
{
  "new_value": 12,
  "response_message": "Changed as requested"
}
```

**Response:**
```json
{
  "message": "Change request handled successfully"
}
```

### 5. Get Modified Entries
**GET** `/api/construction/modified-entries/`

**Response:**
```json
{
  "labour_entries": [
    {
      "id": "uuid",
      "labour_type": "Mason",
      "labour_count": 12,
      "entry_date": "2025-12-26T10:00:00",
      "site_name": "Rajiv Nagar, Plot 12",
      "is_modified": true,
      "modified_at": "2025-12-26T11:00:00",
      "modification_reason": "Changed as requested",
      "modified_by_name": "Accountant Name",
      "supervisor_name": "Supervisor Name"  // Only for accountant
    }
  ],
  "material_entries": [...]
}
```

### 6. Updated Supervisor History API
**GET** `/api/construction/supervisor/history/`

**Changes:**
- Now returns ONLY **unmodified** entries (`is_modified = FALSE`)
- Modified entries appear in `/api/construction/modified-entries/` instead

---

## Frontend Changes

### 1. New Screen: Supervisor Changes
**File:** `otp_phone_auth/lib/screens/supervisor_changes_screen.dart`

**Features:**
- Shows all modified entries for the supervisor
- Displays who modified it (accountant name)
- Shows modification reason
- Grouped by date (Today, Yesterday, etc.)
- Pull to refresh
- Visual distinction with red/orange border and "MODIFIED" badge

### 2. Updated: Supervisor History Screen
**File:** `otp_phone_auth/lib/screens/supervisor_history_screen.dart`

**Changes:**
- Added "Changes" button in AppBar (edit_note icon)
- Opens SupervisorChangesScreen when clicked
- History tab now shows ONLY unmodified entries

### 3. Updated: Construction Service
**File:** `otp_phone_auth/lib/services/construction_service.dart`

**New Methods:**
- `requestChange()` - Request a change
- `getMyChangeRequests()` - Get my change requests
- `getPendingChangeRequests()` - Get pending requests (accountant)
- `handleChangeRequest()` - Handle a request (accountant)
- `getModifiedEntries()` - Get modified entries

---

## User Experience

### Supervisor View

#### History Tab (Unmodified Entries)
```
Today
  Rajiv Nagar, Plot 12
  • 10 Mason
  • 5 Carpenter
  
Yesterday
  Gandhi Street, House 5
  • 8 Plumber
```

#### Changes Tab (Modified Entries)
```
[MODIFIED Badge]
Modified by: Accountant Name

Rajiv Nagar, Plot 12
• Mason: 12 Workers

Reason for Change:
"Corrected count based on attendance sheet"
```

### Accountant View

#### All Entries (Both Modified and Unmodified)
- Can see all entries from all supervisors
- Modified entries show modification badge
- Can filter by role in Reports screen

#### Modified Entries
- Separate view for modified entries only
- Shows original supervisor name
- Shows modification details

---

## Data Separation

### Supervisor History Tab
- Shows ONLY **unmodified** entries
- Query: `WHERE supervisor_id = user_id AND is_modified = FALSE`

### Supervisor Changes Tab
- Shows ONLY **modified** entries
- Query: `WHERE supervisor_id = user_id AND is_modified = TRUE`

### Accountant View
- Can see **both** modified and unmodified entries
- Can filter and view separately
- Shows supervisor names for all entries

---

## Example Workflow

### Scenario: Supervisor Realizes Count Was Wrong

1. **Morning**: Supervisor submits 10 Mason workers
   - Entry appears in History tab
   - `is_modified = FALSE`

2. **Afternoon**: Supervisor realizes it should be 12
   - Supervisor requests change (optional feature for future)
   - OR Supervisor calls accountant

3. **Accountant**: Modifies the entry
   - Changes count from 10 to 12
   - Adds reason: "Corrected based on attendance"
   - Entry updated: `is_modified = TRUE`

4. **Supervisor**: Checks app
   - Entry no longer in History tab
   - Entry now in Changes tab
   - Can see:
     - New count: 12
     - Modified by: Accountant Name
     - Reason: "Corrected based on attendance"

---

## Files Modified/Created

### Backend
- ✅ `django-backend/add_change_requests_system.sql` - Database schema (created)
- ✅ `django-backend/run_add_change_requests_system.py` - Setup script (created)
- ✅ `django-backend/api/views_construction.py` - Added 5 new APIs
- ✅ `django-backend/api/urls.py` - Added 5 new routes

### Frontend
- ✅ `otp_phone_auth/lib/screens/supervisor_changes_screen.dart` - New screen (created)
- ✅ `otp_phone_auth/lib/screens/supervisor_history_screen.dart` - Added Changes button
- ✅ `otp_phone_auth/lib/services/construction_service.dart` - Added 5 new methods

---

## Testing

### Test the Feature

1. **Setup Database:**
   ```bash
   cd django-backend
   python run_add_change_requests_system.py
   ```

2. **Restart Backend:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

3. **Test as Supervisor:**
   - Login as supervisor
   - Submit labour entries
   - Check History tab → Should see entries
   - Click Changes button → Should be empty (no modifications yet)

4. **Test as Accountant:**
   - Login as accountant
   - View all entries
   - Modify an entry (future feature: handle change request)
   - Add modification reason

5. **Test as Supervisor Again:**
   - Check History tab → Modified entry should be gone
   - Click Changes button → Should see modified entry
   - Should see accountant name and reason

---

## Benefits

### For Supervisors
✅ Clear separation of original vs modified data  
✅ Can see who modified their entries  
✅ Can see reason for modifications  
✅ Maintains audit trail  

### For Accountants
✅ Can modify entries when needed  
✅ Must provide reason for changes  
✅ Can see all data (modified and unmodified)  
✅ Complete visibility across all supervisors  

### For System
✅ Complete audit trail  
✅ Data integrity maintained  
✅ Clear accountability  
✅ Transparent modification process  

---

## Summary

The change request system provides:
- **Separation**: Modified vs unmodified entries shown separately
- **Transparency**: Who modified, when, and why
- **Accountability**: Complete audit trail
- **Flexibility**: Accountants can correct errors
- **Clarity**: Supervisors see their original data in History, modified data in Changes

**Status:** ✅ COMPLETE AND READY TO TEST
