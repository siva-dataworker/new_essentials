-- Fix vendor_bills and site_agreements tables
-- Rename accountant_id to uploaded_by to match API

-- Fix vendor_bills table
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_bills' AND column_name = 'accountant_id'
    ) THEN
        -- Drop uploaded_by if it exists
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'vendor_bills' AND column_name = 'uploaded_by'
        ) THEN
            ALTER TABLE vendor_bills DROP COLUMN uploaded_by;
        END IF;
        
        -- Rename accountant_id to uploaded_by
        ALTER TABLE vendor_bills RENAME COLUMN accountant_id TO uploaded_by;
    END IF;
END $$;

-- Fix site_agreements table
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'site_agreements' AND column_name = 'accountant_id'
    ) THEN
        -- Drop uploaded_by if it exists
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'site_agreements' AND column_name = 'uploaded_by'
        ) THEN
            ALTER TABLE site_agreements DROP COLUMN uploaded_by;
        END IF;
        
        -- Rename accountant_id to uploaded_by
        ALTER TABLE site_agreements RENAME COLUMN accountant_id TO uploaded_by;
    END IF;
END $$;

-- Add missing columns to vendor_bills if needed
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS service_type VARCHAR(100);
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS service_description TEXT;
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS amount DECIMAL(12,2);
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS final_amount DECIMAL(12,2);
ALTER TABLE vendor_bills ADD COLUMN IF NOT EXISTS payment_mode VARCHAR(50);

-- Add missing columns to site_agreements if needed
ALTER TABLE site_agreements ADD COLUMN IF NOT EXISTS party_type VARCHAR(50);
ALTER TABLE site_agreements ADD COLUMN IF NOT EXISTS title VARCHAR(200);
ALTER TABLE site_agreements ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'ACTIVE';

COMMIT;
