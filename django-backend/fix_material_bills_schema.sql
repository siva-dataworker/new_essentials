-- Fix material_bills table schema to match the new requirements
-- Add missing columns for the enhanced bill management system

-- Add vendor_type column
ALTER TABLE material_bills 
ADD COLUMN IF NOT EXISTS vendor_type VARCHAR(50);

-- Add tax_amount column
ALTER TABLE material_bills 
ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(10,2) DEFAULT 0;

-- Add discount_amount column
ALTER TABLE material_bills 
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0;

-- Add final_amount column
ALTER TABLE material_bills 
ADD COLUMN IF NOT EXISTS final_amount DECIMAL(12,2);

-- Add payment_mode column (rename from payment_method)
ALTER TABLE material_bills 
ADD COLUMN IF NOT EXISTS payment_mode VARCHAR(50);

-- Update existing records to have final_amount = total_amount if null
UPDATE material_bills 
SET final_amount = total_amount 
WHERE final_amount IS NULL;

-- Rename accountant_id to uploaded_by if it exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'material_bills' AND column_name = 'accountant_id'
    ) THEN
        -- Drop uploaded_by if it exists
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'material_bills' AND column_name = 'uploaded_by'
        ) THEN
            ALTER TABLE material_bills DROP COLUMN uploaded_by;
        END IF;
        
        -- Rename accountant_id to uploaded_by
        ALTER TABLE material_bills RENAME COLUMN accountant_id TO uploaded_by;
    END IF;
END $$;

-- Drop dependent views if they exist
DROP VIEW IF EXISTS site_material_purchases CASCADE;
DROP VIEW IF EXISTS site_comparison_view CASCADE;

-- Update data types to match new schema
ALTER TABLE material_bills 
ALTER COLUMN total_amount TYPE DECIMAL(12,2);

-- Add service_description column for vendor_bills compatibility
ALTER TABLE material_bills 
ADD COLUMN IF NOT EXISTS service_description TEXT;

COMMIT;
