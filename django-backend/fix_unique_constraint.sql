-- Remove UNIQUE constraint from labour_entries table
-- This allows multiple labour types per site per day

-- Drop the constraint if it exists
ALTER TABLE labour_entries DROP CONSTRAINT IF EXISTS labour_entries_site_id_entry_date_key;

-- Verify the constraint is removed
SELECT conname, contype 
FROM pg_constraint 
WHERE conrelid = 'labour_entries'::regclass;
