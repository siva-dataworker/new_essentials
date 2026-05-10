-- Add selected_role column to total_salary table
ALTER TABLE total_salary 
ADD COLUMN IF NOT EXISTS selected_role VARCHAR(50);

-- Add index for role filtering
CREATE INDEX IF NOT EXISTS idx_total_salary_role ON total_salary(selected_role);

-- Update unique constraint to include role
ALTER TABLE total_salary 
DROP CONSTRAINT IF EXISTS total_salary_site_id_entry_date_key;

ALTER TABLE total_salary 
ADD CONSTRAINT total_salary_site_date_role_key 
UNIQUE(site_id, entry_date, selected_role);
