-- Migration: Add Entry Lock Constraint
-- Purpose: Prevent multiple supervisors from entering data for same site/date/time
-- Date: 2026-05-12
-- Safe: Non-breaking, backward compatible

-- STEP 1: Add entry_type column (morning/evening)
ALTER TABLE labour_entries 
ADD COLUMN IF NOT EXISTS entry_type VARCHAR(10) DEFAULT 'morning';

-- STEP 2: Update existing data based on entry_time
UPDATE labour_entries 
SET entry_type = CASE 
    WHEN EXTRACT(HOUR FROM entry_time) < 12 THEN 'morning'
    ELSE 'evening'
END
WHERE entry_type IS NULL OR entry_type = 'morning';

-- STEP 3: Add composite unique constraint
-- This prevents multiple supervisors from entering same site/date/type
-- Using CONCURRENTLY to avoid locking the table
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS 
    idx_labour_entry_lock 
ON labour_entries(site_id, entry_date, entry_type, labour_type);

-- STEP 4: Add check constraint for entry_type
ALTER TABLE labour_entries 
ADD CONSTRAINT chk_entry_type 
CHECK (entry_type IN ('morning', 'evening'));

-- STEP 5: Make entry_type NOT NULL
ALTER TABLE labour_entries 
ALTER COLUMN entry_type SET NOT NULL;

-- STEP 6: Verify no duplicates exist
SELECT site_id, entry_date, entry_type, labour_type, COUNT(*) as count
FROM labour_entries
GROUP BY site_id, entry_date, entry_type, labour_type
HAVING COUNT(*) > 1;
-- Should return 0 rows

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Migration completed successfully!';
    RAISE NOTICE '✅ entry_type column added';
    RAISE NOTICE '✅ Unique constraint created';
    RAISE NOTICE '✅ Check constraint added';
END $$;
