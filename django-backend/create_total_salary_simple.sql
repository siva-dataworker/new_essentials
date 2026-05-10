-- Create total_salary table to track net salary (labour entries - cash entries)
CREATE TABLE IF NOT EXISTS total_salary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    
    -- Salary breakdown
    total_labour_cost DECIMAL(12, 2) NOT NULL DEFAULT 0, -- Total from labour_entries
    total_cash_paid DECIMAL(12, 2) NOT NULL DEFAULT 0,   -- Total from cash_entries
    net_salary DECIMAL(12, 2) NOT NULL DEFAULT 0,        -- total_labour_cost - total_cash_paid
    
    -- Worker counts
    total_workers INTEGER NOT NULL DEFAULT 0,
    
    -- Metadata
    calculated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure only one entry per site per date
    UNIQUE(site_id, entry_date)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_total_salary_site ON total_salary(site_id);
CREATE INDEX IF NOT EXISTS idx_total_salary_date ON total_salary(entry_date);
CREATE INDEX IF NOT EXISTS idx_total_salary_site_date ON total_salary(site_id, entry_date);
