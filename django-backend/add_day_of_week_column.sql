-- Add day_of_week column to labour_entries and material_balances tables

-- Add column to labour_entries
ALTER TABLE labour_entries 
ADD COLUMN IF NOT EXISTS day_of_week VARCHAR(10);

-- Add column to material_balances
ALTER TABLE material_balances 
ADD COLUMN IF NOT EXISTS day_of_week VARCHAR(10);

-- Update existing entries with day of week based on entry_date
-- For labour_entries
UPDATE labour_entries 
SET day_of_week = CASE EXTRACT(DOW FROM entry_date)
    WHEN 0 THEN 'Sunday'
    WHEN 1 THEN 'Monday'
    WHEN 2 THEN 'Tuesday'
    WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday'
    WHEN 5 THEN 'Friday'
    WHEN 6 THEN 'Saturday'
END
WHERE day_of_week IS NULL;

-- For material_balances (using entry_date field)
UPDATE material_balances 
SET day_of_week = CASE EXTRACT(DOW FROM entry_date)
    WHEN 0 THEN 'Sunday'
    WHEN 1 THEN 'Monday'
    WHEN 2 THEN 'Tuesday'
    WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday'
    WHEN 5 THEN 'Friday'
    WHEN 6 THEN 'Saturday'
END
WHERE day_of_week IS NULL;

-- Verify the changes
SELECT 'labour_entries' as table_name, day_of_week, COUNT(*) as count
FROM labour_entries
GROUP BY day_of_week
UNION ALL
SELECT 'material_balances' as table_name, day_of_week, COUNT(*) as count
FROM material_balances
GROUP BY day_of_week
ORDER BY table_name, day_of_week;
