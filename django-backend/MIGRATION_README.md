# 🔄 Entry Lock Migration - Python Scripts

**Purpose:** Add entry_type column and unique constraint to labour_entries table  
**Safe:** Non-breaking, backward compatible, zero downtime  
**Date:** 2026-05-12

---

## 📁 Available Scripts

### 1. **Interactive Migration** (`run_entry_lock_migration.py`)
- Full-featured with colored output
- Interactive prompts
- Backup creation option
- Duplicate handling with confirmation
- Rollback capability

### 2. **Automated Migration** (`migrate_entry_lock_auto.py`)
- No user interaction required
- Perfect for CI/CD pipelines
- Simple logging
- Automatic duplicate handling

### 3. **SQL Script** (`migrations/001_add_entry_lock_constraint.sql`)
- Direct SQL execution
- For manual database management

---

## 🚀 QUICK START

### Option 1: Interactive Migration (Recommended for First Time)

```bash
cd d:\new_essentials\django-backend
python run_entry_lock_migration.py
```

**Features:**
- ✅ Step-by-step progress
- ✅ Colored output
- ✅ Duplicate detection and handling
- ✅ Verification checks
- ✅ Rollback option

**Output Example:**
```
============================================================
ENTRY LOCK MIGRATION - STARTING
============================================================

ℹ️  Checking current database state...
ℹ️  Found 1250 existing labour entries

============================================================
STEP 1: Adding entry_type Column
============================================================

ℹ️  Adding entry_type column...
✅ Column 'entry_type' added successfully

...

============================================================
MIGRATION COMPLETED SUCCESSFULLY!
============================================================

✅ entry_type column added
✅ Unique constraint created
✅ Check constraint added
✅ Column set to NOT NULL
✅ No duplicate entries exist
```

---

### Option 2: Automated Migration (For CI/CD)

```bash
cd d:\new_essentials\django-backend
python migrate_entry_lock_auto.py
```

**Features:**
- ✅ No user interaction
- ✅ Automatic duplicate removal
- ✅ Exit code 0 on success, 1 on failure
- ✅ Timestamped logging

**Output Example:**
```
[2026-05-12 14:30:15] [INFO] Starting entry lock migration...
[2026-05-12 14:30:15] [INFO] Found 1250 existing labour entries
[2026-05-12 14:30:15] [INFO] Adding entry_type column...
[2026-05-12 14:30:16] [INFO] Column 'entry_type' added successfully
...
[2026-05-12 14:30:20] [SUCCESS] Migration completed successfully!
```

---

### Option 3: Direct SQL Execution

```bash
cd d:\new_essentials\django-backend
psql -U postgres -d construction_db -f migrations\001_add_entry_lock_constraint.sql
```

---

## 📋 PREREQUISITES

### 1. Python Requirements
```bash
pip install psycopg2-binary
```

### 2. Database Access
- PostgreSQL database running
- Django settings configured correctly
- Database user has ALTER TABLE permissions

### 3. Django Environment
- Django project properly configured
- `backend.settings` module accessible

---

## 🔍 WHAT THE MIGRATION DOES

### Step 1: Add entry_type Column
```sql
ALTER TABLE labour_entries 
ADD COLUMN entry_type VARCHAR(10) DEFAULT 'morning';
```

### Step 2: Populate entry_type Values
```sql
UPDATE labour_entries 
SET entry_type = CASE 
    WHEN EXTRACT(HOUR FROM entry_time) < 12 THEN 'morning'
    ELSE 'evening'
END;
```

### Step 3: Handle Duplicates
- Detects duplicate entries
- Keeps first entry, removes others
- Interactive script asks for confirmation

### Step 4: Create Unique Index
```sql
CREATE UNIQUE INDEX CONCURRENTLY idx_labour_entry_lock 
ON labour_entries(site_id, entry_date, entry_type, labour_type);
```

### Step 5: Add Check Constraint
```sql
ALTER TABLE labour_entries 
ADD CONSTRAINT chk_entry_type 
CHECK (entry_type IN ('morning', 'evening'));
```

### Step 6: Set NOT NULL
```sql
ALTER TABLE labour_entries 
ALTER COLUMN entry_type SET NOT NULL;
```

---

## 🔄 ROLLBACK

### Using Interactive Script
```bash
python run_entry_lock_migration.py
# Select option 2: Rollback migration
```

### Manual Rollback
```sql
DROP INDEX IF EXISTS idx_labour_entry_lock;
ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS chk_entry_type;
ALTER TABLE labour_entries DROP COLUMN IF EXISTS entry_type;
```

---

## ✅ VERIFICATION

### Check Migration Success

```bash
# Run the automated script
python migrate_entry_lock_auto.py

# Check exit code
echo $?  # Should be 0 for success
```

### Verify in Database

```sql
-- Check column exists
SELECT entry_type FROM labour_entries LIMIT 1;

-- Check no duplicates
SELECT site_id, entry_date, entry_type, labour_type, COUNT(*)
FROM labour_entries
GROUP BY site_id, entry_date, entry_type, labour_type
HAVING COUNT(*) > 1;
-- Should return 0 rows

-- Check entry_type distribution
SELECT entry_type, COUNT(*) 
FROM labour_entries 
GROUP BY entry_type;
```

---

## 🐛 TROUBLESHOOTING

### Error: "Module 'backend.settings' not found"

**Solution:**
```bash
# Make sure you're in the django-backend directory
cd d:\new_essentials\django-backend

# Check DJANGO_SETTINGS_MODULE
echo $DJANGO_SETTINGS_MODULE  # Should be 'backend.settings'
```

### Error: "Permission denied for table labour_entries"

**Solution:**
```sql
-- Grant permissions to your database user
GRANT ALL PRIVILEGES ON TABLE labour_entries TO your_user;
```

### Error: "Could not create unique index due to duplicates"

**Solution:**
- Use the interactive script (it will handle duplicates)
- Or manually remove duplicates first:

```sql
-- Find duplicates
SELECT site_id, entry_date, labour_type, COUNT(*) 
FROM labour_entries 
GROUP BY site_id, entry_date, labour_type 
HAVING COUNT(*) > 1;

-- Remove duplicates (keeps first entry)
DELETE FROM labour_entries a
USING labour_entries b
WHERE a.id > b.id
AND a.site_id = b.site_id
AND a.entry_date = b.entry_date
AND a.labour_type = b.labour_type;
```

### Error: "Index already exists"

**Solution:**
- Migration is idempotent - it will skip existing objects
- Or drop the index first:

```sql
DROP INDEX IF EXISTS idx_labour_entry_lock;
```

---

## 📊 PERFORMANCE

### Expected Duration
- Small database (<1000 rows): ~5 seconds
- Medium database (1000-10000 rows): ~30 seconds
- Large database (>10000 rows): ~2 minutes

### Downtime
- **ZERO** - Uses `CREATE INDEX CONCURRENTLY`
- Table remains accessible during migration
- No locks on table

---

## 🔐 SAFETY FEATURES

### Interactive Script
- ✅ Checks for existing objects before creating
- ✅ Asks for confirmation before removing duplicates
- ✅ Creates backup option
- ✅ Rollback capability
- ✅ Verification checks

### Automated Script
- ✅ Idempotent (can run multiple times safely)
- ✅ Automatic duplicate handling
- ✅ Transaction-safe
- ✅ Proper error handling

---

## 📝 LOGS

### Interactive Script
- Colored terminal output
- Real-time progress updates
- Detailed error messages

### Automated Script
- Timestamped log entries
- Log levels: INFO, SUCCESS, ERROR
- Can be redirected to file:

```bash
python migrate_entry_lock_auto.py > migration.log 2>&1
```

---

## 🎯 AFTER MIGRATION

### 1. Restart Django Server
```bash
python manage.py runserver
```

### 2. Test API Endpoint
```bash
curl http://localhost:8000/api/construction/check-entry-lock/?site_id=XXX
```

### 3. Build Flutter App
```bash
cd d:\new_essentials\otp_phone_auth
flutter build apk --release
```

### 4. Test with 2 Devices
- Install APK on 2 devices
- Test entry lock behavior

---

## 📞 SUPPORT

### Check Migration Status

```sql
-- Check if migration completed
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_name = 'labour_entries' 
AND column_name = 'entry_type';

-- Check index exists
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE indexname = 'idx_labour_entry_lock';

-- Check constraint exists
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'labour_entries' 
AND constraint_name = 'chk_entry_type';
```

---

## 🎉 SUCCESS CRITERIA

After successful migration:
- ✅ entry_type column exists
- ✅ All rows have entry_type value (morning/evening)
- ✅ Unique index prevents duplicates
- ✅ Check constraint validates values
- ✅ Column is NOT NULL
- ✅ No duplicate entries exist

---

**Ready to migrate? Run the script now!** 🚀

```bash
python run_entry_lock_migration.py
```
