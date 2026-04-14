-- Quick Insert - Run this in Supabase SQL Editor
-- https://app.supabase.com/project/ctwthgjuccioxivnzifb/sql

-- 1. Insert Roles
INSERT INTO roles (role_name) VALUES
('Admin'),
('Supervisor'),
('Site Engineer'),
('Junior Accountant')
ON CONFLICT (role_name) DO NOTHING;

-- 2. Insert Users
INSERT INTO users (full_name, email, phone, role_id, is_active) VALUES
('John Admin', 'admin@test.com', '+1111111111', 1, true),
('Mike Supervisor', 'supervisor@test.com', '+2222222222', 2, true),
('Sarah Engineer', 'engineer@test.com', '+3333333333', 3, true)
ON CONFLICT (email) DO NOTHING;

-- 3. Insert Sites
INSERT INTO sites (site_name, location) VALUES
('Downtown Tower', '123 Main Street'),
('Riverside Apartments', '456 River Road'),
('Hillside Villas', '789 Hill Avenue');

-- Check what was inserted
SELECT * FROM roles;
SELECT * FROM users;
SELECT * FROM sites;
