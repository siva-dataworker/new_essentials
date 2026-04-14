-- Admin Features Migration
-- New tables for enhanced admin functionality

-- Site Metrics Table
CREATE TABLE IF NOT EXISTS site_metrics (
    metrics_id SERIAL PRIMARY KEY,
    site_id INTEGER REFERENCES sites(site_id) ON DELETE CASCADE,
    built_up_area DECIMAL(10, 2),
    project_value DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    profit_loss DECIMAL(15, 2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(site_id)
);

-- Site Documents Table
CREATE TABLE IF NOT EXISTS site_documents (
    document_id SERIAL PRIMARY KEY,
    site_id INTEGER REFERENCES sites(site_id) ON DELETE CASCADE,
    document_type VARCHAR(20) CHECK (document_type IN ('PLAN', 'ELEVATION', 'STRUCTURE', 'FINAL_OUTPUT')),
    document_name VARCHAR(200) NOT NULL,
    file_path TEXT NOT NULL,
    uploaded_by INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_site_documents_site ON site_documents(site_id);
CREATE INDEX idx_site_documents_type ON site_documents(document_type);

-- Admin Access Log Table
CREATE TABLE IF NOT EXISTS admin_access_log (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    access_type VARCHAR(20) CHECK (access_type IN ('LABOUR_COUNT', 'BILLS_VIEW', 'FULL_ACCOUNTS')),
    site_id INTEGER REFERENCES sites(site_id) ON DELETE SET NULL,
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_access_user ON admin_access_log(user_id);
CREATE INDEX idx_admin_access_type ON admin_access_log(access_type);

-- Work Notifications Table
CREATE TABLE IF NOT EXISTS work_notifications (
    notification_id SERIAL PRIMARY KEY,
    site_id INTEGER REFERENCES sites(site_id) ON DELETE CASCADE,
    report_id INTEGER REFERENCES daily_site_report(report_id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    sent_to INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_work_notifications_site ON work_notifications(site_id);
CREATE INDEX idx_work_notifications_user ON work_notifications(sent_to);
CREATE INDEX idx_work_notifications_read ON work_notifications(is_read);

-- Add access_type field to users table for specialized logins
ALTER TABLE users ADD COLUMN IF NOT EXISTS access_type VARCHAR(20) 
    CHECK (access_type IN ('LABOUR_COUNT', 'BILLS_VIEW', 'FULL_ACCOUNTS', 'STANDARD'));

-- Set default access type for existing users
UPDATE users SET access_type = 'STANDARD' WHERE access_type IS NULL;

-- Create view for total material purchased per site
CREATE OR REPLACE VIEW site_material_purchases AS
SELECT 
    s.site_id,
    s.site_name,
    m.material_name,
    SUM(mb.bill_amount) as total_purchased,
    COUNT(mb.bill_id) as purchase_count
FROM sites s
JOIN daily_site_report dsr ON s.site_id = dsr.site_id
JOIN material_bills mb ON dsr.report_id = mb.report_id
JOIN material_master m ON mb.material_id = m.material_id
GROUP BY s.site_id, s.site_name, m.material_name;

-- Create view for site comparison
CREATE OR REPLACE VIEW site_comparison_view AS
SELECT 
    s.site_id,
    s.site_name,
    sm.built_up_area,
    sm.project_value,
    sm.total_cost,
    sm.profit_loss,
    COUNT(DISTINCT dsr.report_id) as total_reports,
    SUM(dls.labour_count) as total_labour_count,
    SUM(dse.total_salary) as total_salary_paid,
    SUM(mb.bill_amount) as total_material_cost
FROM sites s
LEFT JOIN site_metrics sm ON s.site_id = sm.site_id
LEFT JOIN daily_site_report dsr ON s.site_id = dsr.site_id
LEFT JOIN daily_labour_summary dls ON dsr.report_id = dls.report_id
LEFT JOIN daily_salary_entry dse ON dsr.report_id = dse.report_id
LEFT JOIN material_bills mb ON dsr.report_id = mb.report_id
GROUP BY s.site_id, s.site_name, sm.built_up_area, sm.project_value, sm.total_cost, sm.profit_loss;

COMMENT ON TABLE site_metrics IS 'Stores site-level metrics including built-up area, project value, and P/L';
COMMENT ON TABLE site_documents IS 'Stores site documents like plans, elevations, structure, and final output images';
COMMENT ON TABLE admin_access_log IS 'Tracks specialized admin logins (labour count, bills view, full accounts)';
COMMENT ON TABLE work_notifications IS 'Notifications for work not done sent to chief accountant/owner';
