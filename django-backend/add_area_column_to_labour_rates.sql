-- Add area column to labour_salary_rates table for local rates
-- This allows setting different rates for different areas

ALTER TABLE labour_salary_rates 
ADD COLUMN IF NOT EXISTS area VARCHAR(255);

-- Add index for faster queries on area
CREATE INDEX IF NOT EXISTS idx_labour_salary_rates_area 
ON labour_salary_rates(area);

-- Add composite index for area + labour_type lookups
CREATE INDEX IF NOT EXISTS idx_labour_salary_rates_area_labour_type 
ON labour_salary_rates(area, labour_type) 
WHERE is_active = TRUE;

-- Add comment
COMMENT ON COLUMN labour_salary_rates.area IS 'Area name for local rates. NULL means global rate.';
