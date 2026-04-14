-- Optimize sites table for faster queries
-- Add indexes for commonly queried columns

-- Index for status column (used in WHERE clause)
CREATE INDEX IF NOT EXISTS idx_sites_status ON sites(status);

-- Index for customer_name and site_name (used in ORDER BY)
CREATE INDEX IF NOT EXISTS idx_sites_customer_site ON sites(customer_name, site_name);

-- Composite index for filtering and sorting
CREATE INDEX IF NOT EXISTS idx_sites_status_customer_site ON sites(status, customer_name, site_name);

-- Analyze the table to update statistics
ANALYZE sites;
