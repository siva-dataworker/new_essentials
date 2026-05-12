# 🚀 RUN DATABASE MIGRATION - QUICK GUIDE

**IMPORTANT:** Run this migration before testing the entry lock system!

---

## ⚡ QUICK START (Windows)

### Option 1: Using psql Command Line

```cmd
cd d:\new_essentials\django-backend
psql -U postgres -d construction_db -f migrations\001_add_entry_lock_constraint.sql
```

### Option 2: Using pgAdmin
1. Open pgAdmin
2. Connect to your database
3. Right-click on `construction_db` → Query Tool
4. Open file: `django-backend/migrations/001_add_entry_lock_constraint.sql`
5. Click Execute (F5)

---

## 📋 WHAT THE MIGRATION DOES

1. ✅ Adds `entry_type` column to `labour_entries` table
2. ✅ Populates existing data (morning/evening based on time)
3. ✅ Creates unique index to prevent duplicates
4. ✅ Adds validation constraints

**Time:** ~30 seconds  
**Downtime:** ZERO (uses CONCURRENTLY)  
**Breaking Changes:** NONE

---

## ✅ VERIFY MIGRATION SUCCESS

After running, check for success message:
```
✅ Migration completed successfully!
✅ entry_type column added
✅ Unique constraint created
✅ Check constraint added
```

---

## 🔍 VERIFY DATA

Check that no duplicates exist:
```sql
SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
FROM labour_entries
GROUP BY site_id, entry_date, entry_type, labour_type
HAVING COUNT(*) > 1;
```

**Expected Result:** 0 rows (no duplicates)

---

## 🔄 ROLLBACK (If Needed)

If something goes wrong:
```sql
-- Remove constraints
DROP INDEX IF EXISTS idx_labour_entry_lock;
ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS chk_entry_type;

-- Remove column (optional)
ALTER TABLE labour_entries DROP COLUMN IF EXISTS entry_type;
```

---

## 🎯 AFTER MIGRATION

1. ✅ Restart Django server
2. ✅ Test with Postman/curl
3. ✅ Build Flutter APK
4. ✅ Test with 2 devices

---

## 📞 NEED HELP?

Check the full implementation guide:
- `ENTRY_LOCK_SYSTEM_IMPLEMENTED.md`
- `IMPLEMENTATION_GUIDE_ENTRY_LOCKS.md`

---

**Ready to run? Execute the migration now!** 🚀
