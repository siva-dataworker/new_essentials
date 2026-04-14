-- Admin Features Migration (Fixed for existing schema)
-- New tables for enhanced admin functionality

-- Site Metrics Table
CREATE TABLE IF NOT EXISTS site_metrics (
    id SERIAL PRIMARY KEY,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    built_up_area DECIMAL(10, 2),
    project_value DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    profit_loss DECIMAL(15, 2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(site_id)
);

-- Site Documents Table
CREATE TABLE IF NOT EXISTS site_documents (
    id SERIAL PRIMARY KEY,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    document_type VARCHAR(20) CHECK (document_type IN ('PLAN', 'ELEVATION', 'STRUCTURE', 'FINAL_OUTPUT')),
    document_name VARCHAR(200) NOT NULL,
    file_path TEXT NOT NULL,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_site_documents_site ON site_documents(site_id);
CREATE INDEX IF NOT EXISTS idx_site_documents_type ON site_documents(document_type);

-- Admin Access Log Table
CREATE TABLE IF NOT EXISTS admin_access_log (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    access_type VARCHAR(20) CHECK (access_type IN ('LABOUR_COUNT', 'BILLS_VIEW', 'FULL_ACCOUNTS')),
    site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_admin_access_user ON admin_access_log(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_access_type ON admin_access_log(access_type);

-- Work Notifications Table
CREATE TABLE IF NOT EXISTS work_notifications (
    id SERIAL PRIMARY KEY,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    sent_to UUID REFERENCES users(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_work_notifications_site ON work_notifications(site_id);
CREATE INDEX IF NOT EXISTS idx_work_notifications_user ON work_notifications(sent_to);
CREATE INDEX IF NOT EXISTS idx_work_notifications_read ON work_notifications(is_read);

-- Add access_type field to users table if not exists
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'access_type'
    ) THEN
        ALTER TABLE users ADD COLUMN access_type VARCHAR(20) 
            CHECK (access_type IN ('LABOUR_COUNT', 'BILLS_VIEW', 'FULL_ACCOUNTS', 'STANDARD'));
    END IF;
END $$;

-- Set default access type for existing users
UPDATE users SET access_type = 'STANDARD' WHERE access_type IS NULL;

-- Create view for total material purchased per site
CREATE OR REPLACE VIEW site_material_purchases AS
SELECT 
    s.id as site_id,
    s.site_name,
    mb.material_type as material_name,
    SUM(mb.total_amount) as total_purchased,
    COUNT(mb.id) as purchase_count
FROM sites s
JOIN material_bills mb ON s.id = mb.site_id
WHERE mb.is_active = TRUE
GROUP BY s.id, s.site_name, mb.material_type;

-- Create view for site comparison
CREATE OR REPLACE VIEW site_comparison_view AS
SELECT 
    s.id as site_id,
    s.site_name,
    sm.built_up_area,
    sm.project_value,
    sm.total_cost,
    sm.profit_loss,
    COUNT(DISTINCT le.id) as total_labour_entries,
    SUM(le.labour_count) as total_labour_count,
    SUM(mb.total_amount) as total_material_cost
FROM sites s
LEFT JOIN site_metrics sm ON s.id = sm.site_id
LEFT JOIN labour_entries le ON s.id = le.site_id
LEFT JOIN material_bills mb ON s.id = mb.site_id AND mb.is_active = TRUE
GROUP BY s.id, s.site_name, sm.built_up_area, sm.project_value, sm.total_cost, sm.profit_loss;

-- Add comments
COMMENT ON TABLE site_metrics IS 'Stores site-level metrics including built-up area, project value, and P/L';
COMMENT ON TABLE site_documents IS 'Stores site documents like plans, elevations, structure, and final output images';
COMMENT ON TABLE admin_access_log IS 'Tracks specialized admin logins (labour count, bills view, full accounts)';
COMMENT ON TABLE work_notifications IS 'Notifications for work not done sent to chief accountant/owner';
