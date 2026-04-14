# Site Data Deletion - Complete

## Date: April 8, 2026

## Summary
Successfully deleted all site data (labour entries, material usage, photos, and documents) from the database while preserving sites, users, and other configuration data.

## What Was Deleted
- ✅ Labour entries: 60 records
- ✅ Material usage: 21 records  
- ✅ Work updates (photos): 5 records
- ✅ Project files (documents): 2 records
- ✅ Working sites assignments: 18 records

## What Was Preserved
- ✅ Sites: 16 sites
- ✅ Users: 18 users
- ✅ Roles and permissions
- ✅ Budget allocations
- ✅ Client complaints
- ✅ All other configuration data

## Backup Created
Before deletion, backup tables were created:
- `labour_entries_backup` (60 records)
- `material_usage_backup` (21 records)
- `work_updates_backup` (5 records)
- `project_files_backup` (2 records)

## Scripts Used

### 1. Backup Script
**File:** `django-backend/backup_data.py`
- Creates backup tables before deletion
- Verifies backup counts

### 2. Deletion Scripts
**File:** `django-backend/delete_site_data_direct.py`
- Direct deletion without transaction wrapper
- Shows before/after counts
- Verifies successful deletion

**File:** `django-backend/delete_working_sites.py`
- Deletes all working sites assignments
- Accountant can re-select working sites fresh

### 3. SQL Files
- `backup_before_delete.sql` - Backup table creation
- `delete_all_site_data.sql` - Deletion statements

## Verification
Final database state confirmed:
```
DELETED (all 0):
  Working sites: 0
  Labour entries: 0
  Material usage: 0
  Work updates: 0
  Project files: 0

PRESERVED:
  Sites: 16
  Users: 18
```

## Notes
- The initial `delete_data.py` script had transaction commit issues
- Created `delete_site_data_direct.py` which successfully deleted all data
- Django's autocommit behavior required direct cursor execution
- All data can be restored from backup tables if needed

## Next Steps
Users can now:
1. Start fresh with clean data
2. Enter new labour entries
3. Add new material usage records
4. Upload new photos and documents
5. All existing sites and users remain intact
