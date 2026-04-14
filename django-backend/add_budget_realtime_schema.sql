-- ============================================
-- Admin Site Management with Real-time Visibility
-- Database Schema Migration
-- ============================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. Site Budgets Table
-- ============================================
CREATE TABLE IF NOT EXISTS site_budgets (
    budget_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    allocated_amount DECIMAL(15, 2) NOT NULL CHECK (allocated_amount > 0),
    utilized_amount DECIMAL(15, 2) DEFAULT 0 CHECK (utilized_amount >= 0),
    remaining_amount DECIMAL(15, 2) NOT NULL,
    allocated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT check_remaining CHECK (remaining_amount = allocated_amount - utilized_amount),
    CONSTRAINT check_utilization CHECK (utilized_amount <= allocated_amount)
);

-- Indexes for site_budgets
CREATE INDEX IF NOT EXISTS idx_site_budgets_site_active 
    ON site_budgets(site_id, is_active);
CREATE INDEX IF NOT EXISTS idx_site_budgets_allocated_at 
    ON site_budgets(allocated_at DESC);

-- Comment on table
COMMENT ON TABLE site_budgets IS 'Budget allocations for construction sites';

-- ============================================
-- 2. Real-time Updates Table
-- ============================================
CREATE TABLE IF NOT EXISTS realtime_updates (
    update_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    update_type VARCHAR(50) NOT NULL CHECK (update_type IN ('LABOUR_ENTRY', 'LABOUR_CORRECTION', 'BILL_UPLOAD', 'BUDGET_UPDATE')),
    record_type VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('CREATE', 'UPDATE', 'DELETE')),
    changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    notify_roles JSONB NOT NULL,
    is_processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for realtime_updates
CREATE INDEX IF NOT EXISTS idx_realtime_updates_site_processed 
    ON realtime_updates(site_id, is_processed, created_at);
CREATE INDEX IF NOT EXISTS idx_realtime_updates_type 
    ON realtime_updates(update_type, created_at);
CREATE INDEX IF NOT EXISTS idx_realtime_updates_created 
    ON realtime_updates(created_at DESC);

-- Comment on table
COMMENT ON TABLE realtime_updates IS 'Real-time update notifications for admin and accountant roles';

-- ============================================
-- 3. Modify labour_entries table (if exists)
-- ============================================
-- Add columns for tracking corrections
DO $$ 
BEGIN
    -- Check if labour_entries table exists and add columns
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'labour_entries') THEN
        -- Add is_modified column
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'labour_entries' AND column_name = 'is_modified') THEN
            ALTER TABLE labour_entries ADD COLUMN is_modified BOOLEAN DEFAULT FALSE;
        END IF;
        
        -- Add modified_by column
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'labour_entries' AND column_name = 'modified_by') THEN
            ALTER TABLE labour_entries ADD COLUMN modified_by UUID REFERENCES users(id) ON DELETE SET NULL;
        END IF;
        
        -- Add modified_at column
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'labour_entries' AND column_name = 'modified_at') THEN
            ALTER TABLE labour_entries ADD COLUMN modified_at TIMESTAMP;
        END IF;
        
        -- Add modification_reason column
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name = 'labour_entries' AND column_name = 'modification_reason') THEN
            ALTER TABLE labour_entries ADD COLUMN modification_reason TEXT;
        END IF;
        
        -- Create index
        CREATE INDEX IF NOT EXISTS idx_labour_entries_modified 
            ON labour_entries(is_modified, modified_at);
    END IF;
END $$;

-- ============================================
-- 4. Enhanced Audit Logs Table
-- ============================================
-- Create new enhanced audit logs table
CREATE TABLE IF NOT EXISTS audit_logs_enhanced (
    audit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    change_type VARCHAR(20) DEFAULT 'UPDATE' CHECK (change_type IN ('CREATE', 'UPDATE', 'DELETE')),
    changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    changed_by_role VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

-- Indexes for audit_logs_enhanced
CREATE INDEX IF NOT EXISTS idx_audit_logs_site 
    ON audit_logs_enhanced(site_id, changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record 
    ON audit_logs_enhanced(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_changed_by 
    ON audit_logs_enhanced(changed_by, changed_at DESC);

-- Comment on table
COMMENT ON TABLE audit_logs_enhanced IS 'Enhanced audit trail for all data modifications';

-- ============================================
-- 5. Trigger Functions for Automatic Updates
-- ============================================

-- Function to update budget utilization
CREATE OR REPLACE FUNCTION update_budget_utilization()
RETURNS TRIGGER AS $$
BEGIN
    -- This will be implemented when we integrate with cost tracking
    -- For now, it's a placeholder
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to create real-time update notification
CREATE OR REPLACE FUNCTION create_realtime_update()
RETURNS TRIGGER AS $$
DECLARE
    v_site_id INTEGER;
    v_update_type VARCHAR(50);
    v_notify_roles JSONB;
BEGIN
    -- Determine update type and notify roles based on table
    IF TG_TABLE_NAME = 'daily_labour_summary' THEN
        v_site_id := (SELECT site_id FROM daily_site_report WHERE report_id = NEW.report_id);
        
        IF NEW.is_modified = TRUE THEN
            v_update_type := 'LABOUR_CORRECTION';
            v_notify_roles := '["Admin"]'::jsonb;
        ELSE
            v_update_type := 'LABOUR_ENTRY';
            v_notify_roles := '["Admin", "Accountant"]'::jsonb;
        END IF;
        
        INSERT INTO realtime_updates (
            site_id, update_type, record_type, record_id, action, 
            changed_by, notify_roles
        ) VALUES (
            v_site_id, v_update_type, TG_TABLE_NAME, 
            NEW.labour_summary_id::text::uuid, TG_OP, 
            NEW.entered_by, v_notify_roles
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. Create Triggers
-- ============================================

-- Trigger for labour summary changes (commented out - table doesn't exist yet)
-- DROP TRIGGER IF EXISTS trigger_labour_summary_realtime ON daily_labour_summary;
-- CREATE TRIGGER trigger_labour_summary_realtime
--     AFTER INSERT OR UPDATE ON daily_labour_summary
--     FOR EACH ROW
--     EXECUTE FUNCTION create_realtime_update();

-- ============================================
-- 7. Grant Permissions
-- ============================================
-- Grant necessary permissions to the application user
-- Adjust the username based on your setup

-- GRANT ALL PRIVILEGES ON TABLE site_budgets TO your_app_user;
-- GRANT ALL PRIVILEGES ON TABLE realtime_updates TO your_app_user;
-- GRANT ALL PRIVILEGES ON TABLE audit_logs_enhanced TO your_app_user;

-- ============================================
-- 8. Sample Data (Optional - for testing)
-- ============================================

-- Insert sample budget for testing (uncomment if needed)
-- INSERT INTO site_budgets (site_id, allocated_amount, utilized_amount, remaining_amount, allocated_by, is_active)
-- SELECT 
--     site_id, 
--     5000000.00, 
--     0, 
--     5000000.00, 
--     (SELECT user_id FROM users WHERE role_id = (SELECT role_id FROM roles WHERE role_name = 'Admin') LIMIT 1),
--     TRUE
-- FROM sites LIMIT 1;

-- ============================================
-- Migration Complete
-- ============================================

-- Verify tables were created
DO $$
BEGIN
    RAISE NOTICE 'Checking created tables...';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'site_budgets') THEN
        RAISE NOTICE '✓ site_budgets table created';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'realtime_updates') THEN
        RAISE NOTICE '✓ realtime_updates table created';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs_enhanced') THEN
        RAISE NOTICE '✓ audit_logs_enhanced table created';
    END IF;
    
    RAISE NOTICE 'Migration completed successfully!';
END $$;
