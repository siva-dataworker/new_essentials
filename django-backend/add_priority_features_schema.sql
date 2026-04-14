-- Priority Features Database Schema Updates
-- Run this migration to add support for new features

-- 1. Add photo time type to work_updates
ALTER TABLE work_updates 
ADD COLUMN IF NOT EXISTS upload_time_type VARCHAR(10) CHECK (upload_time_type IN ('morning', 'evening'));

-- 2. Add submitted_by_role to track who submitted entries
ALTER TABLE labour_entries 
ADD COLUMN IF NOT EXISTS submitted_by_role VARCHAR(20) DEFAULT 'Supervisor';

ALTER TABLE material_balances 
ADD COLUMN IF NOT EXISTS submitted_by_role VARCHAR(20) DEFAULT 'Supervisor';

-- 3. Ensure sites table has all location fields
ALTER TABLE sites 
ADD COLUMN IF NOT EXISTS town VARCHAR(100),
ADD COLUMN IF NOT EXISTS city VARCHAR(100);

-- 4. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Create index for faster notification queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- 6. Add index for work_updates time type
CREATE INDEX IF NOT EXISTS idx_work_updates_time_type ON work_updates(upload_time_type);

-- Verify the changes
SELECT 
    table_name,
    column_name, 
    data_type
FROM information_schema.columns 
WHERE table_name IN ('work_updates', 'labour_entries', 'material_balances', 'sites', 'notifications')
    AND column_name IN ('upload_time_type', 'submitted_by_role', 'town', 'city', 'is_read')
ORDER BY table_name, column_name;
