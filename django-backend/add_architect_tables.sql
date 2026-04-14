-- Add project_files table for architect file uploads
CREATE TABLE IF NOT EXISTS project_files (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    file_type VARCHAR(50) NOT NULL, -- 'ESTIMATION', 'FLOOR_PLAN', 'ELEVATION', 'STRUCTURE', 'DESIGN', 'OTHER'
    file_url TEXT NOT NULL,
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(15, 2), -- For estimation files
    is_plan_extended BOOLEAN DEFAULT FALSE, -- For estimation files
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_files_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
    CONSTRAINT fk_project_files_user FOREIGN KEY (uploaded_by) REFERENCES users(id)
);

-- Add notifications table if not exists
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'COMPLAINT', 'PLAN_UPDATE', 'ESTIMATION', 'GENERAL'
    related_id UUID, -- ID of related entity (complaint_id, file_id, etc.)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_project_files_site ON project_files(site_id);
CREATE INDEX IF NOT EXISTS idx_project_files_type ON project_files(file_type);
CREATE INDEX IF NOT EXISTS idx_project_files_uploaded_at ON project_files(uploaded_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at);

-- Ensure complaints table has all required columns
DO $$ 
BEGIN
    -- Add proof_image_url if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='complaints' AND column_name='proof_image_url') THEN
        ALTER TABLE complaints ADD COLUMN proof_image_url TEXT;
    END IF;
    
    -- Add resolution_notes if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='complaints' AND column_name='resolution_notes') THEN
        ALTER TABLE complaints ADD COLUMN resolution_notes TEXT;
    END IF;
END $$;
