-- Add site_engineer_documents table for document uploads (Site Plans, Floor Designs, etc.)
CREATE TABLE IF NOT EXISTS site_engineer_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    site_engineer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- 'Site Plan', 'Floor Design', 'Structural Plan', 'Electrical Plan', 'Plumbing Plan', 'Other'
    title VARCHAR(200) NOT NULL,
    description TEXT,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_size INTEGER, -- in bytes
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    day_of_week VARCHAR(10) NOT NULL, -- 'Monday', 'Tuesday', etc.
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_site_id ON site_engineer_documents(site_id);
CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_engineer_id ON site_engineer_documents(site_engineer_id);
CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_upload_date ON site_engineer_documents(upload_date);
CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_document_type ON site_engineer_documents(document_type);

-- Add comment
COMMENT ON TABLE site_engineer_documents IS 'Stores PDF documents uploaded by Site Engineers (site plans, floor designs, etc.)';
