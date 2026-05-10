# Total Labour Salary Calculation Fixed

## Issue
Dashboard was showing **₹11.05K** total labour salary, but database only had **₹6.65K** worth of entries (using default rates).

## Root Cause
The API query had a `LEFT JOIN` with the `labour_salary_rates` table that was creating **duplicate entries** when multiple custom rates existed for the same labour type.

### Duplicate Entries Found:
- Entry ID `8bbada0e-c71b-4bda-9c7e-e0977cbee87a` (Mason, 2 workers) appeared twice:
  - Once with ₹1000 rate = ₹2000
  - Once with ₹900 rate = ₹1800
- Entry ID `09938ea9-652e-42f4-97a6-60b79e7157cc` (Mason, 1 worker) appeared twice:
  - Once with ₹1000 rate = ₹1000
  - Once with ₹900 rate = ₹900

This caused the API to return **10 entries** instead of **8 unique entries**.

### Why Duplicates Occurred:
The `labour_salary_rates` table had multiple active rates for Mason:
- Mason: ₹900 (Global)
- Mason: ₹1000 (Global)
- Mason: ₹1000 (Site-specific)

When the LEFT JOIN matched multiple rows, it created duplicate entries in the result set.

## Solution
Added `DISTINCT ON (l.id)` to the SQL query to ensure each labour entry appears only once, even when multiple custom rates exist.

### Query Changes:
```sql
-- BEFORE (caused duplicates)
SELECT
    l.id,
    l.site_id,
    ...
FROM labour_entries l
LEFT JOIN labour_salary_rates lsr
    ON lsr.site_id IS NULL
    AND lsr.labour_type = l.labour_type
    AND lsr.is_active = TRUE
ORDER BY l.entry_time DESC

-- AFTER (fixed)
SELECT DISTINCT ON (l.id)
    l.id,
    l.site_id,
    ...
FROM labour_entries l
LEFT JOIN labour_salary_rates lsr
    ON lsr.site_id IS NULL
    AND lsr.labour_type = l.labour_type
    AND lsr.is_active = TRUE
ORDER BY l.id, lsr.created_at DESC, l.entry_time DESC
```

The `ORDER BY l.id, lsr.created_at DESC` ensures that when multiple rates exist, the **most recent rate** is used.

## Results After Fix

### Database (using default rates):
- **8 entries**
- **₹6,650 total salary**

### API (using custom rates from labour_salary_rates):
- **8 entries** (duplicates removed ✓)
- **₹8,050 total salary**

### Difference Explained:
The ₹1,400 difference is because custom rates are higher than defaults:
- Helper: ₹800 (custom) vs ₹500 (default) = +₹300 × 2 workers = +₹600
- Mason: ₹900 (custom) vs ₹800 (default) = +₹100 × 3 workers = +₹300
- Plumber: ₹950 (custom) vs ₹700 (default) = +₹250
- Carpenter: ₹1000 (custom) vs ₹750 (default) = +₹250
- **Total extra: ₹1,400**

## Dashboard Display
The dashboard will now show **₹8.05K** which is correct based on the custom rates configured in the system.

## Files Modified
- `django-backend/api/views_construction.py` - Added `DISTINCT ON (l.id)` to `get_all_entries_for_accountant` function

## Testing
Run these diagnostic scripts to verify:
```bash
cd django-backend
python check_total_labour_salary.py  # Shows ₹6.65K (default rates)
python check_api_detailed.py         # Shows ₹8.05K (custom rates, no duplicates)
```

## Date Fixed
May 9, 2026
