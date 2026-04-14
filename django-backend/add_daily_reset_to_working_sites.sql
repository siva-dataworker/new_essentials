-- Add daily reset tracking to working_sites table
-- This allows automatic reset of working sites at 6 AM daily

-- Add last_reset_date column to track when sites were last reset
ALTER TABLE working_sites 
ADD COLUMN IF NOT EXISTS last_reset_date DATE DEFAULT CURRENT_DATE;

-- Add index for efficient querying
CREATE INDEX IF NOT EXISTS idx_working_sites_reset_date ON working_sites(last_reset_date);

-- Add comment
COMMENT ON COLUMN working_sites.last_reset_date IS 'Date when working sites were last reset (6 AM daily)';

-- Verify the column was added
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'working_sites' AND column_name = 'last_reset_date';
