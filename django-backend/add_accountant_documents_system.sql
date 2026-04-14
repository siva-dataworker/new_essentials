-- ============================================
-- ACCOUNTANT DOCUMENTS SYSTEM
-- Bills, Agreements, and Financial Documents
-- ============================================

-- 1. MATERIAL BILLS TABLE
-- For bills from material vendors (tiles shop, cement, steel, etc.)
CREATE TABLE IF NOT EXISTS material_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Bill Information
    bill_number VARCHAR(100) NOT NULL,
    bill_date DATE NOT NULL,
    vendor_name VARCHAR(200) NOT NULL,
    vendor_type VARCHAR(50) NOT NULL, -- 'Tiles Shop', 'Cement Supplier', 'Steel Supplier', 'Hardware Store', 'Paint Shop', 'Electrical Shop', 'Plumbing Shop', 'Other'
    
    -- Material Details
    material_type VARCHAR(100) NOT NULL, -- 'Tiles', 'Cement', 'Steel', 'Sand', 'Bricks', 'Paint', 'Electrical', 'Plumbing', 'Other'
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- 'nos', 'bags', 'kg', 'tons', 'sqft', 'boxes', 'pieces'
    
    -- Financial Details
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL,
    
    -- Payment Details
    payment_status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'PARTIAL', 'PAID'
    payment_mode VARCHAR(50), -- 'Cash', 'Cheque', 'Bank Transfer', 'UPI', 'Credit'
    payment_date DATE,
    
    -- Document
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_size INTEGER,
    
    -- Additional Info
    notes TEXT,
    description TEXT,
    
    -- Metadata
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    day_of_week VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. VENDOR BILLS TABLE
-- For bills from service providers and contractors
CREATE TABLE IF NOT EXISTS vendor_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Bill Information
    bill_number VARCHAR(100) NOT NULL,
    bill_date DATE NOT NULL,
    vendor_name VARCHAR(200) NOT NULL,
    vendor_type VARCHAR(50) NOT NULL, -- 'Contractor', 'Electrician', 'Plumber', 'Carpenter', 'Mason', 'Painter', 'Transport', 'Equipment Rental', 'Other'
    
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

-- 3. SITE AGREEMENTS TABLE
-- For signed agreements for new sites
CREATE TABLE IF NOT EXISTS site_agreements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Agreement Information
    agreement_type VARCHAR(50) NOT NULL, -- 'Site Agreement', 'Contractor Agreement', 'Vendor Agreement', 'Lease Agreement', 'Purchase Agreement', 'Other'
    agreement_number VARCHAR(100),
    agreement_date DATE NOT NULL,
    
    -- Parties Involved
    party_name VARCHAR(200) NOT NULL, -- Customer/Contractor/Vendor name
    party_type VARCHAR(50) NOT NULL, -- 'Customer', 'Contractor', 'Vendor', 'Owner', 'Other'
    
    -- Agreement Details
    title VARCHAR(200) NOT NULL,
    description TEXT,
    contract_value DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    duration_months INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE', -- 'DRAFT', 'ACTIVE', 'COMPLETED', 'TERMINATED', 'EXPIRED'
    
    -- Document
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_size INTEGER,
    
    -- Additional Info
    notes TEXT,
    terms_conditions TEXT,
    
    -- Metadata
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    day_of_week VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Material Bills Indexes
CREATE INDEX IF NOT EXISTS idx_material_bills_site_id ON material_bills(site_id);
CREATE INDEX IF NOT EXISTS idx_material_bills_uploaded_by ON material_bills(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_material_bills_bill_date ON material_bills(bill_date);
CREATE INDEX IF NOT EXISTS idx_material_bills_vendor_type ON material_bills(vendor_type);
CREATE INDEX IF NOT EXISTS idx_material_bills_material_type ON material_bills(material_type);
CREATE INDEX IF NOT EXISTS idx_material_bills_payment_status ON material_bills(payment_status);

-- Vendor Bills Indexes
CREATE INDEX IF NOT EXISTS idx_vendor_bills_site_id ON vendor_bills(site_id);
CREATE INDEX IF NOT EXISTS idx_vendor_bills_uploaded_by ON vendor_bills(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_vendor_bills_bill_date ON vendor_bills(bill_date);
CREATE INDEX IF NOT EXISTS idx_vendor_bills_vendor_type ON vendor_bills(vendor_type);
CREATE INDEX IF NOT EXISTS idx_vendor_bills_payment_status ON vendor_bills(payment_status);

-- Site Agreements Indexes
CREATE INDEX IF NOT EXISTS idx_site_agreements_site_id ON site_agreements(site_id);
CREATE INDEX IF NOT EXISTS idx_site_agreements_uploaded_by ON site_agreements(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_site_agreements_agreement_date ON site_agreements(agreement_date);
CREATE INDEX IF NOT EXISTS idx_site_agreements_agreement_type ON site_agreements(agreement_type);
CREATE INDEX IF NOT EXISTS idx_site_agreements_status ON site_agreements(status);

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE material_bills IS 'Stores bills from material vendors (tiles, cement, steel, etc.)';
COMMENT ON TABLE vendor_bills IS 'Stores bills from service providers and contractors';
COMMENT ON TABLE site_agreements IS 'Stores signed agreements for sites (customer agreements, contractor agreements, etc.)';

