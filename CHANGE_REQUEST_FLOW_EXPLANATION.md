# Change Request System - Complete Flow Explanation

## Overview
The Change Request system allows Supervisors (and Site Engineers) to request modifications to their submitted labour/material entries. Accountants review and approve these requests, making the actual changes to the data.

---

## System Architecture

### Database Tables

#### 1. `change_requests` Table
```sql
CREATE TABLE change_requests (
    id UUID PRIMARY KEY,
    entry_id UUID NOT NULL,              -- ID of labour_entries or material_balances
    entry_type VARCHAR(20) NOT NULL,     -- 'LABOUR' or 'MATERIAL'
    requested_by UUID NOT NULL,          -- User ID of supervisor/site engineer
    request_note TEXT,                   -- Reason for change request
    status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'COMPLETED', 'REJECTED'
    reviewed_by UUID,                    -- User ID of accountant who handled it
    reviewed_at TIMESTAMP,               -- When accountant handled it
    accountant_notes TEXT,               -- Accountant's response/notes
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### 2. Modified Entry Tracking
Both `labour_entries` and `material_balances` tables have:
```sql
is_modified BOOLEAN DEFAULT FALSE,
modified_by UUID,                        -- Accountant who modified
modified_at TIMESTAMP,
modification_reason TEXT
```

---

## Complete Flow

### STEP 1: Supervisor Submits Entry
1. Supervisor/Site Engineer submits labour or material entry
2. Entry is stored in `labour_entries` or `material_balances` table
3. Entry appears in their history with `is_modified = FALSE`

### STEP 2: Supervisor Requests Change
**When:** Supervisor realizes they made a mistake in the submitted data

**Frontend (Flutter):**
- Supervisor views their history in `SupervisorHistoryScreen`
- Clicks "Request Change" button on an entry
- Dialog appears asking for:
  - Reason for change request
  - Optionally, proposed new value
- Calls `ConstructionService.requestChange()`

**Backend API:**
```
POST /api/construction/request-change/
```

**Request Body:**
```json
{
  "entry_id": "uuid-of-entry",
  "entry_type": "LABOUR",  // or "MATERIAL"
  "request_message": "Entered wrong count, should be 5 not 3"
}
```

**Backend Logic (`views_construction.py`):**
```python
def request_change(request):
    # 1. Extract data from request
    entry_id = request.data.get('entry_id')
    entry_type = request.data.get('entry_type')
    request_message = request.data.get('request_message')
    user_id = request.user['user_id']
    
    # 2. Create change request record
    change_request_id = str(uuid.uuid4())
    execute_query("""
        INSERT INTO change_requests 
        (id, entry_id, entry_type, requested_by, request_note, status)
        VALUES (%s, %s, %s, %s, %s, 'PENDING')
    """, (change_request_id, entry_id, entry_type, user_id, request_message))
    
    # 3. Return success
    return Response({'request_id': change_request_id})
```

**Result:**
- New record created in `change_requests` table with `status = 'PENDING'`
- Entry in supervisor's history shows "Pending Request" badge
- Supervisor can view their requests in "Requests" tab

### STEP 3: Supervisor Views Their Requests
**Frontend:**
- Supervisor navigates to "Requests" tab in their history
- Calls `ChangeRequestProvider.loadMyChangeRequests()`

**Backend API:**
```
GET /api/construction/my-change-requests/
```

**Backend Logic:**
```python
def get_my_change_requests(request):
    user_id = request.user['user_id']
    
    # Get all change requests by this supervisor
    requests_data = fetch_all("""
        SELECT 
            cr.id, cr.entry_id, cr.entry_type,
            cr.request_note, cr.status, cr.created_at,
            cr.accountant_notes, cr.reviewed_at,
            u.full_name as handled_by_name
        FROM change_requests cr
        LEFT JOIN users u ON cr.reviewed_by = u.id
        WHERE cr.requested_by = %s
        ORDER BY cr.created_at DESC
    """, (user_id,))
    
    return Response({'change_requests': requests_data})
```

**Display:**
- Shows all requests (PENDING, COMPLETED, REJECTED)
- For each request:
  - Entry details (labour type, count, date)
  - Request message
  - Status badge (Pending/Completed/Rejected)
  - Accountant's response (if handled)
  - Handled by and when

### STEP 4: Accountant Views Pending Requests
**Frontend:**
- Accountant opens their dashboard
- Sees "Change Requests" tab or notification badge
- Calls `ChangeRequestProvider.loadPendingChangeRequests()`

**Backend API:**
```
GET /api/construction/pending-change-requests/
Optional: ?site_id=uuid (filter by site)
```

**Backend Logic:**
```python
def get_pending_change_requests(request):
    site_id = request.query_params.get('site_id')
    
    # Get all pending requests
    requests_data = fetch_all("""
        SELECT 
            cr.id, cr.entry_id, cr.entry_type,
            cr.request_note, cr.status, cr.created_at,
            u.full_name as requested_by_name,
            u.username as requested_by_username,
            r.role_name as requested_by_role
        FROM change_requests cr
        JOIN users u ON cr.requested_by = u.id
        JOIN roles r ON u.role_id = r.id
        WHERE cr.status = 'PENDING'
        ORDER BY cr.created_at DESC
    """)
    
    # For each request, get entry details
    result = []
    for req in requests_data:
        if req['entry_type'] == 'LABOUR':
            entry_details = fetch_one("""
                SELECT l.labour_type, l.labour_count, l.entry_date,
                       l.site_id, s.site_name, s.area, s.street
                FROM labour_entries l
                JOIN sites s ON l.site_id = s.id
                WHERE l.id = %s
            """, (req['entry_id'],))
        else:  # MATERIAL
            entry_details = fetch_one("""
                SELECT m.material_type, m.quantity, m.unit,
                       m.entry_date, m.site_id, s.site_name
                FROM material_balances m
                JOIN sites s ON m.site_id = s.id
                WHERE m.id = %s
            """, (req['entry_id'],))
        
        # Filter by site if provided
        if site_id and entry_details['site_id'] != site_id:
            continue
        
        result.append({
            'id': req['id'],
            'entry_id': req['entry_id'],
            'entry_type': req['entry_type'],
            'request_message': req['request_note'],
            'requested_by_name': req['requested_by_name'],
            'requested_by_role': req['requested_by_role'],
            'site_id': entry_details['site_id'],
            'entry_details': entry_details
        })
    
    return Response({'change_requests': result})
```

**Display:**
- List of all pending change requests
- For each request shows:
  - Who requested (supervisor name, role)
  - Which site
  - Entry details (current values)
  - Request message (reason)
  - "Handle Request" button

### STEP 5: Accountant Handles Request
**Frontend:**
- Accountant clicks "Handle Request" on a pending request
- Dialog appears with:
  - Current value (read-only)
  - New value input field
  - Response message field
  - "Approve & Update" button
- Calls `ChangeRequestProvider.handleChangeRequest()`

**Backend API:**
```
POST /api/construction/handle-change-request/<request_id>/
```

**Request Body:**
```json
{
  "new_value": 5,
  "response_message": "Updated count from 3 to 5 as requested"
}
```

**Backend Logic:**
```python
def handle_change_request(request, request_id):
    user_id = request.user['user_id']
    new_value = request.data.get('new_value')
    response_message = request.data.get('response_message', '')
    
    # 1. Get change request details
    change_req = fetch_one("""
        SELECT entry_id, entry_type 
        FROM change_requests 
        WHERE id = %s
    """, (request_id,))
    
    # 2. Update the actual entry
    if change_req['entry_type'] == 'LABOUR':
        execute_query("""
            UPDATE labour_entries 
            SET labour_count = %s,
                is_modified = TRUE,
                modified_by = %s,
                modified_at = NOW(),
                modification_reason = %s
            WHERE id = %s
        """, (new_value, user_id, response_message, change_req['entry_id']))
    else:  # MATERIAL
        execute_query("""
            UPDATE material_balances 
            SET quantity = %s,
                is_modified = TRUE,
                modified_by = %s,
                modified_at = NOW(),
                modification_reason = %s
            WHERE id = %s
        """, (new_value, user_id, response_message, change_req['entry_id']))
    
    # 3. Update change request status
    execute_query("""
        UPDATE change_requests 
        SET status = 'COMPLETED',
            reviewed_by = %s,
            reviewed_at = NOW(),
            accountant_notes = %s
        WHERE id = %s
    """, (user_id, response_message, request_id))
    
    return Response({'message': 'Change request handled successfully'})
```

**Result:**
- Entry in `labour_entries`/`material_balances` is updated with new value
- Entry marked as `is_modified = TRUE`
- Change request status changed to `COMPLETED`
- Accountant details and notes recorded

### STEP 6: Supervisor Sees Updated Entry
**Frontend:**
- Supervisor refreshes their history
- Entry now shows:
  - Updated value (new count/quantity)
  - "Modified" badge
  - Modified by accountant name
  - Modification reason
- In "Requests" tab:
  - Request status changed to "Completed"
  - Shows accountant's response message
  - Shows who handled it and when

---

## Key Features

### 1. Entry Visibility Control
- **Unmodified entries:** Shown in supervisor history and accountant views
- **Modified entries:** Marked with badge, shows modification details
- **Filter option:** Can filter to show only modified or unmodified entries

### 2. Request Status Tracking
- **PENDING:** Waiting for accountant review
- **COMPLETED:** Accountant approved and updated
- **REJECTED:** Accountant rejected (optional, not fully implemented)

### 3. Audit Trail
Every modification is tracked:
- Who requested the change
- Why they requested it
- Who approved it
- When it was approved
- What the new value is
- Accountant's notes

### 4. UI Indicators
- **Pending badge:** Yellow badge on entries with pending requests
- **Modified badge:** Blue badge on entries that have been modified
- **Request count:** Shows number of pending requests in tabs
- **Disabled button:** Can't request change if already pending

---

## Data Flow Diagram

```
┌─────────────┐
│ Supervisor  │
│  Submits    │
│   Entry     │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  labour_entries /   │
│  material_balances  │
│  is_modified=FALSE  │
└──────┬──────────────┘
       │
       │ (Realizes mistake)
       ▼
┌─────────────────────┐
│   Supervisor        │
│ Requests Change     │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  change_requests    │
│   status=PENDING    │
└──────┬──────────────┘
       │
       │ (Notification)
       ▼
┌─────────────────────┐
│   Accountant        │
│  Views Requests     │
└──────┬──────────────┘
       │
       │ (Reviews & Approves)
       ▼
┌─────────────────────┐
│  Accountant         │
│ Handles Request     │
└──────┬──────────────┘
       │
       ├──────────────────────┐
       │                      │
       ▼                      ▼
┌─────────────────┐   ┌──────────────────┐
│ Update Entry    │   │ Update Request   │
│ is_modified=TRUE│   │ status=COMPLETED │
│ new value       │   │ accountant_notes │
└─────────────────┘   └──────────────────┘
       │
       │ (Refresh)
       ▼
┌─────────────────────┐
│   Supervisor        │
│ Sees Updated Entry  │
│  & Completed Req    │
└─────────────────────┘
```

---

## API Endpoints Summary

| Endpoint | Method | Role | Purpose |
|----------|--------|------|---------|
| `/api/construction/request-change/` | POST | Supervisor/Site Engineer | Submit change request |
| `/api/construction/my-change-requests/` | GET | Supervisor/Site Engineer | View own requests |
| `/api/construction/pending-change-requests/` | GET | Accountant | View all pending requests |
| `/api/construction/handle-change-request/<id>/` | POST | Accountant | Approve and update entry |
| `/api/construction/modified-entries/` | GET | Both | View modified entries |

---

## Frontend Components

### Supervisor Side
1. **SupervisorHistoryScreen** - Shows entries with "Request Change" button
2. **ChangeRequestProvider** - Manages state for requests
3. **Request Change Dialog** - Input form for request message
4. **Requests Tab** - Shows all submitted requests and their status

### Accountant Side
1. **AccountantChangeRequestsScreen** - Dedicated screen for all requests
2. **AccountantSiteDetailScreen** - Shows requests per site in "Requests" tab
3. **Handle Request Dialog** - Input form for new value and response
4. **ChangeRequestProvider** - Manages state for pending requests

---

## Benefits

1. **Accountability:** Full audit trail of all changes
2. **Control:** Accountant reviews before any data is modified
3. **Transparency:** Supervisor sees who modified and why
4. **Flexibility:** Can request changes without direct edit access
5. **Data Integrity:** Prevents unauthorized modifications
6. **Communication:** Request/response messages provide context

---

## Example Scenario

**Scenario:** Supervisor entered 3 masons but actually had 5

1. **Day 1, 10:00 AM:** Supervisor submits labour entry: 3 Masons
2. **Day 1, 2:00 PM:** Supervisor realizes mistake
3. **Day 1, 2:05 PM:** Supervisor clicks "Request Change"
   - Message: "Entered wrong count, we had 5 masons not 3"
4. **Day 1, 3:00 PM:** Accountant sees pending request
5. **Day 1, 3:10 PM:** Accountant reviews:
   - Sees current value: 3
   - Enters new value: 5
   - Response: "Updated count from 3 to 5 as requested"
   - Clicks "Approve & Update"
6. **Day 1, 3:11 PM:** System updates:
   - Labour entry: count = 5, is_modified = TRUE
   - Change request: status = COMPLETED
7. **Day 1, 4:00 PM:** Supervisor refreshes history
   - Sees updated count: 5 Masons
   - Sees "Modified" badge
   - Sees modification reason
   - In Requests tab: Status = Completed

---

## Technical Notes

### Caching Strategy
- Requests are cached in `ChangeRequestProvider`
- Cache invalidated on:
  - New request submission
  - Request handling
  - Manual refresh
  - Force refresh flag

### Performance Optimization
- Pending requests loaded once per session
- Site-specific filtering on backend
- Lazy loading of entry details
- Provider pattern prevents redundant API calls

### Error Handling
- Validates required fields before submission
- Checks if entry exists before creating request
- Prevents duplicate requests for same entry
- Shows user-friendly error messages

---

## Future Enhancements (Potential)

1. **Rejection Flow:** Allow accountant to reject requests with reason
2. **Bulk Handling:** Handle multiple requests at once
3. **Notifications:** Push notifications for new requests/responses
4. **Request History:** View all historical requests (not just pending)
5. **Approval Workflow:** Multi-level approval for large changes
6. **Auto-approval:** Auto-approve small changes within threshold
7. **Request Expiry:** Auto-expire old pending requests
8. **Comments:** Allow back-and-forth discussion on requests
