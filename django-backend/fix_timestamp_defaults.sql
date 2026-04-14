-- Ensure timestamp columns have proper defaults for IST timezone
-- PostgreSQL will use the server timezone (which we set to Asia/Kolkata in Django settings)

-- Fix labour_entries table
ALTER TABLE labour_entries 
ALTER COLUMN entry_time SET DEFAULT CURRENT_TIMESTAMP;

-- Fix material_balances table  
ALTER TABLE material_balances 
ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

-- Verify the changes
SELECT 
    table_name,
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns 
WHERE table_name IN ('labour_entries', 'material_balances')
    AND column_name IN ('entry_time', 'updated_at', 'entry_date')
ORDER BY table_name, column_name;
