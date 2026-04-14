-- Check if site_photos table exists and has data
SELECT 
    COUNT(*) as total_photos,
    time_of_day,
    upload_date
FROM site_photos
GROUP BY time_of_day, upload_date
ORDER BY upload_date DESC;

-- Show all photos
SELECT 
    id,
    site_id,
    uploaded_by,
    image_url,
    upload_date,
    time_of_day,
    description,
    created_at
FROM site_photos
ORDER BY created_at DESC
LIMIT 20;

-- Check if table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'site_photos';
