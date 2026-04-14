-- Backup script before deleting data
-- Run this BEFORE running the delete script to create backups

-- Create backup tables
CREATE TABLE IF NOT EXISTS labour_entries_backup AS SELECT * FROM labour_entries;
CREATE TABLE IF NOT EXISTS material_usage_backup AS SELECT * FROM material_usage;
CREATE TABLE IF NOT EXISTS work_updates_backup AS SELECT * FROM work_updates;
CREATE TABLE IF NOT EXISTS project_files_backup AS SELECT * FROM project_files;

-- Verify backup counts
SELECT 'labour_entries' as table_name, COUNT(*) as original_count FROM labour_entries
UNION ALL
SELECT 'labour_entries_backup', COUNT(*) FROM labour_entries_backup
UNION ALL
SELECT 'material_usage', COUNT(*) FROM material_usage
UNION ALL
SELECT 'material_usage_backup', COUNT(*) FROM material_usage_backup
UNION ALL
SELECT 'work_updates', COUNT(*) FROM work_updates
UNION ALL
SELECT 'work_updates_backup', COUNT(*) FROM work_updates_backup
UNION ALL
SELECT 'project_files', COUNT(*) FROM project_files
UNION ALL
SELECT 'project_files_backup', COUNT(*) FROM project_files_backup;

-- Show summary
SELECT 
    'Backup created successfully!' as status,
    (SELECT COUNT(*) FROM labour_entries_backup) as labour_entries_backed_up,
    (SELECT COUNT(*) FROM material_usage_backup) as material_usage_backed_up,
    (SELECT COUNT(*) FROM work_updates_backup) as work_updates_backed_up,
    (SELECT COUNT(*) FROM project_files_backup) as project_files_backed_up;
