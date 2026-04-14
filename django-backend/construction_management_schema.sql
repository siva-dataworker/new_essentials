-- ============================================
-- CONSTRUCTION MANAGEMENT SYSTEM - DATABASE SCHEMA
-- ============================================
-- Stack: Django + Supabase PostgreSQL
-- Auth: Custom form-based (NO Firebase)
-- ============================================

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS extra_works CASCADE;
DROP TABLE IF EXISTS bills CASCADE;
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS work_updates CASCADE;
DROP TABLE IF EXISTS material_balances CASCADE;
DROP TABLE IF EXISTS labour_entries CASCADE;
DROP TABLE IF EXISTS sites CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- ============================================
-- 1. ROLES TABLE
-- ============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert predefined roles
INSERT INTO roles (role_name) VALUES 
    ('Admin'),
    ('Supervisor'),
    ('Site Engineer'),
    ('Accountant'),
    ('Architect'),
    ('Owner');

-- ============================================
-- 2. USERS TABLE
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role_id INTEGER REFERENCES roles(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create indexes for faster queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_role ON users(role_id);

-- ============================================
-- 3. SITES TABLE
-- ============================================
CREATE TABLE sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    area VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    site_name VARCHAR(255) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    site_code VARCHAR(50) UNIQUE,
    project_value DECIMAL(15, 2),
    start_date DATE,
    estimated_completion DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'ON_HOLD')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Create indexes
CREATE INDEX idx_sites_area ON sites(area);
CREATE INDEX idx_sites_street ON sites(street);
CREATE INDEX idx_sites_status ON sites(status);

-- ============================================
-- 4. LABOUR ENTRIES TABLE
-- ============================================
CREATE TABLE labour_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    labour_count INTEGER NOT NULL CHECK (labour_count >= 0),
    labour_type VARCHAR(100),
    entry_date DATE NOT NULL,
    entry_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_modified BOOLEAN DEFAULT FALSE,
    modified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    modified_at TIMESTAMP,
    modification_reason TEXT,
    notes TEXT
);

-- Create indexes
CREATE INDEX idx_labour_site ON labour_entries(site_id);
CREATE INDEX idx_labour_date ON labour_entries(entry_date);
CREATE INDEX idx_labour_supervisor ON labour_entries(supervisor_id);

-- ============================================
-- 5. MATERIAL BALANCES TABLE
-- ============================================
CREATE TABLE material_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    material_type VARCHAR(100) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50),
    entry_date DATE NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Create indexes
CREATE INDEX idx_material_site ON material_balances(site_id);
CREATE INDEX idx_material_date ON material_balances(entry_date);
CREATE INDEX idx_material_type ON material_balances(material_type);

-- ============================================
-- 6. WORK UPDATES TABLE
-- ============================================
CREATE TABLE work_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    engineer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    update_type VARCHAR(50) NOT NULL CHECK (update_type IN ('STARTED', 'FINISHED', 'RECTIFIED', 'PROGRESS')),
    image_url TEXT,
    description TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date DATE NOT NULL,
    visible_to_client BOOLEAN DEFAULT FALSE
);

-- Create indexes
CREATE INDEX idx_work_site ON work_updates(site_id);
CREATE INDEX idx_work_date ON work_updates(update_date);
CREATE INDEX idx_work_type ON work_updates(update_type);

-- ============================================
-- 7. COMPLAINTS TABLE
-- ============================================
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    raised_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    priority VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    proof_image_url TEXT
);

-- Create indexes
CREATE INDEX idx_complaints_site ON complaints(site_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_assigned ON complaints(assigned_to);

-- ============================================
-- 8. BILLS TABLE
-- ============================================
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    material_type VARCHAR(100) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50),
    price_per_unit DECIMAL(10, 2),
    total_amount DECIMAL(15, 2) NOT NULL,
    bill_number VARCHAR(100),
    bill_url TEXT,
    vendor_name VARCHAR(255),
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bill_date DATE NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'UNPAID' CHECK (payment_status IN ('UNPAID', 'PARTIAL', 'PAID')),
    notes TEXT
);

-- Create indexes
CREATE INDEX idx_bills_site ON bills(site_id);
CREATE INDEX idx_bills_date ON bills(bill_date);
CREATE INDEX idx_bills_material ON bills(material_type);
CREATE INDEX idx_bills_payment ON bills(payment_status);

-- ============================================
-- 9. EXTRA WORKS TABLE
-- ============================================
CREATE TABLE extra_works (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    bill_url TEXT,
    payment_status VARCHAR(20) DEFAULT 'UNPAID' CHECK (payment_status IN ('UNPAID', 'PARTIAL', 'PAID')),
    due_date DATE,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_amount DECIMAL(15, 2) DEFAULT 0,
    payment_date DATE,
    notes TEXT
);

-- Create indexes
CREATE INDEX idx_extra_site ON extra_works(site_id);
CREATE INDEX idx_extra_payment ON extra_works(payment_status);
CREATE INDEX idx_extra_due ON extra_works(due_date);

-- ============================================
-- 10. AUDIT LOGS TABLE
-- ============================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id UUID,
    performed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_audit_user ON audit_logs(performed_by);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_action ON audit_logs(action);

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View: Site Summary
CREATE OR REPLACE VIEW site_summary AS
SELECT 
    s.id,
    s.site_name,
    s.customer_name,
    s.area,
    s.street,
    s.project_value,
    COUNT(DISTINCT le.id) as total_labour_entries,
    SUM(le.labour_count) as total_labour_count,
    COUNT(DISTINCT b.id) as total_bills,
    SUM(b.total_amount) as total_material_cost,
    COUNT(DISTINCT ew.id) as total_extra_works,
    SUM(ew.amount) as total_extra_work_amount
FROM sites s
LEFT JOIN labour_entries le ON s.id = le.site_id
LEFT JOIN bills b ON s.id = b.site_id
LEFT JOIN extra_works ew ON s.id = ew.site_id
GROUP BY s.id;

-- View: Pending Approvals
CREATE OR REPLACE VIEW pending_approvals AS
SELECT 
    u.id,
    u.username,
    u.email,
    u.phone,
    u.full_name,
    r.role_name,
    u.created_at
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.status = 'PENDING'
ORDER BY u.created_at;

-- ============================================
-- FUNCTIONS FOR NOTIFICATIONS
-- ============================================

-- Function: Check overdue labour entries
CREATE OR REPLACE FUNCTION check_overdue_labour_entries()
RETURNS TABLE(site_id UUID, site_name VARCHAR, supervisor_name VARCHAR, days_overdue INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.site_name,
        u.full_name,
        (CURRENT_DATE - MAX(le.entry_date))::INTEGER as days_overdue
    FROM sites s
    LEFT JOIN labour_entries le ON s.id = le.site_id
    LEFT JOIN users u ON s.created_by = u.id
    WHERE s.status = 'ACTIVE'
    GROUP BY s.id, s.site_name, u.full_name
    HAVING MAX(le.entry_date) < CURRENT_DATE OR MAX(le.entry_date) IS NULL;
END;
$$ LANGUAGE plpgsql;

-- Function: Check overdue bills
CREATE OR REPLACE FUNCTION check_overdue_bills()
RETURNS TABLE(id UUID, site_name VARCHAR, amount DECIMAL, days_overdue INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ew.id,
        s.site_name,
        ew.amount,
        (CURRENT_DATE - ew.due_date)::INTEGER as days_overdue
    FROM extra_works ew
    JOIN sites s ON ew.site_id = s.id
    WHERE ew.payment_status != 'PAID'
    AND ew.due_date < CURRENT_DATE
    ORDER BY days_overdue DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Create admin user (password: admin123 - hashed with bcrypt)
-- Note: You'll need to hash this properly in your application
INSERT INTO users (username, email, phone, password_hash, full_name, role_id, status, approved_at)
VALUES ('admin', 'admin@essentialhomes.com', '9999999999', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIxF6q0OXm', 'System Admin', 1, 'APPROVED', CURRENT_TIMESTAMP);

-- Sample areas and streets (you can add more)
-- These will be used in dropdowns

-- ============================================
-- GRANTS (Adjust based on your setup)
-- ============================================
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_db_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_db_user;

-- ============================================
-- END OF SCHEMA
-- ============================================
