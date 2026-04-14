-- Fix NULL site_ids in labour_entries and material_balances
-- This assigns them to the first available site

-- Check current state
SELECT 'Labour entries with NULL site_id:' as info, COUNT(*) as count FROM labour_entries WHERE site_id IS NULL;
SELECT 'Material entries with NULL site_id:' as info, COUNT(*) as count FROM material_balances WHERE site_id IS NULL;

-- Get first site ID
DO $$
DECLARE
    first_site_id VARCHAR(255);
BEGIN
    -- Get the first site
    SELECT id INTO first_site_id FROM sites LIMIT 1;
    
    IF first_site_id IS NULL THEN
        RAISE EXCEPTION 'No sites found! Please create a site first.';
    END IF;
    
    RAISE NOTICE 'Using site ID: %', first_site_id;
    
    -- Update labour entries
    UPDATE labour_entries 
    SET site_id = first_site_id 
    WHERE site_id IS NULL;
    
    RAISE NOTICE 'Fixed % labour entries', (SELECT COUNT(*) FROM labour_entries WHERE site_id = first_site_id);
    
    -- Update material balances
    UPDATE material_balances 
    SET site_id = first_site_id 
    WHERE site_id IS NULL;
    
    RAISE NOTICE 'Fixed % material entries', (SELECT COUNT(*) FROM material_balances WHERE site_id = first_site_id);
END $$;

-- Verify fix
SELECT 'After fix - Labour entries with NULL site_id:' as info, COUNT(*) as count FROM labour_entries WHERE site_id IS NULL;
SELECT 'After fix - Material entries with NULL site_id:' as info, COUNT(*) as count FROM material_balances WHERE site_id IS NULL;
SELECT 'Total labour entries:' as info, COUNT(*) as count FROM labour_entries;
SELECT 'Total material entries:' as info, COUNT(*) as count FROM material_balances;
