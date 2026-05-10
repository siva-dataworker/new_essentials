-- Update budget_utilization_summary view to read from cash_entries table
-- This ensures budget utilization shows only accountant-confirmed entries

DROP VIEW IF EXISTS budget_utilization_summary CASCADE;

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
    
    -- Labour Costs (NOW FROM cash_entries - accountant-confirmed entries)
    COALESCE(SUM(ce.total_cost), 0) as total_labour_cost,
    
    -- Vendor Bills (Other Costs)
    COALESCE(SUM(vb.final_amount), 0) as total_vendor_cost,
    
    -- Total Spent
    COALESCE(SUM(mct.total_cost), 0) + 
    COALESCE(SUM(ce.total_cost), 0) + 
    COALESCE(SUM(vb.final_amount), 0) as total_spent,
    
    -- Remaining Budget
    sba.total_budget - (
        COALESCE(SUM(mct.total_cost), 0) + 
        COALESCE(SUM(ce.total_cost), 0) + 
        COALESCE(SUM(vb.final_amount), 0)
    ) as remaining_budget,
    
    -- Utilization Percentage
    CASE 
        WHEN sba.total_budget > 0 THEN
            ((COALESCE(SUM(mct.total_cost), 0) + 
              COALESCE(SUM(ce.total_cost), 0) + 
              COALESCE(SUM(vb.final_amount), 0)) / sba.total_budget) * 100
        ELSE 0
    END as utilization_percentage,
    
    -- Status
    sba.status,
    sba.allocated_date
    
FROM site_budget_allocation sba
JOIN sites s ON sba.site_id = s.id
LEFT JOIN material_cost_tracking mct ON sba.site_id = mct.site_id
LEFT JOIN cash_entries ce ON sba.site_id = ce.site_id  -- CHANGED: Now reads from cash_entries
LEFT JOIN vendor_bills vb ON sba.site_id = vb.site_id AND vb.is_active = TRUE

WHERE sba.status = 'ACTIVE'
GROUP BY 
    sba.site_id, 
    s.site_name, 
    s.customer_name,
    sba.total_budget,
    sba.material_budget,
    sba.labour_budget,
    sba.other_budget,
    sba.status,
    sba.allocated_date;

-- Add comment
COMMENT ON VIEW budget_utilization_summary IS 'Budget utilization summary - NOW READS FROM cash_entries (accountant-confirmed entries) instead of labour_cost_calculation';
