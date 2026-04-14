-- Create site_photos table for supervisor photo uploads
CREATE TABLE IF NOT EXISTS site_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    upload_date DATE NOT NULL,
    time_of_day VARCHAR(20) CHECK (time_of_day IN ('morning', 'evening')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_site_photos_site ON site_photos(site_id);
CREATE INDEX IF NOT EXISTS idx_site_photos_uploaded_by ON site_photos(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_site_photos_upload_date ON site_photos(upload_date);
CREATE INDEX IF NOT EXISTS idx_site_photos_time_of_day ON site_photos(time_of_day);

-- Add comments
COMMENT ON TABLE site_photos IS 'Stores photos uploaded by supervisors (morning and evening)';
COMMENT ON COLUMN site_photos.time_of_day IS 'Time of day when photo was taken: morning or evening';
COMMENT ON COLUMN site_photos.upload_date IS 'Date when the photo was uploaded';

-- Verify table creation
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'site_photos'
ORDER BY ordinal_position;
