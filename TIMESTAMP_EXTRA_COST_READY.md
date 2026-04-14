# Timestamp and Extra Cost Feature - Ready to Deploy ✅

## Status: Backend Complete - Ready for Database Migration

All backend changes have been implemented. Now you need to run the database migration.

## What Was Done:

### ✅ Database Migration Scripts Created:
- `django-backend/add_extra_cost_columns.sql` - SQL to add extra_cost columns
- `django-backend/run_add_extra_cost.py` - Python script to run migration

### ✅ Backend API Updated:
1. **submit_labour_count** - Now accepts `extra_cost` and `extra_cost_notes`
2. **submit_material_balance** - Now accepts `extra_cost` and `extra_cost_notes`
3. **get_supervisor_history** - Returns `entry_time`, `updated_at`, `extra_cost`, `extra_cost_notes`
4. **get_all_entries_for_accountant** - Returns timestamps and extra costs

## How to Run Database Migration:

### Step 1: Navigate to Django Backend
```bash
cd django-backend
```

### Step 2: Run Migration Script
```bash
python run_add_extra_cost.py
```

### Expected Output:
```
🔄 Adding extra_cost columns to database...
✅ Extra cost columns added successfully!

Verifying changes...

📊 Labour Entries Columns:
  - entry_time: timestamp without time zone (default: CURRENT_TIMESTAMP)
  - extra_cost: numeric (default: 0)
  - extra_cost_notes: text (default: None)

📦 Material Balances Columns:
  - extra_cost: numeric (default: 0)
  - extra_cost_notes: text (default: None)
  - updated_at: timestamp without time zone (default: CURRENT_TIMESTAMP)

✅ Migration completed successfully!
```

### Step 3: Restart Django Backend
```bash
# Stop current backend (Ctrl+C)
# Then restart
python manage.py runserver
```

## API Changes Summary:

### POST /construction/labour/submit
**New Fields:**
```json
{
  "site_id": "uuid",
  "labour_count": 5,
  "labour_type": "Carpenter",
  "notes": "Morning shift",
  "extra_cost": 500,  // NEW - Optional, defaults to 0
  "extra_cost_notes": "Transport charges"  // NEW - Optional
}
```

**Response:**
```json
{
  "message": "Labour count submitted successfully",
  "entry_id": "uuid",
  "extra_cost": 500  // NEW
}
```

### POST /construction/material/submit
**New Fields:**
```json
{
  "site_id": "uuid",
  "materials": [...],
  "extra_cost": 300,  // NEW - Optional, defaults to 0
  "extra_cost_notes": "Delivery charges"  // NEW - Optional
}
```

### GET /construction/supervisor/history
**New Response Fields:**
```json
{
  "labour_entries": [
    {
      "id": "uuid",
      "labour_type": "Carpenter",
      "labour_count": 5,
      "entry_date": "2024-12-27",
      "entry_time": "2024-12-27T10:30:00",  // NEW - Timestamp
      "extra_cost": 500,  // NEW
      "extra_cost_notes": "Transport charges",  // NEW
      "site_name": "Site A",
      ...
    }
  ],
  "material_entries": [
    {
      "id": "uuid",
      "material_type": "Cement",
      "quantity": 50,
      "entry_date": "2024-12-27",
      "updated_at": "2024-12-27T16:45:00",  // NEW - Timestamp
      "extra_cost": 300,  // NEW
      "extra_cost_notes": "Delivery charges",  // NEW
      ...
    }
  ]
}
```

### GET /construction/accountant/entries
**New Response Fields:**
Same as supervisor history, plus:
```json
{
  "labour_entries": [
    {
      ...
      "entry_time": "2024-12-27T10:30:00",  // NEW
      "extra_cost": 500,  // NEW
      "extra_cost_notes": "Transport charges",  // NEW
      "supervisor_name": "John Doe",
      "user_role": "Supervisor"
    }
  ]
}
```

## Next Steps - Frontend Updates:

### 1. Update Construction Service (construction_service.dart)
Add extra_cost parameters to submission methods

### 2. Update Supervisor UI (site_detail_screen.dart)
Add extra cost input fields to labour and material forms

### 3. Update Accountant UI (accountant_dashboard.dart)
Display timestamps and extra costs in entry cards

## Testing Checklist:

### Database:
- [ ] Run migration script
- [ ] Verify columns added
- [ ] Check default values work

### Backend:
- [ ] Test POST labour with extra_cost
- [ ] Test POST labour without extra_cost (defaults to 0)
- [ ] Test POST material with extra_cost
- [ ] Test GET supervisor history shows timestamps
- [ ] Test GET accountant entries shows timestamps and extra costs

### Frontend (After UI Updates):
- [ ] Supervisor can enter extra cost
- [ ] Extra cost is optional
- [ ] Submission works with/without extra cost
- [ ] Accountant sees timestamps
- [ ] Accountant sees extra costs
- [ ] Extra costs highlighted in orange

## Database Schema Changes:

### labour_entries table:
```sql
extra_cost DECIMAL(10, 2) DEFAULT 0 CHECK (extra_cost >= 0)
extra_cost_notes TEXT
-- entry_time already exists (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
```

### material_balances table:
```sql
extra_cost DECIMAL(10, 2) DEFAULT 0 CHECK (extra_cost >= 0)
extra_cost_notes TEXT
-- updated_at already exists (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
```

## Files Modified:

### Backend:
1. ✅ `django-backend/add_extra_cost_columns.sql` (NEW)
2. ✅ `django-backend/run_add_extra_cost.py` (NEW)
3. ✅ `django-backend/api/views_construction.py` (UPDATED)

### Frontend (TODO):
1. ⏳ `otp_phone_auth/lib/services/construction_service.dart`
2. ⏳ `otp_phone_auth/lib/screens/site_detail_screen.dart`
3. ⏳ `otp_phone_auth/lib/screens/accountant_dashboard.dart`

## Important Notes:

- Timestamps are automatically generated by database (CURRENT_TIMESTAMP)
- Extra cost defaults to 0 if not provided
- Extra cost notes are optional
- All existing data will have extra_cost = 0
- No data loss - only adding new columns
- Backward compatible - old API calls still work

---

**Status**: ✅ Backend Ready - Run Database Migration
**Next**: Run `python run_add_extra_cost.py` in django-backend folder
**Last Updated**: 2024-12-27

Run the database migration now, then I'll update the frontend!
