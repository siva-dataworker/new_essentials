# Budget Utilization Fix - Reading from cash_entries

## 🔍 Problem Identified

The budget utilization is showing **₹8.05K** total but only **₹950** in labour breakdown because:

1. ✅ The `get_budget_utilization()` API endpoint reads from `cash_entries` (CORRECT)
2. ❌ The `budget_utilization_summary` VIEW still reads from `labour_cost_calculation` (WRONG)

## 📊 Current Situation

### What's Happening:
```
budget_utilization_summary VIEW
  ↓
Reads from: labour_cost_calculation (OLD DATA - ₹8,050)
  ↓
Shows in: Total Spent card

get_budget_utilization() API
  ↓
Reads from: cash_entries (NEW DATA - ₹950)
  ↓
Shows in: Labour Breakdown section
```

### Result:
- **Total Spent**: ₹8.05K (from VIEW reading labour_cost_calculation)
- **Labour Breakdown**: ₹950 (from API reading cash_entries)
- **Mismatch!** ❌

## ✅ Solution

Update the `budget_utilization_summary` VIEW to read from `cash_entries` table instead of `labour_cost_calculation`.

### Step 1: Run the Update Script

```bash
cd essential/essential/construction_flutter/django-backend
python update_budget_view.py
```

This will:
1. Drop the old view
2. Create new view reading from `cash_entries`
3. Verify the update

### Step 2: Restart Django Backend

```bash
# Stop Django (Ctrl+C)
# Start again
python manage.py runserver
```

### Step 3: Refresh App

- Hot restart Flutter app (press `R` in terminal)
- Or restart the app completely
- Navigate to Budget Utilization screen
- Pull to refresh

## 📋 What Will Change

### Before Update:
```sql
-- budget_utilization_summary VIEW
LEFT JOIN labour_cost_calculation lcc ON sba.site_id = lcc.site_id
-- Shows ALL labour entries (supervisor + engineer)
```

### After Update:
```sql
-- budget_utilization_summary VIEW  
LEFT JOIN cash_entries ce ON sba.site_id = ce.site_id
-- Shows ONLY accountant-confirmed entries
```

## ✅ Expected Result

After the update, Budget Utilization will show:

```
Total Spent: ₹950
  ↓
Material: ₹0
Labour: ₹950
  ↓
Labour Breakdown:
  - Plumber: 1 × ₹950 = ₹950
```

**Everything will match!** ✅

## 🔍 How to Verify

### Check 1: View Definition
```sql
SELECT definition 
FROM pg_views 
WHERE viewname = 'budget_utilization_summary';
```

Should contain: `cash_entries ce` (not `labour_cost_calculation lcc`)

### Check 2: Query the View
```sql
SELECT 
    site_name,
    total_labour_cost,
    total_spent
FROM budget_utilization_summary
WHERE site_id = 'your-site-id';
```

Should show labour cost from cash_entries only.

### Check 3: Compare Tables
```sql
-- Old table (should have more data)
SELECT SUM(total_cost) FROM labour_cost_calculation WHERE site_id = 'your-site-id';

-- New table (should have less data - only confirmed)
SELECT SUM(total_cost) FROM cash_entries WHERE site_id = 'your-site-id';

-- View should match cash_entries
SELECT total_labour_cost FROM budget_utilization_summary WHERE site_id = 'your-site-id';
```

## 📊 Data Flow After Fix

```
Supervisor submits → labour_entries table
Site Engineer submits → labour_entries table
         ↓
Accountant Compare Screen
         ↓
Accountant selects Supervisor entry
         ↓
Saved to cash_entries table
         ↓
budget_utilization_summary VIEW reads from cash_entries
         ↓
Admin Budget Utilization shows correct data
```

## 🎯 Why This Matters

### Before Fix:
- **Total Spent**: Includes ALL labour entries (supervisor + engineer + duplicates)
- **Labour Breakdown**: Shows only accountant-confirmed entries
- **Result**: Numbers don't match ❌

### After Fix:
- **Total Spent**: Includes ONLY accountant-confirmed entries
- **Labour Breakdown**: Shows ONLY accountant-confirmed entries
- **Result**: Numbers match perfectly ✅

## 🔄 Migration Path

If you have existing data in `labour_cost_calculation`:

### Option 1: Keep Old Data (Recommended)
- Update the view (as described above)
- Old data in `labour_cost_calculation` is preserved
- New data goes to `cash_entries`
- Budget utilization shows only confirmed entries going forward

### Option 2: Migrate Old Data
- Copy existing `labour_cost_calculation` data to `cash_entries`
- Mark as `source_type = 'migrated'`
- Update the view
- All historical data appears in budget utilization

## 📝 Files Created

1. ✅ `update_budget_view_for_cash_entries.sql` - SQL to update view
2. ✅ `update_budget_view.py` - Python script to run update
3. ✅ `BUDGET_UTILIZATION_FIX.md` - This documentation

## ✅ Checklist

- [ ] Run `python update_budget_view.py`
- [ ] Restart Django backend
- [ ] Restart Flutter app
- [ ] Navigate to Budget Utilization
- [ ] Verify Total Spent matches Labour Breakdown
- [ ] Test with new accountant confirmations
- [ ] Verify numbers update correctly

## 🆘 Troubleshooting

### View update fails
```bash
# Check if view exists
psql -d your_database -c "\d+ budget_utilization_summary"

# Drop manually if needed
psql -d your_database -c "DROP VIEW IF EXISTS budget_utilization_summary CASCADE;"

# Run update script again
python update_budget_view.py
```

### Numbers still don't match
1. Check which table the view is reading from
2. Verify cash_entries has data
3. Restart Django backend
4. Clear app cache and restart

### Old data showing
- The view might be cached
- Restart Django backend
- Restart PostgreSQL if needed

## ✅ Success Criteria

After the fix:
1. ✅ Total Spent = Sum of (Material + Labour + Vendor)
2. ✅ Labour cost in Total Spent = Labour cost in Breakdown
3. ✅ Labour Breakdown shows only accountant-confirmed entries
4. ✅ Numbers update when accountant confirms new entries
5. ✅ No duplicate or unconfirmed entries in utilization

---

**Status**: Ready to fix  
**Action Required**: Run `python update_budget_view.py`  
**Impact**: Budget utilization will show accurate, accountant-confirmed data only
