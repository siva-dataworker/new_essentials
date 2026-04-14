-- Fix vendor_bills table schema

-- Check if table exists, if not create it
CREATE TABLE IF NOT EXISTS vendor_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Bill Information
    bill_number VARCHAR(100) NOT NULL,
    bill_date DATE NOT NULL,
    vendor_name VARCHAR(200) NOT NULL,
    vendor_type VARCHAR(50) NOT NULL,
    
    -- Service Details
    service_type VARCHAR(100) NOT NULL,
    service_description TEXT,
    
    -- Financial Details
    amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL,
    
    -- Payment Details
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    payment_mode VARCHAR(50),
    payment_date DATE,
    
    -- Document
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_size INTEGER,
    
    -- Additional Info
    notes TEXT,
    
    -- Metadata
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    day_of_week VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Fix site_agreements table
CREATE TABLE IF NOT EXISTS site_agreements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Agreement Information
    agreement_type VARCHAR(50) NOT NULL,
    agreement_number VARCHAR(100),
    agreement_date DATE NOT NULL,
    
    -- Parties
    party_name VARCHAR(200) NOT NULL,
    party_type VARCHAR(50) NOT NULL,
    
    -- Details
    title VARCHAR(200) NOT NULL,
    description TEXT,
    contract_value DECIMAL(15,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    
    -- Document
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_size INTEGER,
    
    -- Additional Info
    notes TEXT,
    
    -- Metadata
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    day_of_week VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
