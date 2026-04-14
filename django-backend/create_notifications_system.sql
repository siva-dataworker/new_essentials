-- Create notifications table for late entry alerts
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL,
    entry_type VARCHAR(50) NOT NULL, -- 'labour', 'material', 'morning_photo', 'evening_photo'
    message TEXT NOT NULL,
    actual_time TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    supervisor_id UUID,
    supervisor_name VARCHAR(255),
    site_name VARCHAR(255)
);

-- Add foreign key constraints after table creation
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'notifications_site_id_fkey'
    ) THEN
        ALTER TABLE notifications 
        ADD CONSTRAINT notifications_site_id_fkey 
        FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'notifications_supervisor_id_fkey'
    ) THEN
        ALTER TABLE notifications 
        ADD CONSTRAINT notifications_supervisor_id_fkey 
        FOREIGN KEY (supervisor_id) REFERENCES users(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_site_id ON notifications(site_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_entry_type ON notifications(entry_type);

-- Add comment
COMMENT ON TABLE notifications IS 'Stores notifications for late entries by supervisors';
