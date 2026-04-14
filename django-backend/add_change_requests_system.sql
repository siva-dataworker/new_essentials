-- ============================================
-- CHANGE REQUESTS SYSTEM
-- ============================================
-- Allows supervisors to request changes from accountants
-- Tracks all modifications made by accountants

-- Drop if exists
DROP TABLE IF EXISTS change_requests CASCADE;

-- Change Requests Table
CREATE TABLE change_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL,  -- ID of labour or material entry
    entry_type VARCHAR(20) NOT NULL CHECK (entry_type IN ('LABOUR', 'MATERIAL')),
    requested_by UUID REFERENCES users(id) ON DELETE SET NULL,
    request_message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    handled_by UUID REFERENCES users(id) ON DELETE SET NULL,
    handled_at TIMESTAMP,
    response_message TEXT
);

-- Create indexes
CREATE INDEX idx_change_requests_entry ON change_requests(entry_id, entry_type);
CREATE INDEX idx_change_requests_requested_by ON change_requests(requested_by);
CREATE INDEX idx_change_requests_status ON change_requests(status);
CREATE INDEX idx_change_requests_handled_by ON change_requests(handled_by);

-- Add notes field to labour_entries if not exists
ALTER TABLE labour_entries ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add notes field to material_balances if not exists
ALTER TABLE material_balances ADD COLUMN IF NOT EXISTS notes TEXT;

COMMIT;
