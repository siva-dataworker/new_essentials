-- Check all sites
SELECT id, site_name, area, street, city 
FROM sites 
ORDER BY site_name;

-- Search for Basha and Anwar
SELECT id, site_name, area, street, city 
FROM sites 
WHERE LOWER(site_name) LIKE '%basha%' 
   OR LOWER(site_name) LIKE '%anwar%'
   OR LOWER(area) LIKE '%basha%'
   OR LOWER(area) LIKE '%anwar%';

-- Check for NULL or empty names
SELECT id, site_name, area, street, city 
FROM sites 
WHERE site_name IS NULL OR site_name = '';
