-- ============================================
-- MATERIAL INVENTORY MANAGEMENT SYSTEM
-- ============================================
-- This adds comprehensive material tracking with:
-- 1. Material stock/inventory per site
-- 2. Material usage tracking by supervisors
-- 3. Automatic balance calculation
-- ============================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS material_usage CASCADE;
DROP TABLE IF EXISTS material_stock CASCADE;

-- ============================================
-- 1. MATERIAL STOCK TABLE (Inventory)
-- ============================================
-- Tracks the total material available at each site
CREATE TABLE material_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    material_type VARCHAR(100) NOT NULL,
    total_quantity DECIMAL(10, 2) NOT NULL DEFAULT 0,
    unit VARCHAR(50) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT,
    UNIQUE(site_id, material_type)
);

-- Create indexes
CREATE INDEX idx_material_stock_site ON material_stock(site_id);
CREATE INDEX idx_material_stock_type ON material_stock(material_type);

-- ============================================
-- 2. MATERIAL USAGE TABLE (Consumption)
-- ============================================
-- Tracks material used by supervisors
CREATE TABLE material_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    material_type VARCHAR(100) NOT NULL,
    quantity_used DECIMAL(10, 2) NOT NULL CHECK (quantity_used > 0),
    unit VARCHAR(50) NOT NULL,
    usage_date DATE NOT NULL,
    usage_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_material_usage_site ON material_usage(site_id);
CREATE INDEX idx_material_usage_supervisor ON material_usage(supervisor_id);
CREATE INDEX idx_material_usage_date ON material_usage(usage_date);
CREATE INDEX idx_material_usage_type ON material_usage(material_type);

-- ============================================
-- 3. VIEW: MATERIAL BALANCE (Current Stock)
-- ============================================
-- Automatically calculates remaining balance
CREATE OR REPLACE VIEW material_balance_view AS
SELECT 
    ms.id as stock_id,
    ms.site_id,
    s.site_name,
    s.customer_name,
    ms.material_type,
    ms.total_quantity as initial_stock,
    COALESCE(SUM(mu.quantity_used), 0) as total_used,
    (ms.total_quantity - COALESCE(SUM(mu.quantity_used), 0)) as current_balance,
    ms.unit,
    ms.last_updated,
    CASE 
        WHEN (ms.total_quantity - COALESCE(SUM(mu.quantity_used), 0)) <= 0 THEN 'OUT_OF_STOCK'
        WHEN (ms.total_quantity - COALESCE(SUM(mu.quantity_used), 0)) < (ms.total_quantity * 0.2) THEN 'LOW_STOCK'
        ELSE 'IN_STOCK'
    END as stock_status
FROM material_stock ms
JOIN sites s ON ms.site_id = s.id
LEFT JOIN material_usage mu ON ms.site_id = mu.site_id AND ms.material_type = mu.material_type
GROUP BY ms.id, ms.site_id, s.site_name, s.customer_name, ms.material_type, ms.total_quantity, ms.unit, ms.last_updated;

-- ============================================
-- 4. FUNCTION: UPDATE MATERIAL STOCK
-- ============================================
-- Function to add or update material stock
CREATE OR REPLACE FUNCTION update_material_stock(
    p_site_id UUID,
    p_material_type VARCHAR,
    p_quantity DECIMAL,
    p_unit VARCHAR,
    p_updated_by UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_stock_id UUID;
BEGIN
    -- Insert or update material stock
    INSERT INTO material_stock (site_id, material_type, total_quantity, unit, updated_by, notes)
    VALUES (p_site_id, p_material_type, p_quantity, p_unit, p_updated_by, p_notes)
    ON CONFLICT (site_id, material_type)
    DO UPDATE SET
        total_quantity = material_stock.total_quantity + p_quantity,
        last_updated = CURRENT_TIMESTAMP,
        updated_by = p_updated_by,
        notes = COALESCE(p_notes, material_stock.notes)
    RETURNING id INTO v_stock_id;
    
    RETURN v_stock_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. FUNCTION: RECORD MATERIAL USAGE
-- ============================================
-- Function to record material usage by supervisor
CREATE OR REPLACE FUNCTION record_material_usage(
    p_site_id UUID,
    p_supervisor_id UUID,
    p_material_type VARCHAR,
    p_quantity_used DECIMAL,
    p_unit VARCHAR,
    p_usage_date DATE,
    p_notes TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_usage_id UUID;
    v_current_balance DECIMAL;
BEGIN
    -- Check if enough stock is available
    SELECT (ms.total_quantity - COALESCE(SUM(mu.quantity_used), 0))
    INTO v_current_balance
    FROM material_stock ms
    LEFT JOIN material_usage mu ON ms.site_id = mu.site_id AND ms.material_type = mu.material_type
    WHERE ms.site_id = p_site_id AND ms.material_type = p_material_type
    GROUP BY ms.total_quantity;
    
    -- If no stock record exists, raise error
    IF v_current_balance IS NULL THEN
        RAISE EXCEPTION 'No stock record found for material type: %', p_material_type;
    END IF;
    
    -- If insufficient stock, raise warning (but still allow)
    IF v_current_balance < p_quantity_used THEN
        RAISE WARNING 'Insufficient stock! Current balance: %, Requested: %', v_current_balance, p_quantity_used;
    END IF;
    
    -- Record the usage
    INSERT INTO material_usage (site_id, supervisor_id, material_type, quantity_used, unit, usage_date, notes)
    VALUES (p_site_id, p_supervisor_id, p_material_type, p_quantity_used, p_unit, p_usage_date, p_notes)
    RETURNING id INTO v_usage_id;
    
    RETURN v_usage_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. VIEW: MATERIAL USAGE HISTORY
-- ============================================
-- Shows all material usage with supervisor details
CREATE OR REPLACE VIEW material_usage_history AS
SELECT 
    mu.id,
    mu.site_id,
    s.site_name,
    s.customer_name,
    mu.supervisor_id,
    u.full_name as supervisor_name,
    mu.material_type,
    mu.quantity_used,
    mu.unit,
    mu.usage_date,
    mu.usage_time,
    mu.notes,
    mu.created_at
FROM material_usage mu
JOIN sites s ON mu.site_id = s.id
LEFT JOIN users u ON mu.supervisor_id = u.id
ORDER BY mu.usage_date DESC, mu.usage_time DESC;

-- ============================================
-- 7. VIEW: LOW STOCK ALERTS
-- ============================================
-- Shows materials that are running low
CREATE OR REPLACE VIEW low_stock_alerts AS
SELECT 
    site_id,
    site_name,
    customer_name,
    material_type,
    initial_stock,
    total_used,
    current_balance,
    unit,
    stock_status
FROM material_balance_view
WHERE stock_status IN ('LOW_STOCK', 'OUT_OF_STOCK')
ORDER BY 
    CASE stock_status
        WHEN 'OUT_OF_STOCK' THEN 1
        WHEN 'LOW_STOCK' THEN 2
    END,
    current_balance ASC;

-- ============================================
-- 8. SAMPLE DATA (for testing)
-- ============================================

-- Add sample material stock for testing
-- Note: Replace site_id and user_id with actual values from your database

-- Example: Add cement stock to a site
-- SELECT update_material_stock(
--     'your-site-id-here'::UUID,
--     'Cement',
--     100.00,
--     'Bags',
--     'your-user-id-here'::UUID,
--     'Initial stock'
-- );

-- Example: Record cement usage
-- SELECT record_material_usage(
--     'your-site-id-here'::UUID,
--     'your-supervisor-id-here'::UUID,
--     'Cement',
--     10.00,
--     'Bags',
--     CURRENT_DATE,
--     'Used for foundation work'
-- );

-- ============================================
-- COMMENTS AND DOCUMENTATION
-- ============================================

COMMENT ON TABLE material_stock IS 'Stores total material inventory available at each site';
COMMENT ON TABLE material_usage IS 'Tracks material consumption by supervisors';
COMMENT ON VIEW material_balance_view IS 'Shows current material balance (stock - usage) for each site';
COMMENT ON VIEW material_usage_history IS 'Complete history of material usage with supervisor details';
COMMENT ON VIEW low_stock_alerts IS 'Alerts for materials running low or out of stock';

COMMENT ON FUNCTION update_material_stock IS 'Adds or updates material stock for a site';
COMMENT ON FUNCTION record_material_usage IS 'Records material usage by supervisor and validates stock availability';

-- ============================================
-- END OF MATERIAL INVENTORY SYSTEM
-- ============================================
