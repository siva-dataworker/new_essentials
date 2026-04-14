-- Migrate existing material_balances data to material_usage table
-- This fixes the issue where material usage was being saved to the wrong table

-- Insert data from material_balances into material_usage
INSERT INTO material_usage (
    id,
    site_id,
    supervisor_id,
    material_type,
    quantity_used,
    unit,
    usage_date,
    notes,
    created_at
)
SELECT 
    id,
    site_id,
    supervisor_id,
    material_type,
    quantity,  -- material_balances uses 'quantity', material_usage uses 'quantity_used'
    unit,
    entry_date,  -- material_balances uses 'entry_date', material_usage uses 'usage_date'
    extra_cost_notes,  -- Use extra_cost_notes as notes
    updated_at  -- material_balances uses 'updated_at', material_usage uses 'created_at'
FROM material_balances
WHERE NOT EXISTS (
    -- Avoid duplicates if this script is run multiple times
    SELECT 1 FROM material_usage mu 
    WHERE mu.id = material_balances.id
);

-- Verify the migration
SELECT 
    'material_usage' as table_name,
    COUNT(*) as record_count,
    SUM(quantity_used) as total_quantity
FROM material_usage
UNION ALL
SELECT 
    'material_balances' as table_name,
    COUNT(*) as record_count,
    SUM(quantity) as total_quantity
FROM material_balances;

-- Check the material_balance_view to see if total_used is now correct
SELECT * FROM material_balance_view ORDER BY material_type;
