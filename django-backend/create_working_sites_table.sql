-- Create working_sites table for accountant to assign sites to supervisors
CREATE TABLE IF NOT EXISTS working_sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accountant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    supervisor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    description TEXT,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(supervisor_id, site_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_working_sites_accountant ON working_sites(accountant_id);
CREATE INDEX IF NOT EXISTS idx_working_sites_supervisor ON working_sites(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_working_sites_site ON working_sites(site_id);
CREATE INDEX IF NOT EXISTS idx_working_sites_active ON working_sites(is_active);

-- Add comments
COMMENT ON TABLE working_sites IS 'Stores sites assigned by accountant to supervisors';
COMMENT ON COLUMN working_sites.description IS 'Optional description/notes about the site assignment';
COMMENT ON COLUMN working_sites.is_active IS 'Whether the site assignment is currently active';

-- Verify table creation
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'working_sites'
ORDER BY ordinal_position;
