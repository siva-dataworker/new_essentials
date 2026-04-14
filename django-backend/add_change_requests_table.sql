-- ============================================
-- ADD CHANGE REQUESTS TABLE
-- ============================================
-- This table stores supervisor requests to modify their submitted entries

CREATE TABLE IF NOT EXISTS change_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Request details
    entry_type VARCHAR(20) NOT NULL CHECK (entry_type IN ('LABOUR', 'MATERIAL')),
    entry_id UUID NOT NULL,  -- ID of the labour_entry or material_balance
    
    -- Who requested
    requested_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Request content
    request_note TEXT NOT NULL,  -- What the supervisor wants to change
    current_value TEXT,  -- Current value (for reference)
    requested_value TEXT,  -- What they want it changed to (optional)
    
    -- Status
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    
    -- Accountant response
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP,
    accountant_notes TEXT,  -- Accountant's response/notes
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_change_requests_status ON change_requests(status);
CREATE INDEX idx_change_requests_requested_by ON change_requests(requested_by);
CREATE INDEX idx_change_requests_entry ON change_requests(entry_type, entry_id);

-- Add comment
COMMENT ON TABLE change_requests IS 'Stores supervisor requests to modify their submitted labour/material entries';
