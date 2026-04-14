-- Add test material usage data for client testing
-- This script adds sample material usage for the test site

-- First, get the site_id for "Test Construction Site"
DO $$
DECLARE
    v_site_id UUID;
    v_supervisor_id UUID;
BEGIN
    -- Get the site ID
    SELECT id INTO v_site_id 
    FROM sites 
    WHERE site_name = 'Test Construction Site' 
    LIMIT 1;
    
    -- Get a supervisor ID (any supervisor will do)
    SELECT id INTO v_supervisor_id 
    FROM users 
    WHERE role_id = 2 
    LIMIT 1;
    
    IF v_site_id IS NOT NULL AND v_supervisor_id IS NOT NULL THEN
        -- Delete existing test materials for this site
        DELETE FROM material_usage WHERE site_id = v_site_id;
        
        -- Insert test material usage data
        INSERT INTO material_usage (id, site_id, material_type, quantity_used, unit, usage_date, uploaded_by, notes, created_at)
        VALUES
            (gen_random_uuid(), v_site_id, 'Cement', 50.0, 'bags', CURRENT_DATE - INTERVAL '5 days', v_supervisor_id, 'Foundation work', NOW()),
            (gen_random_uuid(), v_site_id, 'Cement', 30.0, 'bags', CURRENT_DATE - INTERVAL '3 days', v_supervisor_id, 'Column work', NOW()),
            (gen_random_uuid(), v_site_id, 'Sand', 100.0, 'cubic feet', CURRENT_DATE - INTERVAL '5 days', v_supervisor_id, 'Foundation work', NOW()),
            (gen_random_uuid(), v_site_id, 'Sand', 75.0, 'cubic feet', CURRENT_DATE - INTERVAL '2 days', v_supervisor_id, 'Plastering', NOW()),
            (gen_random_uuid(), v_site_id, 'Steel', 500.0, 'kg', CURRENT_DATE - INTERVAL '7 days', v_supervisor_id, 'Reinforcement', NOW()),
            (gen_random_uuid(), v_site_id, 'Steel', 300.0, 'kg', CURRENT_DATE - INTERVAL '4 days', v_supervisor_id, 'Column reinforcement', NOW()),
            (gen_random_uuid(), v_site_id, 'Brick', 2000.0, 'pieces', CURRENT_DATE - INTERVAL '6 days', v_supervisor_id, 'Wall construction', NOW()),
            (gen_random_uuid(), v_site_id, 'Brick', 1500.0, 'pieces', CURRENT_DATE - INTERVAL '1 day', v_supervisor_id, 'Wall construction', NOW()),
            (gen_random_uuid(), v_site_id, 'Gravel', 150.0, 'cubic feet', CURRENT_DATE - INTERVAL '5 days', v_supervisor_id, 'Foundation work', NOW());
        
        RAISE NOTICE 'Test material usage data added successfully for site: %', v_site_id;
    ELSE
        RAISE NOTICE 'Site or supervisor not found. Site ID: %, Supervisor ID: %', v_site_id, v_supervisor_id;
    END IF;
END $$;

-- Verify the data
SELECT 
    s.site_name,
    mu.material_type,
    SUM(mu.quantity_used) as total_used,
    mu.unit,
    COUNT(*) as usage_count,
    MAX(mu.usage_date) as last_used
FROM material_usage mu
JOIN sites s ON mu.site_id = s.id
WHERE s.site_name = 'Test Construction Site'
GROUP BY s.site_name, mu.material_type, mu.unit
ORDER BY mu.material_type;
