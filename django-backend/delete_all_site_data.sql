-- ============================================
-- DELETE ALL SITE DATA
-- ============================================
-- This script deletes:
-- 1. Labour entries (all sites)
-- 2. Material usage (all sites)
-- 3. Photos/Work updates (all sites)
-- 4. Project files/Documents (all sites)
--
-- WARNING: This is IRREVERSIBLE!
-- Run backup_before_delete.sql FIRST!
-- ============================================

-- Show counts BEFORE deletion
SELECT '=== BEFORE DELETION ===' as status;

SELECT 
    'labour_entries' as table_name, 
    COUNT(*) as count,
    COUNT(DISTINCT site_id) as sites_affected
FROM labour_entries
UNION ALL
SELECT 
    'material_usage', 
    COUNT(*),
    COUNT(DISTINCT site_id)
FROM material_usage
UNION ALL
SELECT 
    'work_updates (photos)', 
    COUNT(*),
    COUNT(DISTINCT site_id)
FROM work_updates
UNION ALL
SELECT 
    'project_files (documents)', 
    COUNT(*),
    COUNT(DISTINCT site_id)
FROM project_files;

-- ============================================
-- DELETION STARTS HERE
-- ============================================

-- 1. Delete all labour entries
DELETE FROM labour_entries;

-- 2. Delete all material usage
DELETE FROM material_usage;

-- 3. Delete all work updates (photos)
DELETE FROM work_updates;

-- 4. Delete all project files (documents)
DELETE FROM project_files;

-- ============================================
-- VERIFICATION
-- ============================================

-- Show counts AFTER deletion
SELECT '=== AFTER DELETION ===' as status;

SELECT 
    'labour_entries' as table_name, 
    COUNT(*) as remaining_count
FROM labour_entries
UNION ALL
SELECT 
    'material_usage', 
    COUNT(*)
FROM material_usage
UNION ALL
SELECT 
    'work_updates (photos)', 
    COUNT(*)
FROM work_updates
UNION ALL
SELECT 
    'project_files (documents)', 
    COUNT(*)
FROM project_files;

-- Final summary
SELECT 
    'Deletion completed!' as status,
    (SELECT COUNT(*) FROM labour_entries) as labour_entries_remaining,
    (SELECT COUNT(*) FROM material_usage) as material_usage_remaining,
    (SELECT COUNT(*) FROM work_updates) as work_updates_remaining,
    (SELECT COUNT(*) FROM project_files) as project_files_remaining;

-- Show message
SELECT 
    '✅ All site data deleted successfully!' as message,
    'Sites, users, and other data are preserved' as note;
