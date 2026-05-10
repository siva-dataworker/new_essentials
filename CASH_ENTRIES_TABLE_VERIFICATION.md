# Cash Entries Table Verification

## ✅ Confirmation: Only ONE cash_entries Table

I've verified that there is **only ONE** cash_entries table definition in the codebase.

### Table Definition Location
**File:** `django-backend/create_cash_entries_table.sql`

This is the ONLY place where the cash_entries table is defined.

### Verification Results

#### 1. SQL Files Checked
- ✅ Only ONE CREATE TABLE statement found
- ✅ Located in: `create_cash_entries_table.sql`
- ✅ No duplicate definitions in other SQL files

#### 2. Django Models Checked
- ✅ No Django model class for CashEntry/CashEntries
- ✅ Table is created via raw SQL only
- ✅ No ORM-based table creation

#### 3. Migration Files Checked
- ✅ No Django migrations for cash_entries
- ✅ No duplicate migration files
- ✅ Table created via standalone script only

## How to Verify in Your Database

### Option 1: Run Verification Script
```bash
cd essential/essential/construction_flutter/django-backend
python verify_cash_entries_table.py
```

This will show:
- ✅ Whether table exists
- 📋 Table structure (columns, types, constraints)
- 🔒 Constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- 📊 Indexes
- 📊 Record count
- 📝 Sample data (if any)

### Option 2: Check Database Directly
```sql
-- Check if table exists
SELECT COUNT(*) 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'cash_entries';

-- Show table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'cash_entries'
ORDER BY ordinal_position;

-- Show constraints
SELECT conname, contype
FROM pg_constraint
WHERE conrelid = 'cash_entries'::regclass;
```

## Table Schema (Single Definition)

```sql
CREATE TABLE IF NOT EXISTS cash_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    accountant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    source_type VARCHAR(20) NOT NULL CHECK (source_type IN ('supervisor', 'site_engineer', 'accountant_created')),
    source_entry_id UUID,
    labour_type VARCHAR(100) NOT NULL,
    labour_count INTEGER NOT NULL CHECK (labour_count >= 0),
    daily_rate DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
    notes TEXT,
    submitted_by_name VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(site_id, entry_date, labour_type)
);
```

## Why You Might Think There Are Two Tables

### Possible Reasons:
1. **Multiple Project Folders**: You have both `essential/` and `Essentials_construction_project/` folders
   - But cash_entries is only in `essential/` folder
   - Not in `Essentials_construction_project/` folder

2. **Grep Results**: Search results might show duplicates due to:
   - Same file appearing multiple times in results
   - Index definitions appearing as separate matches
   - Comment lines appearing as separate matches

3. **Database State**: If you ran the creation script multiple times:
   - The `CREATE TABLE IF NOT EXISTS` prevents duplicates
   - Only one table will exist in the database
   - Multiple runs are safe

## Confirmation Commands

### Check for Duplicate Definitions
```bash
# Search for all CREATE TABLE statements
grep -r "CREATE TABLE.*cash_entries" essential/

# Should return only ONE file:
# essential/essential/construction_flutter/django-backend/create_cash_entries_table.sql
```

### Check for Django Models
```bash
# Search for Django model classes
grep -r "class.*CashEntry" essential/

# Should return: No matches found
```

### Check Database
```bash
# Run verification script
python verify_cash_entries_table.py

# Or connect to database and run:
psql -d your_database -c "\d cash_entries"
```

## What to Do Now

### If Table Doesn't Exist Yet
```bash
cd essential/essential/construction_flutter/django-backend
python create_cash_entries_table.py
```

### If Table Already Exists
```bash
# Verify it's correct
python verify_cash_entries_table.py

# If structure is wrong, drop and recreate:
# 1. Connect to database
# 2. DROP TABLE cash_entries CASCADE;
# 3. python create_cash_entries_table.py
```

### If You See Duplicate Data
This would be a data issue, not a table issue:
```sql
-- Check for duplicate entries
SELECT site_id, entry_date, labour_type, COUNT(*)
FROM cash_entries
GROUP BY site_id, entry_date, labour_type
HAVING COUNT(*) > 1;

-- Should return 0 rows (UNIQUE constraint prevents duplicates)
```

## Summary

✅ **Confirmed**: Only ONE cash_entries table definition exists  
✅ **Location**: `django-backend/create_cash_entries_table.sql`  
✅ **Safe to Create**: Running the script multiple times is safe (IF NOT EXISTS)  
✅ **No Duplicates**: UNIQUE constraint prevents duplicate data  

**Next Step**: Run `python verify_cash_entries_table.py` to check your database state.
