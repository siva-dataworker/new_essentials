-- ============================================
-- COMPREHENSIVE BUDGET MANAGEMENT SYSTEM
-- ============================================

-- 1. SITE BUDGET ALLOCATION TABLE
CREATE TABLE IF NOT EXISTS site_budget_allocation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    allocated_by UUID NOT NULL REFERENCES users(id),
    
    -- Budget Details
    total_budget DECIMAL(15,2) NOT NULL,
    material_budget DECIMAL(15,2),
    labour_budget DECIMAL(15,2),
    other_budget DECIMAL(15,2),
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, EXCEEDED, COMPLETED
    notes TEXT,
    
    -- Timestamps
    allocated_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one active budget per site
    UNIQUE(site_id, status)
);

-- 2. LABOUR SALARY RATES TABLE
CREATE TABLE IF NOT EXISTS labour_salary_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    
    -- Labour Type and Rate
    labour_type VARCHAR(50) NOT NULL, -- General, Skilled, Mason, Carpenter, etc.
    daily_rate DECIMAL(10,2) NOT NULL,
    
    -- Effective Period
    effective_from DATE NOT NULL DEFAULT CURRENT_DATE,
    effective_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    set_by UUID NOT NULL REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one active rate per labour type per site
    UNIQUE(site_id, labour_type, is_active)
);

-- 3. MATERIAL COST TRACKING TABLE
CREATE TABLE IF NOT EXISTS material_cost_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    bill_id UUID REFERENCES material_bills(id) ON DELETE CASCADE,
    
    -- Material Details
    material_type VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(12,2) NOT NULL,
    
    -- Tracking
    recorded_by UUID NOT NULL REFERENCES users(id),
    recorded_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. LABOUR COST CALCULATION TABLE (Auto-calculated)
CREATE TABLE IF NOT EXISTS labour_cost_calculation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    labour_entry_id UUID NOT NULL REFERENCES labour_entries(id) ON DELETE CASCADE,
    
    -- Labour Details
    labour_type VARCHAR(50) NOT NULL,
    labour_count INTEGER NOT NULL,
    daily_rate DECIMAL(10,2) NOT NULL,
    
    -- Calculated Cost
    total_cost DECIMAL(12,2) NOT NULL, -- labour_count * daily_rate
    
    -- Entry Details
    entry_date DATE NOT NULL,
    day_of_week VARCHAR(20),
    
    -- Calculation Metadata
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one calculation per labour entry
    UNIQUE(labour_entry_id)
);

-- 5. BUDGET UTILIZATION SUMMARY VIEW
CREATE OR REPLACE VIEW budget_utilization_summary AS
SELECT 
    sba.site_id,
    s.site_name,
    s.customer_name,
    
    -- Budget Allocation
    sba.total_budget,
    sba.material_budget,
    sba.labour_budget,
    sba.other_budget,
    
    -- Material Costs
    COALESCE(SUM(mct.total_cost), 0) as total_material_cost,
    
    -- Labour Costs
    COALESCE(SUM(lcc.total_cost), 0) as total_labour_cost,
    
    -- Vendor Bills (Other Costs)
    COALESCE(SUM(vb.final_amount), 0) as total_vendor_cost,
    
    -- Total Spent
    COALESCE(SUM(mct.total_cost), 0) + 
    COALESCE(SUM(lcc.total_cost), 0) + 
    COALESCE(SUM(vb.final_amount), 0) as total_spent,
    
    -- Remaining Budget
    sba.total_budget - (
        COALESCE(SUM(mct.total_cost), 0) + 
        COALESCE(SUM(lcc.total_cost), 0) + 
        COALESCE(SUM(vb.final_amount), 0)
    ) as remaining_budget,
    
    -- Utilization Percentage
    CASE 
        WHEN sba.total_budget > 0 THEN
            ((COALESCE(SUM(mct.total_cost), 0) + 
              COALESCE(SUM(lcc.total_cost), 0) + 
              COALESCE(SUM(vb.final_amount), 0)) / sba.total_budget) * 100
        ELSE 0
    END as utilization_percentage,
    
    -- Status
    sba.status,
    sba.allocated_date
    
FROM site_budget_allocation sba
JOIN sites s ON sba.site_id = s.id
LEFT JOIN material_cost_tracking mct ON sba.site_id = mct.site_id
LEFT JOIN labour_cost_calculation lcc ON sba.site_id = lcc.site_id
LEFT JOIN vendor_bills vb ON sba.site_id = vb.site_id AND vb.is_active = TRUE
WHERE sba.status = 'ACTIVE'
GROUP BY 
    sba.site_id, s.site_name, s.customer_name,
    sba.total_budget, sba.material_budget, sba.labour_budget, sba.other_budget,
    sba.status, sba.allocated_date;

-- 6. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_site_budget_site ON site_budget_allocation(site_id);
CREATE INDEX IF NOT EXISTS idx_labour_rates_site ON labour_salary_rates(site_id, is_active);
CREATE INDEX IF NOT EXISTS idx_material_cost_site ON material_cost_tracking(site_id);
CREATE INDEX IF NOT EXISTS idx_labour_cost_site ON labour_cost_calculation(site_id);
CREATE INDEX IF NOT EXISTS idx_labour_cost_entry ON labour_cost_calculation(labour_entry_id);

-- 7. TRIGGER TO AUTO-CALCULATE LABOUR COSTS
CREATE OR REPLACE FUNCTION calculate_labour_cost()
RETURNS TRIGGER AS $$
DECLARE
    v_daily_rate DECIMAL(10,2);
    v_total_cost DECIMAL(12,2);
BEGIN
    -- Get the daily rate for this labour type at this site
    SELECT daily_rate INTO v_daily_rate
    FROM labour_salary_rates
    WHERE site_id = NEW.site_id
      AND labour_type = NEW.labour_type
      AND is_active = TRUE
    LIMIT 1;
    
    -- If no rate found, use default rate of 500
    IF v_daily_rate IS NULL THEN
        v_daily_rate := 500.00;
    END IF;
    
    -- Calculate total cost
    v_total_cost := NEW.labour_count * v_daily_rate;
    
    -- Insert or update labour cost calculation
    INSERT INTO labour_cost_calculation (
        site_id,
        labour_entry_id,
        labour_type,
        labour_count,
        daily_rate,
        total_cost,
        entry_date,
        day_of_week
    ) VALUES (
        NEW.site_id,
        NEW.id,
        NEW.labour_type,
        NEW.labour_count,
        v_daily_rate,
        v_total_cost,
        NEW.entry_date,
        NEW.day_of_week
    )
    ON CONFLICT (labour_entry_id) 
    DO UPDATE SET
        labour_count = EXCLUDED.labour_count,
        daily_rate = EXCLUDED.daily_rate,
        total_cost = EXCLUDED.total_cost,
        updated_at = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_calculate_labour_cost ON labour_entries;
CREATE TRIGGER trigger_calculate_labour_cost
    AFTER INSERT OR UPDATE ON labour_entries
    FOR EACH ROW
    EXECUTE FUNCTION calculate_labour_cost();

-- 8. FUNCTION TO UPDATE BUDGET STATUS
CREATE OR REPLACE FUNCTION update_budget_status()
RETURNS TRIGGER AS $$
DECLARE
    v_total_spent DECIMAL(15,2);
    v_total_budget DECIMAL(15,2);
BEGIN
    -- Calculate total spent for this site
    SELECT 
        COALESCE(SUM(mct.total_cost), 0) + 
        COALESCE(SUM(lcc.total_cost), 0) + 
        COALESCE(SUM(vb.final_amount), 0)
    INTO v_total_spent
    FROM site_budget_allocation sba
    LEFT JOIN material_cost_tracking mct ON sba.site_id = mct.site_id
    LEFT JOIN labour_cost_calculation lcc ON sba.site_id = lcc.site_id
    LEFT JOIN vendor_bills vb ON sba.site_id = vb.site_id AND vb.is_active = TRUE
    WHERE sba.site_id = NEW.site_id
      AND sba.status = 'ACTIVE';
    
    -- Get total budget
    SELECT total_budget INTO v_total_budget
    FROM site_budget_allocation
    WHERE site_id = NEW.site_id
      AND status = 'ACTIVE';
    
    -- Update status if budget exceeded
    IF v_total_spent > v_total_budget THEN
        UPDATE site_budget_allocation
        SET status = 'EXCEEDED',
            updated_at = CURRENT_TIMESTAMP
        WHERE site_id = NEW.site_id
          AND status = 'ACTIVE';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for budget status update
DROP TRIGGER IF EXISTS trigger_update_budget_material ON material_cost_tracking;
CREATE TRIGGER trigger_update_budget_material
    AFTER INSERT OR UPDATE ON material_cost_tracking
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_status();

DROP TRIGGER IF EXISTS trigger_update_budget_labour ON labour_cost_calculation;
CREATE TRIGGER trigger_update_budget_labour
    AFTER INSERT OR UPDATE ON labour_cost_calculation
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_status();

COMMIT;

-- Success message
SELECT 'Budget Management System Created Successfully!' as message;
