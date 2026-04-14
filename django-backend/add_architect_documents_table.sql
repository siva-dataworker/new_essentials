-- Add architect_documents table for document uploads
CREATE TABLE IF NOT EXISTS architect_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    architect_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- 'Floor Plan', 'Elevation', 'Structure Drawing', 'Design', 'Other'
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
CREATE INDEX IF NOT EXISTS idx_architect_documents_site_id ON architect_documents(site_id);
CREATE INDEX IF NOT EXISTS idx_architect_documents_architect_id ON architect_documents(architect_id);
CREATE INDEX IF NOT EXISTS idx_architect_documents_upload_date ON architect_documents(upload_date);
CREATE INDEX IF NOT EXISTS idx_architect_documents_document_type ON architect_documents(document_type);

-- Add architect_complaints table for complaints
CREATE TABLE IF NOT EXISTS architect_complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    architect_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM', -- 'LOW', 'MEDIUM', 'HIGH', 'URGENT'
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'
    assigned_to UUID REFERENCES users(id), -- Site Engineer assigned to resolve
    resolution_notes TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    day_of_week VARCHAR(10) NOT NULL, -- 'Monday', 'Tuesday', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for architect_complaints
CREATE INDEX IF NOT EXISTS idx_architect_complaints_site_id ON architect_complaints(site_id);
CREATE INDEX IF NOT EXISTS idx_architect_complaints_architect_id ON architect_complaints(architect_id);
CREATE INDEX IF NOT EXISTS idx_architect_complaints_upload_date ON architect_complaints(upload_date);
CREATE INDEX IF NOT EXISTS idx_architect_complaints_status ON architect_complaints(status);
CREATE INDEX IF NOT EXISTS idx_architect_complaints_priority ON architect_complaints(priority);