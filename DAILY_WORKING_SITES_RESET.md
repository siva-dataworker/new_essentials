# Daily Working Sites Reset Feature

## Overview
Implemented automatic daily reset of working sites at 6 AM IST for accountants.

## How It Works

### Daily Reset Logic
1. **6 AM Daily Reset**: Every day at 6 AM IST, all working sites are automatically reset (set to inactive)
2. **Accountant Selection**: Accountant can select working sites anytime during the day
3. **Next Day Reset**: The next day at 6 AM, sites automatically reset again to 0

### Implementation Details

#### Database Changes
- Added `last_reset_date` column to `working_sites` table
- Tracks when sites were last reset
- Indexed for efficient querying

#### API Changes
- Modified `POST /api/construction/assign-working-sites/` endpoint
- Automatically checks if reset is needed before assigning sites
- Resets all sites if last reset was before today

### Reset Trigger
The reset happens automatically when:
1. Accountant tries to assign working sites
2. The `last_reset_date` is before today's date
3. System deactivates all working sites (`is_active = FALSE`)
4. Updates `last_reset_date` to today

### API Response
When assigning sites, the response includes:
```json
{
  "message": "X site(s) assigned to Y supervisor(s) successfully",
  "assigned_count": 10,
  "sites_count": 5,
  "supervisors_count": 2,
  "reset_performed": true,
  "assignment_date": "2026-04-07"
}
```

## Files Modified

### Backend
1. **api/views_construction.py**
   - Updated `assign_working_sites()` function
   - Added daily reset logic
   - Added timezone handling for IST

2. **Database Migration**
   - `add_daily_reset_to_working_sites.sql` - SQL migration
   - `apply_daily_reset_migration.py` - Python script to apply migration

### Database Schema
```sql
ALTER TABLE working_sites 
ADD COLUMN last_reset_date DATE DEFAULT CURRENT_DATE;
```

## Usage

### For Accountants
1. Open the app anytime during the day
2. Select working sites for supervisors
3. Sites are assigned and active for the day
4. Next day at 6 AM, sites automatically reset to 0
5. Accountant selects sites again for the new day

### Automatic Reset
- No manual intervention needed
- Reset happens automatically when accountant first accesses the system after 6 AM
- All supervisors' working sites are cleared
- Accountant can then select new sites for the day

## Benefits
1. **Daily Fresh Start**: Each day starts with a clean slate
2. **No Manual Reset**: Automatic reset eliminates manual work
3. **Consistent Process**: Same workflow every day
4. **Audit Trail**: `last_reset_date` tracks when reset occurred

## Testing
1. Assign working sites as accountant
2. Check that sites are active
3. Wait until next day (or change system date for testing)
4. Assign sites again
5. Verify that previous sites were reset before new assignment

## Notes
- Reset time is fixed at 6 AM IST
- Reset happens on first API call after 6 AM
- All supervisors' sites are reset together
- Previous day's assignments are preserved in database (just marked inactive)
