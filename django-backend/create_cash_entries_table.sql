-- Create cash_entries table for accountant-confirmed labour entries
CREATE TABLE IF NOT EXISTS cash_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    accountant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    
    -- Source of the entry
    source_type VARCHAR(20) NOT NULL CHECK (source_type IN ('supervisor', 'site_engineer', 'accountant_created')),
    source_entry_id UUID, -- Reference to original labour_entries.id if from supervisor/engineer
    
    -- Labour details (each labour type gets its own row)
    labour_type VARCHAR(100) NOT NULL,
    labour_count INTEGER NOT NULL CHECK (labour_count >= 0),
    daily_rate DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
    
    -- Additional info
    notes TEXT,
    submitted_by_name VARCHAR(255), -- Name of supervisor/engineer who originally submitted
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure only one entry per site per date per labour type
    UNIQUE(site_id, entry_date, labour_type)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_cash_entries_site_date ON cash_entries(site_id, entry_date);
CREATE INDEX IF NOT EXISTS idx_cash_entries_accountant ON cash_entries(accountant_id);
CREATE INDEX IF NOT EXISTS idx_cash_entries_source ON cash_entries(source_type, source_entry_id);

-- Add comment
COMMENT ON TABLE cash_entries IS 'Stores accountant-confirmed labour entries for cash management. Each labour type gets its own row. Only one entry per site per date per labour type allowed.';

