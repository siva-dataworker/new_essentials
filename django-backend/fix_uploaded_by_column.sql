-- Fix uploaded_by column in bills and agreements tables
-- Add the column if it doesn't exist

-- Material Bills
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'material_bills' AND column_name = 'uploaded_by'
    ) THEN
        ALTER TABLE material_bills ADD COLUMN uploaded_by UUID REFERENCES users(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added uploaded_by column to material_bills';
    ELSE
        RAISE NOTICE 'uploaded_by column already exists in material_bills';
    END IF;
END $$;

-- Vendor Bills
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_bills' AND column_name = 'uploaded_by'
    ) THEN
        ALTER TABLE vendor_bills ADD COLUMN uploaded_by UUID REFERENCES users(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added uploaded_by column to vendor_bills';
    ELSE
        RAISE NOTICE 'uploaded_by column already exists in vendor_bills';
    END IF;
END $$;

-- Site Agreements
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'site_agreements' AND column_name = 'uploaded_by'
    ) THEN
        ALTER TABLE site_agreements ADD COLUMN uploaded_by UUID REFERENCES users(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added uploaded_by column to site_agreements';
    ELSE
        RAISE NOTICE 'uploaded_by column already exists in site_agreements';
    END IF;
END $$;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_material_bills_uploaded_by ON material_bills(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_vendor_bills_uploaded_by ON vendor_bills(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_site_agreements_uploaded_by ON site_agreements(uploaded_by);

SELECT 'Fix complete!' as status;
