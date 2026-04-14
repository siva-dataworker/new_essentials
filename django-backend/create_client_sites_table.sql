-- Create table to link clients to their sites
CREATE TABLE IF NOT EXISTS client_sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(client_id, site_id)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_client_sites_client ON client_sites(client_id);
CREATE INDEX IF NOT EXISTS idx_client_sites_site ON client_sites(site_id);
CREATE INDEX IF NOT EXISTS idx_client_sites_active ON client_sites(is_active);

-- Analyze table
ANALYZE client_sites;
