# Cash Entries Feature - Implementation Complete

## Summary
Implemented cash entries feature for accountants to confirm labour entries from supervisors/site engineers or create custom entries.

## Database
- **Table**: `cash_entries`
- **Constraint**: Only ONE entry per site per day (UNIQUE constraint on site_id + entry_date)
- **Source Types**: 'supervisor', 'site_engineer', 'accountant_created'

## Backend APIs Created

### 1. Confirm Cash Entry
- **Endpoint**: `POST /api/construction/confirm-cash-entry/`
- **Purpose**: Confirm a supervisor or site engineer entry
- **Body**:
```json
{
  "site_id": "uuid",
  "entry_date": "2026-05-08",
  "source_type": "supervisor",
  "source_entry_id": "uuid",
  "labour_entries": [
    {"labour_type": "Mason", "labour_count": 2, "daily_rate": 900}
  ]
}
```

### 2. Create Custom Cash Entry
- **Endpoint**: `POST /api/construction/create-custom-cash-entry/`
- **Purpose**: Accountant creates their own entry
- **Body**:
```json
{
  "site_id": "uuid",
  "entry_date": "2026-05-08",
  "labour_entries": [
    {"labour_type": "Carpenter", "labour_count": 3, "daily_rate": 1000}
  ],
  "notes": "Custom entry notes"
}
```

### 3. Check Cash Entry Exists
- **Endpoint**: `GET /api/construction/check-cash-entry/?site_id=xxx&date=YYYY-MM-DD`
- **Purpose**: Check if entry already exists before creating

## Flutter Implementation

### UI Features
1. ✅ Checkbox on each entry card (supervisor & site engineer)
2. ✅ Visual selection feedback (highlighted border)
3. ✅ "Confirm Selection" button at bottom (appears when entry selected)
4. ✅ "+" button in app bar for custom entries
5. ✅ Single selection enforcement (only one entry can be selected)

### Service Methods Added
- `confirmCashEntry()` - Confirm selected entry
- `createCustomCashEntry()` - Create custom entry
- `checkCashEntryExists()` - Check if entry exists

## Next Steps (TODO)

### 1. Complete `_confirmSelection()` method
Update the method in `accountant_compare_screen.dart` to:
- Get labour entries from selected entry
- Get labour rates from backend
- Call `confirmCashEntry()` API
- Show success/error message
- Reload data

### 2. Implement Custom Entry Dialog
Create a full dialog with:
- Site selector dropdown
- Date picker
- Labour type selector (from admin rates)
- Labour count input
- Daily rate display (auto-filled from admin rates)
- Notes field
- Validation
- Call `createCustomCashEntry()` API

### 3. Add Cash Entry Check
Before showing selection UI:
- Call `checkCashEntryExists()` for the selected site and date
- If exists, show message "Cash entry already confirmed for this date"
- Disable selection/creation

### 4. Testing
- Test confirming supervisor entry
- Test confirming site engineer entry
- Test creating custom entry
- Test duplicate prevention (one per site per day)
- Test with multiple labour types

## Files Modified
1. `django-backend/create_cash_entries_table.sql` - Database schema
2. `django-backend/api/views_construction.py` - Backend endpoints
3. `django-backend/api/urls.py` - URL routes
4. `otp_phone_auth/lib/services/construction_service.dart` - Service methods
5. `otp_phone_auth/lib/screens/accountant_compare_screen.dart` - UI implementation

## Usage Flow
1. Accountant opens Compare screen
2. Selects date and site
3. Views supervisor and site engineer entries
4. **Option A**: Selects one entry → Clicks "Confirm Selection"
5. **Option B**: Clicks "+" → Creates custom entry
6. System saves to `cash_entries` table
7. Only ONE entry per site per day allowed
