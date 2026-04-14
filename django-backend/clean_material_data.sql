-- Clean Material Inventory Data
-- Run this to remove all existing material data and start fresh

-- 1. Delete all material usage records
DELETE FROM material_usage;

-- 2. Delete all material stock records
DELETE FROM material_stock;

-- 3. Verify tables are empty
SELECT COUNT(*) as material_stock_count FROM material_stock;
SELECT COUNT(*) as material_usage_count FROM material_usage;

-- 4. Check material balance view (should be empty)
SELECT * FROM material_balance_view;

-- Now you can start fresh:
-- 1. Site Engineer adds only Sand
-- 2. Supervisor will see only Sand in dropdown
