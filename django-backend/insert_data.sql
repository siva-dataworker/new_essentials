-- =========================================
-- ESSENTIAL HOMES - INSERT SAMPLE DATA
-- Run this in Supabase SQL Editor
-- =========================================

-- 1. INSERT ROLES
INSERT INTO roles (role_name) VALUES
('Admin'),
('Supervisor'),
('Site Engineer'),
('Junior Accountant')
ON CONFLICT (role_name) DO NOTHING;

-- 2. INSERT SAMPLE USERS
INSERT INTO users (full_name, email, phone, role_id, is_active) VALUES
('John Admin', 'admin@essentialhomes.com', '+1234567890', 1, true),
('Mike Supervisor', 'supervisor@essentialhomes.com', '+1234567891', 2, true),
('Sarah Engineer', 'engineer@essentialhomes.com', '+1234567892', 3, true),
('Tom Accountant', 'accountant@essentialhomes.com', '+1234567893', 4, true)
ON CONFLICT (email) DO NOTHING;

-- 3. INSERT SAMPLE SITES
INSERT INTO sites (site_name, location) VALUES
('Downtown Tower', '123 Main Street, Downtown'),
('Riverside Apartments', '456 River Road, Riverside'),
('Hillside Villas', '789 Hill Avenue, Hillside')
ON CONFLICT DO NOTHING;

-- 4. INSERT SAMPLE MATERIALS
INSERT INTO material_master (material_name, created_by) VALUES
('Cement', 1),
('Steel Rods', 1),
('Bricks', 1),
('Sand', 1),
('Gravel', 1)
ON CONFLICT (material_name) DO NOTHING;

-- 5. INSERT SAMPLE DAILY SITE REPORTS
INSERT INTO daily_site_report (site_id, report_date, status) VALUES
(1, CURRENT_DATE, 'OPEN'),
(2, CURRENT_DATE, 'OPEN'),
(3, CURRENT_DATE - INTERVAL '1 day', 'CLOSED')
ON CONFLICT (site_id, report_date) DO NOTHING;

-- 6. INSERT SAMPLE LABOUR SUMMARY
INSERT INTO daily_labour_summary (report_id, labour_count, locked, entered_by) VALUES
(1, 25, true, 2),
(2, 18, true, 2);

-- 7. INSERT SAMPLE SALARY ENTRIES
INSERT INTO daily_salary_entry (report_id, total_salary, entered_by, verified) VALUES
(1, 12500.00, 2, false),
(2, 9000.00, 2, false);

-- 8. INSERT SAMPLE MATERIAL BALANCE
INSERT INTO daily_material_balance (report_id, material_id, remaining_quantity) VALUES
(1, 1, 50.5),
(1, 2, 120.0),
(2, 1, 35.0),
(2, 3, 5000.0)
ON CONFLICT (report_id, material_id) DO NOTHING;

-- 9. INSERT SAMPLE MATERIAL BILLS
INSERT INTO material_bills (report_id, material_id, bill_amount, uploaded_by, verified) VALUES
(1, 1, 5000.00, 2, false),
(1, 2, 8000.00, 2, false);

-- 10. INSERT SAMPLE WORK ACTIVITIES
INSERT INTO work_activity (report_id, activity_type, image_path, uploaded_by) VALUES
(1, 'WORK_STARTED', '/images/site1_start.jpg', 3),
(2, 'WORK_STARTED', '/images/site2_start.jpg', 3);

-- 11. INSERT SAMPLE NOTIFICATIONS
INSERT INTO notifications (user_id, message, sent_via, status) VALUES
(2, 'Daily report for Downtown Tower is pending', 'APP', 'SENT'),
(3, 'Please upload work completion photos', 'WHATSAPP', 'SENT');

-- 12. INSERT SAMPLE COMPLAINTS
INSERT INTO complaints (site_id, report_id, description, status) VALUES
(1, 1, 'Material delivery delayed', 'OPEN'),
(2, 2, 'Equipment malfunction', 'OPEN');

-- Verify data inserted
SELECT 'Roles:', COUNT(*) FROM roles;
SELECT 'Users:', COUNT(*) FROM users;
SELECT 'Sites:', COUNT(*) FROM sites;
SELECT 'Materials:', COUNT(*) FROM material_master;
SELECT 'Daily Reports:', COUNT(*) FROM daily_site_report;
