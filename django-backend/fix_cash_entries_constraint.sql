-- Fix cash_entries UNIQUE constraint
-- Current: UNIQUE(site_id, entry_date) - WRONG
-- Should be: UNIQUE(site_id, entry_date, labour_type) - CORRECT

-- Drop the wrong constraint
ALTER TABLE cash_entries 
DROP CONSTRAINT IF EXISTS cash_entries_site_id_entry_date_key;

-- Add the correct constraint
ALTER TABLE cash_entries 
ADD CONSTRAINT cash_entries_site_id_entry_date_labour_type_key 
UNIQUE (site_id, entry_date, labour_type);

-- Verify the constraint
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'cash_entries'::regclass
  AND contype = 'u'
ORDER BY conname;
