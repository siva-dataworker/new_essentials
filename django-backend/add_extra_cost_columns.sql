-- Add extra_cost columns to labour_entries and material_balances tables
-- This allows supervisors to record additional/miscellaneous costs

-- Add extra cost columns to labour_entries
ALTER TABLE labour_entries 
ADD COLUMN IF NOT EXISTS extra_cost DECIMAL(10, 2) DEFAULT 0 CHECK (extra_cost >= 0),
ADD COLUMN IF NOT EXISTS extra_cost_notes TEXT;

-- Add extra cost columns to material_balances
ALTER TABLE material_balances 
ADD COLUMN IF NOT EXISTS extra_cost DECIMAL(10, 2) DEFAULT 0 CHECK (extra_cost >= 0),
ADD COLUMN IF NOT EXISTS extra_cost_notes TEXT;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_labour_extra_cost ON labour_entries(extra_cost) WHERE extra_cost > 0;
CREATE INDEX IF NOT EXISTS idx_material_extra_cost ON material_balances(extra_cost) WHERE extra_cost > 0;

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('labour_entries', 'material_balances')
    AND column_name IN ('extra_cost', 'extra_cost_notes', 'entry_time', 'updated_at')
ORDER BY table_name, ordinal_position;
