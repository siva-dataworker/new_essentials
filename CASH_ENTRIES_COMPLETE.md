# Cash Entries System - Complete Implementation

## Overview
The cash entries system allows accountants to confirm supervisor/site engineer labour entries or create custom entries. These confirmed entries are stored in the `cash_entries` table and displayed in the admin budget utilization screen.

## Database Schema

### cash_entries Table
```sql
CREATE TABLE cash_entries (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL REFERENCES sites(id),
    accountant_id UUID NOT NULL REFERENCES users(id),
    entry_date DATE NOT NULL,
    source_type VARCHAR(20) NOT NULL, -- 'supervisor', 'site_engineer', 'accountant_created'
    source_entry_id UUID, -- Reference to original labour_entries.id
    labour_type VARCHAR(100) NOT NULL,
    labour_count INTEGER NOT NULL,
    daily_rate DECIMAL(10, 2) NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    submitted_by_name VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(site_id, entry_date, labour_type) -- One entry per site per date per labour type
);
```

**Key Points:**
- Each labour type gets its own row
- Multiple labour types can exist for the same site and date
- UNIQUE constraint on (site_id, entry_date, labour_type)
- Only ONE set of entries per site per day (accountant can only confirm once)

## Setup Instructions

### 1. Create the Table
```bash
cd essential/essential/construction_flutter/django-backend
python create_cash_entries_table.py
```

This will:
- Create the `cash_entries` table
- Create indexes for performance
- Verify the table structure

### 2. Verify Table Creation
```bash
python show_cash_entries.py
```

## User Flow

### Accountant Compare Screen

1. **Select Date**: Choose the date to compare entries
2. **Filter by Site**: Optionally filter by specific site
3. **View Entries**: See supervisor and site engineer entries side by side
4. **Select Entry**: Click checkbox on one entry (supervisor OR site engineer)
5. **Confirm**: Click "Confirm Selection" button at bottom
6. **OR Create Custom**: Click "+" button to create custom entry

### Confirm Selection Flow
1. Accountant selects an entry (supervisor or site engineer)
2. System fetches labour rates from backend
3. Calculates total cost for each labour type
4. Calls `confirmCashEntry()` API
5. Backend creates rows in `cash_entries` table (one per labour type)
6. Success message shown
7. Data reloaded

### Create Custom Entry Flow
1. Accountant clicks "+" button
2. Dialog opens with form:
   - Site selector (dropdown)
   - Date picker
   - Labour type selector (from admin rates)
   - Labour count input
   - Daily rate (auto-filled from selected labour type)
   - Notes (optional)
3. Validation:
   - All required fields must be filled
   - Count must be positive integer
4. Calls `createCustomCashEntry()` API
5. Backend creates row in `cash_entries` table
6. Success message shown
7. Data reloaded

## Backend APIs

### 1. Confirm Cash Entry
**Endpoint:** `POST /api/construction/confirm-cash-entry/`

**Request Body:**
```json
{
  "site_id": "uuid",
  "entry_date": "2026-05-08",
  "source_type": "supervisor",
  "source_entry_id": "uuid",
  "labour_entries": [
    {
      "labour_type": "Mason",
      "labour_count": 5,
      "daily_rate": 800
    },
    {
      "labour_type": "Helper",
      "labour_count": 3,
      "daily_rate": 500
    }
  ]
}
```

**Response:**
```json
{
  "message": "Cash entry confirmed successfully",
  "entries_count": 2
}
```

### 2. Create Custom Cash Entry
**Endpoint:** `POST /api/construction/create-custom-cash-entry/`

**Request Body:**
```json
{
  "site_id": "uuid",
  "entry_date": "2026-05-08",
  "labour_entries": [
    {
      "labour_type": "Electrician",
      "labour_count": 2,
      "daily_rate": 750
    }
  ],
  "notes": "Custom entry for special work"
}
```

**Response:**
```json
{
  "message": "Custom cash entry created successfully",
  "entries_count": 1
}
```

### 3. Check Cash Entry Exists
**Endpoint:** `GET /api/construction/check-cash-entry/?site_id=xxx&date=2026-05-08`

**Response:**
```json
{
  "exists": true,
  "entry": {
    "id": "uuid",
    "source_type": "supervisor",
    "created_at": "2026-05-08T10:30:00"
  }
}
```

### 4. Get Entries by Date and Role
**Endpoint:** `GET /api/construction/entries-by-date-role/?date=2026-05-08&role=Supervisor`

**Response:**
```json
[
  {
    "site_id": "uuid",
    "site_name": "Customer Name Site Name",
    "submitted_by": "John Doe",
    "submitted_at": "2026-05-08T09:00:00",
    "labour_entries": [
      {
        "labour_type": "Mason",
        "labour_count": 5
      }
    ]
  }
]
```

## Budget Utilization Integration

### Updated Endpoint
The `get_budget_utilization()` endpoint now reads from `cash_entries` table instead of `labour_cost_calculation`:

**Before:**
```python
labour_costs = fetch_all("""
    SELECT labour_type, SUM(total_cost) as total_cost
    FROM labour_cost_calculation
    WHERE site_id = %s
    GROUP BY labour_type
""", (site_id,))
```

**After:**
```python
labour_costs = fetch_all("""
    SELECT labour_type, SUM(total_cost) as total_cost
    FROM cash_entries
    WHERE site_id = %s
    GROUP BY labour_type
""", (site_id,))
```

### Admin Budget Utilization Screen
- Now displays labour costs from `cash_entries` table
- Only shows accountant-confirmed entries
- Reflects actual cash expenditure
- Updates automatically when accountant confirms entries

## Data Flow

```
Supervisor/Engineer → labour_entries table (raw entries)
                              ↓
                    Accountant Compare Screen
                              ↓
                    Accountant selects/creates
                              ↓
                    cash_entries table (confirmed)
                              ↓
                    Admin Budget Utilization Screen
```

## Important Notes

1. **One Entry Per Day**: Only ONE set of entries allowed per site per day
2. **Multiple Labour Types**: Each labour type gets its own row in cash_entries
3. **Unique Constraint**: (site_id, entry_date, labour_type) must be unique
4. **Source Tracking**: System tracks whether entry came from supervisor, engineer, or accountant
5. **Rate Calculation**: Daily rates fetched from admin labour rates (global)
6. **Total Cost**: Automatically calculated as labour_count × daily_rate

## Testing

### 1. Test Confirm Entry
1. Login as Supervisor
2. Submit labour entries for today
3. Login as Accountant
4. Go to Compare tab
5. Select today's date
6. Select supervisor entry
7. Click Confirm
8. Verify success message
9. Login as Admin
10. Check Budget Utilization screen
11. Verify labour costs appear

### 2. Test Custom Entry
1. Login as Accountant
2. Go to Compare tab
3. Click "+" button
4. Fill form:
   - Select site
   - Select date
   - Select labour type
   - Enter count
   - Add notes
5. Click Create
6. Verify success message
7. Login as Admin
8. Check Budget Utilization screen
9. Verify custom entry appears

### 3. Test Duplicate Prevention
1. Confirm an entry for a site and date
2. Try to confirm another entry for same site and date
3. Should show error: "Cash entry already exists"

## Files Modified

### Flutter (Frontend)
- `otp_phone_auth/lib/screens/accountant_compare_screen.dart`
  - Implemented `_confirmSelection()` method
  - Implemented `_showCreateCustomEntryDialog()` method
  - Added selection UI with checkboxes
  - Added confirm button at bottom
  - Added "+" button for custom entries

- `otp_phone_auth/lib/services/construction_service.dart`
  - Added `confirmCashEntry()` method
  - Added `createCustomCashEntry()` method
  - Added `checkCashEntryExists()` method
  - Added `getLabourRates()` method

### Backend (Django)
- `django-backend/api/views_construction.py`
  - Added `confirm_cash_entry()` endpoint
  - Added `create_custom_cash_entry()` endpoint
  - Added `check_cash_entry_exists()` endpoint
  - Fixed `get_entries_by_date_and_role()` query

- `django-backend/api/views_budget_management.py`
  - Updated `get_budget_utilization()` to read from cash_entries
  - Updated `get_labour_cost_details()` to read from cash_entries

- `django-backend/api/urls.py`
  - Added routes for cash entry endpoints

### Database
- `django-backend/create_cash_entries_table.sql`
  - Table schema with UNIQUE constraint
  - Indexes for performance

- `django-backend/create_cash_entries_table.py`
  - Python script to create table

## Troubleshooting

### No entries showing in Compare screen
- Check backend logs for SQL errors
- Verify `get_entries_by_date_and_role()` is returning data
- Check that `submitted_by_role` column exists in labour_entries table

### Cannot confirm entry
- Check if cash entry already exists for that site and date
- Verify accountant is logged in
- Check backend logs for errors

### Budget utilization not showing labour costs
- Verify cash_entries table has data
- Check that `get_budget_utilization()` is reading from cash_entries
- Verify site_id matches between tables

### Duplicate entry error
- This is expected - only one entry per site per day allowed
- Delete existing entry from cash_entries table if needed
- Or choose a different date

## Next Steps

1. ✅ Create cash_entries table
2. ✅ Implement confirm selection
3. ✅ Implement custom entry creation
4. ✅ Update budget utilization endpoint
5. ⏳ Test complete flow
6. ⏳ Deploy to production

## Status: COMPLETE ✅

All implementation is complete. Ready for testing.
