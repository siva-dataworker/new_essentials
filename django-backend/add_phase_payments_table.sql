-- Add phase payments tracking table
-- This table tracks payment phases for each site budget

CREATE TABLE IF NOT EXISTS budget_phase_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    budget_allocation_id UUID NOT NULL REFERENCES site_budget_allocation(id) ON DELETE CASCADE,
    phase_number INTEGER NOT NULL CHECK (phase_number BETWEEN 1 AND 5),
    phase_amount DECIMAL(15, 2) NOT NULL CHECK (phase_amount >= 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    recorded_by UUID NOT NULL REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(budget_allocation_id, phase_number)
);

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_phase_payments_site ON budget_phase_payments(site_id);
CREATE INDEX IF NOT EXISTS idx_phase_payments_budget ON budget_phase_payments(budget_allocation_id);

-- Add client_balance column to site_budget_allocation table
ALTER TABLE site_budget_allocation 
ADD COLUMN IF NOT EXISTS client_balance DECIMAL(15, 2) DEFAULT 0;

-- Update existing records to set client_balance = total_budget
UPDATE site_budget_allocation 
SET client_balance = total_budget 
WHERE client_balance IS NULL OR client_balance = 0;

COMMENT ON TABLE budget_phase_payments IS 'Tracks phase-wise payments received from client';
COMMENT ON COLUMN budget_phase_payments.phase_number IS 'Phase number (1-5)';
COMMENT ON COLUMN budget_phase_payments.phase_amount IS 'Amount received in this phase';
COMMENT ON COLUMN site_budget_allocation.client_balance IS 'Remaining balance from client (total_budget - sum of phase payments)';
