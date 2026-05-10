# Cash Entries System - Complete Workflow

## 📋 Overview

This document explains the complete workflow from when a supervisor/site engineer submits labour entries to when they appear in the admin budget utilization screen.

## 🔄 Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 1: Supervisor/Site Engineer Submits Labour Entries            │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
                    labour_entries table
                    (Raw, unconfirmed entries)
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 2: Accountant Views Compare Screen                            │
│ - Selects date                                                      │
│ - Sees supervisor entries on left                                   │
│ - Sees site engineer entries on right                               │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 3: Accountant Selects ONE Entry                               │
│ - Clicks checkbox on supervisor OR site engineer entry             │
│ - Can only select ONE (not both)                                    │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 4: Accountant Clicks "Confirm Selection"                      │
│ - Backend fetches daily rates from labour_salary_rates             │
│ - Calculates total cost for each labour type                       │
│ - Saves to cash_entries table (one row per labour type)            │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
                    cash_entries table
                    (Confirmed entries only)
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 5: Admin Views Budget Utilization                             │
│ - Reads from cash_entries table                                    │
│ - Shows Total Spent = Material + Labour + Vendor                   │
│ - Shows Labour Breakdown with all labour types                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 📊 Example Scenario

### Scenario: Supervisor submits 4 labour types, Site Engineer submits 1

#### Step 1: Supervisor Submits (Morning)
```
Site: Customer A Site B
Date: 2026-05-08

Labour Entries:
- Plumber: 2 workers
- Helper: 3 workers
- Mason: 1 worker
- General: 4 workers

Saved to: labour_entries table
submitted_by_role: 'Supervisor'
```

#### Step 2: Site Engineer Submits (Morning)
```
Site: Customer A Site B
Date: 2026-05-08

Labour Entries:
- Plumber: 1 worker

Saved to: labour_entries table
submitted_by_role: 'Site Engineer'
```

#### Step 3: Accountant Views Compare Screen
```
Left Side (Supervisor):          Right Side (Site Engineer):
☐ Customer A Site B              ☐ Customer A Site B
  Submitted by: John Doe           Submitted by: Jane Smith
  - Plumber: 2                     - Plumber: 1
  - Helper: 3
  - Mason: 1
  - General: 4
```

#### Step 4: Accountant Selects Supervisor Entry
```
Left Side (Supervisor):          Right Side (Site Engineer):
☑ Customer A Site B              ☐ Customer A Site B
  Submitted by: John Doe           Submitted by: Jane Smith
  - Plumber: 2                     - Plumber: 1
  - Helper: 3
  - Mason: 1
  - General: 4

[Confirm Selection] button at bottom
```

#### Step 5: Accountant Clicks "Confirm Selection"

Backend Process:
```python
# 1. Fetch daily rates from labour_salary_rates table
Plumber rate: ₹700
Helper rate: ₹500
Mason rate: ₹800
General rate: ₹600

# 2. Calculate costs
Plumber: 2 × ₹700 = ₹1,400
Helper: 3 × ₹500 = ₹1,500
Mason: 1 × ₹800 = ₹800
General: 4 × ₹600 = ₹2,400

# 3. Save to cash_entries table (4 rows)
Row 1: site_id, 2026-05-08, Plumber, 2, 700, 1400, 'supervisor'
Row 2: site_id, 2026-05-08, Helper, 3, 500, 1500, 'supervisor'
Row 3: site_id, 2026-05-08, Mason, 1, 800, 800, 'supervisor'
Row 4: site_id, 2026-05-08, General, 4, 600, 2400, 'supervisor'
```

#### Step 6: Admin Views Budget Utilization
```
Budget Utilization for Customer A Site B

Total Budget: ₹50,000
Total Spent: ₹6,100
  - Material: ₹0
  - Labour: ₹6,100
  - Vendor: ₹0

Remaining: ₹43,900
Utilization: 12.2%

Labour Breakdown:
- Plumber: 2 workers × ₹700 = ₹1,400
- Helper: 3 workers × ₹500 = ₹1,500
- Mason: 1 worker × ₹800 = ₹800
- General: 4 workers × ₹600 = ₹2,400

Total Labour Cost: ₹6,100
```

## 🔑 Key Points

### 1. One Entry Per Site Per Day
- Accountant can only confirm ONE entry per site per day
- If supervisor entry is confirmed, site engineer entry is ignored
- If site engineer entry is confirmed, supervisor entry is ignored
- This prevents duplicate entries in budget utilization

### 2. Multiple Labour Types
- Each labour type gets its own row in cash_entries table
- If supervisor submitted 4 labour types, 4 rows are created
- All rows have the same site_id and entry_date
- UNIQUE constraint on (site_id, entry_date, labour_type)

### 3. Daily Rates
- Fetched from labour_salary_rates table (admin-set rates)
- If no admin rate exists, uses default rates:
  - General: ₹600
  - Mason: ₹800
  - Helper: ₹500
  - Plumber: ₹700
  - Carpenter: ₹750
  - Electrician: ₹750
  - Painter: ₹650
  - Tile Layer: ₹700

### 4. Total Cost Calculation
```
total_cost = labour_count × daily_rate
```

### 5. Budget Utilization
- Reads ONLY from cash_entries table
- Does NOT read from labour_entries table
- Shows only accountant-confirmed entries
- Updates automatically when new entries are confirmed

## 📊 Database Tables

### labour_entries (Raw Entries)
```sql
Columns:
- id (UUID)
- site_id (UUID)
- supervisor_id (UUID) -- Can be supervisor or site engineer
- labour_type (VARCHAR)
- labour_count (INTEGER)
- entry_date (DATE)
- entry_time (TIMESTAMP)
- submitted_by_role (VARCHAR) -- 'Supervisor' or 'Site Engineer'
- notes (TEXT)

Purpose: Store raw, unconfirmed labour entries
Used by: Supervisor, Site Engineer (submit), Accountant (view)
```

### cash_entries (Confirmed Entries)
```sql
Columns:
- id (UUID)
- site_id (UUID)
- accountant_id (UUID)
- entry_date (DATE)
- source_type (VARCHAR) -- 'supervisor', 'site_engineer', 'accountant_created'
- source_entry_id (UUID) -- Reference to labour_entries.id
- labour_type (VARCHAR)
- labour_count (INTEGER)
- daily_rate (DECIMAL)
- total_cost (DECIMAL)
- submitted_by_name (VARCHAR)
- created_at (TIMESTAMP)

Constraints:
- UNIQUE(site_id, entry_date, labour_type)

Purpose: Store accountant-confirmed labour entries
Used by: Accountant (create), Admin (view in budget utilization)
```

### labour_salary_rates (Daily Rates)
```sql
Columns:
- id (UUID)
- site_id (UUID) -- NULL for global rates
- labour_type (VARCHAR)
- daily_rate (DECIMAL)
- effective_from (DATE)
- is_active (BOOLEAN)

Purpose: Store admin-set daily rates for labour types
Used by: Admin (set), Backend (fetch for calculations)
```

## 🔍 Troubleshooting

### Issue: "No Entries Found" in Compare Screen

**Possible Causes:**
1. No labour entries for selected date
2. submitted_by_role column is NULL or incorrect
3. Backend query filtering incorrectly

**Solution:**
```bash
# Check if entries exist
python debug_compare_screen.py

# Check submitted_by_role values
SELECT entry_date, labour_type, submitted_by_role 
FROM labour_entries 
WHERE entry_date = '2026-05-08';
```

### Issue: "Cash entry already exists"

**Cause:** Accountant already confirmed an entry for this site and date

**Solution:**
```bash
# Delete existing entry
python delete_cash_entry_for_site.py

# Or delete all entries
python delete_all_cash_entries.py
```

### Issue: Budget utilization shows wrong numbers

**Possible Causes:**
1. budget_utilization_summary VIEW reading from wrong table
2. cash_entries table empty
3. Rates not calculated correctly

**Solution:**
```bash
# Check if VIEW reads from cash_entries
python update_budget_view.py

# Check cash_entries data
python check_cash_entries_columns.py

# Restart Django backend
```

## ✅ Testing Checklist

### Test 1: Supervisor Entry Flow
- [ ] Login as Supervisor
- [ ] Submit labour entries (multiple types)
- [ ] Login as Accountant
- [ ] Go to Compare tab
- [ ] Select today's date
- [ ] Verify supervisor entry appears on left
- [ ] Select supervisor entry (checkbox)
- [ ] Click "Confirm Selection"
- [ ] Verify success message
- [ ] Login as Admin
- [ ] Go to Budget Utilization
- [ ] Verify all labour types appear
- [ ] Verify costs are calculated correctly

### Test 2: Site Engineer Entry Flow
- [ ] Login as Site Engineer
- [ ] Submit labour entry
- [ ] Login as Accountant
- [ ] Go to Compare tab
- [ ] Select today's date
- [ ] Verify site engineer entry appears on right
- [ ] Select site engineer entry (checkbox)
- [ ] Click "Confirm Selection"
- [ ] Verify success message
- [ ] Login as Admin
- [ ] Go to Budget Utilization
- [ ] Verify labour entry appears

### Test 3: Custom Entry Flow
- [ ] Login as Accountant
- [ ] Go to Compare tab
- [ ] Click "+" button
- [ ] Fill form (site, date, labour type, count)
- [ ] Click "Create"
- [ ] Verify success message
- [ ] Login as Admin
- [ ] Go to Budget Utilization
- [ ] Verify custom entry appears

### Test 4: Duplicate Prevention
- [ ] Confirm an entry for a site and date
- [ ] Try to confirm another entry for same site and date
- [ ] Verify error: "Cash entry already exists"

### Test 5: Budget Calculation
- [ ] Confirm entry with multiple labour types
- [ ] Login as Admin
- [ ] Go to Budget Utilization
- [ ] Verify Total Spent = Material + Labour + Vendor
- [ ] Verify Labour cost in Total = Labour cost in Breakdown
- [ ] Verify each labour type shows correct calculation

## 📝 Utility Scripts

### Check Table Structure
```bash
python check_cash_entries_columns.py
```
Shows: columns, constraints, indexes, row count, sample data

### Delete Entry for Specific Site
```bash
python delete_cash_entry_for_site.py
```
Prompts for site_id and date, deletes matching entries

### Delete All Entries
```bash
python delete_all_cash_entries.py
```
Deletes all rows from cash_entries table

### Debug Compare Screen
```bash
python debug_compare_screen.py
```
Shows labour_entries for today, checks submitted_by_role values

## 🎯 Success Criteria

✅ Accountant can view supervisor and site engineer entries side by side
✅ Accountant can select ONE entry (not both)
✅ Accountant can confirm selection
✅ Confirmed entries saved to cash_entries table (one row per labour type)
✅ Only ONE entry per site per day allowed
✅ Admin budget utilization shows correct labour costs
✅ Total Spent matches Labour Breakdown
✅ All labour types appear in breakdown
✅ Costs calculated correctly (count × rate)

---

**Status**: Implementation Complete ✅  
**Last Updated**: 2026-05-08  
**Next Step**: Run `python check_cash_entries_columns.py` to verify table structure
