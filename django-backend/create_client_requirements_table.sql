-- Create client_requirements table
CREATE TABLE IF NOT EXISTS client_requirements (
    requirement_id UUID PRIMARY KEY,
    site_id UUID NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    added_by UUID NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (site_id) REFERENCES sites(site_id) ON DELETE CASCADE,
    FOREIGN KEY (added_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_client_requirements_site ON client_requirements(site_id);
CREATE INDEX IF NOT EXISTS idx_client_requirements_date ON client_requirements(added_date DESC);

-- Insert sample data (optional)
-- INSERT INTO client_requirements (requirement_id, site_id, description, amount, added_by, added_date, status)
-- VALUES (
--     gen_random_uuid(),
--     (SELECT site_id FROM sites LIMIT 1),
--     'Additional electrical work required',
--     25000.00,
--     (SELECT user_id FROM users WHERE role_id = (SELECT role_id FROM roles WHERE role_name = 'Accountant') LIMIT 1),
--     NOW(),
--     'Pending'
-- );
