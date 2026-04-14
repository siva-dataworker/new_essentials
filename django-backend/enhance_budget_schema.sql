-- ============================================
-- Enhanced Budget Management Schema
-- Project Quote Management with Cost Breakdown
-- ============================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. Enhanced Site Budgets Table
-- ============================================
-- Drop existing constraints and add new columns
ALTER TABLE site_budgets DROP CONSTRAINT IF EXISTS check_remaining;
ALTER TABLE site_budgets DROP CONSTRAINT IF EXISTS check_utilization;

-- Add new columns for detailed cost tracking
DO $$
BEGIN
    -- Initial quoted amount
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'initial_quote') THEN
        ALTER TABLE site_budgets ADD COLUMN initial_quote DECIMAL(15, 2);
    END IF;
    
    -- Extra costs approved by admin
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'extra_cost_approved') THEN
        ALTER TABLE site_budgets ADD COLUMN extra_cost_approved DECIMAL(15, 2) DEFAULT 0;
    END IF;
    
    -- Labour cost tracking
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'labour_cost') THEN
        ALTER TABLE site_budgets ADD COLUMN labour_cost DECIMAL(15, 2) DEFAULT 0;
    END IF;
    
    -- Material cost tracking
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'material_cost') THEN
        ALTER TABLE site_budgets ADD COLUMN material_cost DECIMAL(15, 2) DEFAULT 0;
    END IF;
    
    -- Extra cost tracking
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'extra_cost') THEN
        ALTER TABLE site_budgets ADD COLUMN extra_cost DECIMAL(15, 2) DEFAULT 0;
    END IF;
    
    -- Project status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'project_status') THEN
        ALTER TABLE site_budgets ADD COLUMN project_status VARCHAR(20) DEFAULT 'ACTIVE';
    END IF;
    
    -- Notes/remarks
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'site_budgets' AND column_name = 'notes') THEN
        ALTER TABLE site_budgets ADD COLUMN notes TEXT;
    END IF;
END $$;

-- Update allocated_amount to be computed from initial_quote + extra_cost_approved
-- Update utilized_amount to be computed from labour_cost + material_cost + extra_cost
-- Update remaining_amount to be computed from allocated_amount - utilized_amount

-- Add new constraints
ALTER TABLE site_budgets 
    ADD CONSTRAINT check_costs_positive 
    CHECK (labour_cost >= 0 AND material_cost >= 0 AND extra_cost >= 0);

ALTER TABLE site_budgets 
    ADD CONSTRAINT check_project_status 
    CHECK (project_status IN ('ACTIVE', 'COMPLETED', 'ON_HOLD', 'CANCELLED'));

-- Create index for project status
CREATE INDEX IF NOT EXISTS idx_site_budgets_status 
    ON site_budgets(project_status, is_active);

COMMENT ON COLUMN site_budgets.initial_quote IS 'Initial quoted amount for the project';
COMMENT ON COLUMN site_budgets.extra_cost_approved IS 'Additional costs approved by admin';
COMMENT ON COLUMN site_budgets.labour_cost IS 'Total labour costs incurred';
COMMENT ON COLUMN site_budgets.material_cost IS 'Total material costs incurred';
COMMENT ON COLUMN site_budgets.extra_cost IS 'Extra costs beyond quote';

-- ============================================
-- 2. Extra Cost Requests Table
-- ============================================
CREATE TABLE IF NOT EXISTS extra_cost_requests (
    request_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    budget_id UUID NOT NULL REFERENCES site_budgets(budget_id) ON DELETE CASCADE,
    requested_amount DECIMAL(15, 2) NOT NULL CHECK (requested_amount > 0),
    reason TEXT NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('LABOUR', 'MATERIAL', 'EQUIPMENT', 'OTHER')),
    requested_by UUID REFERENCES users(id) ON DELETE SET NULL,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP,
    review_notes TEXT,
    CONSTRAINT check_review_required CHECK (
        (status = 'PENDING' AND reviewed_by IS NULL) OR
        (status IN ('APPROVED', 'REJECTED') AND reviewed_by IS NOT NULL)
    )
);

-- Indexes for extra_cost_requests
CREATE INDEX IF NOT EXISTS idx_extra_cost_site_status 
    ON extra_cost_requests(site_id, status, requested_at DESC);
CREATE INDEX IF NOT EXISTS idx_extra_cost_requested_by 
    ON extra_cost_requests(requested_by, requested_at DESC);

COMMENT ON TABLE extra_cost_requests IS 'Requests for additional costs beyond initial quote';

-- ============================================
-- 3. Financial Timeline Table
-- ============================================
CREATE TABLE IF NOT EXISTS financial_timeline (
    timeline_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    budget_id UUID NOT NULL REFERENCES site_budgets(budget_id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'INITIAL_QUOTE', 'EXTRA_COST_ADDED', 'LABOUR_COST_UPDATED', 
        'MATERIAL_COST_UPDATED', 'BUDGET_ADJUSTED', 'PROJECT_COMPLETED'
    )),
    event_description TEXT NOT NULL,
    amount DECIMAL(15, 2),
    previous_total DECIMAL(15, 2),
    new_total DECIMAL(15, 2),
    performed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Indexes for financial_timeline
CREATE INDEX IF NOT EXISTS idx_financial_timeline_site 
    ON financial_timeline(site_id, performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_financial_timeline_budget 
    ON financial_timeline(budget_id, performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_financial_timeline_type 
    ON financial_timeline(event_type, performed_at DESC);

COMMENT ON TABLE financial_timeline IS 'Complete financial history timeline for projects';

-- ============================================
-- 4. Budget Mismatch Alerts Table
-- ============================================
CREATE TABLE IF NOT EXISTS budget_mismatch_alerts (
    alert_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    budget_id UUID NOT NULL REFERENCES site_budgets(budget_id) ON DELETE CASCADE,
    alert_type VARCHAR(50) NOT NULL CHECK (alert_type IN (
        'OVER_BUDGET', 'NEAR_LIMIT', 'COST_SPIKE', 'UNAUTHORIZED_EXPENSE'
    )),
    severity VARCHAR(20) DEFAULT 'MEDIUM' CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    message TEXT NOT NULL,
    current_amount DECIMAL(15, 2),
    threshold_amount DECIMAL(15, 2),
    difference_amount DECIMAL(15, 2),
    is_acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by UUID REFERENCES users(id) ON DELETE SET NULL,
    acknowledged_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Indexes for budget_mismatch_alerts
CREATE INDEX IF NOT EXISTS idx_alerts_site_status 
    ON budget_mismatch_alerts(site_id, is_acknowledged, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_severity 
    ON budget_mismatch_alerts(severity, is_acknowledged, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_type 
    ON budget_mismatch_alerts(alert_type, created_at DESC);

COMMENT ON TABLE budget_mismatch_alerts IS 'Budget mismatch and overspending alerts for admin';

-- ============================================
-- 5. Cost Breakdown View
-- ============================================
CREATE OR REPLACE VIEW v_site_cost_breakdown AS
SELECT 
    sb.budget_id,
    sb.site_id,
    s.site_name,
    sb.initial_quote,
    sb.extra_cost_approved,
    (sb.initial_quote + sb.extra_cost_approved) as total_allocated,
    sb.labour_cost,
    sb.material_cost,
    sb.extra_cost,
    (sb.labour_cost + sb.material_cost + sb.extra_cost) as total_utilized,
    (sb.initial_quote + sb.extra_cost_approved - sb.labour_cost - sb.material_cost - sb.extra_cost) as remaining,
    CASE 
        WHEN (sb.initial_quote + sb.extra_cost_approved) > 0 
        THEN ROUND(((sb.labour_cost + sb.material_cost + sb.extra_cost) / 
                    (sb.initial_quote + sb.extra_cost_approved) * 100)::numeric, 2)
        ELSE 0 
    END as utilization_percentage,
    sb.project_status,
    sb.is_active,
    sb.allocated_at,
    sb.updated_at
FROM site_budgets sb
JOIN sites s ON sb.site_id = s.id;

COMMENT ON VIEW v_site_cost_breakdown IS 'Detailed cost breakdown view for all sites';

-- ============================================
-- 6. Trigger Functions
-- ============================================

-- Function to update budget totals automatically
CREATE OR REPLACE FUNCTION update_budget_totals()
RETURNS TRIGGER AS $$
BEGIN
    -- Update allocated_amount
    NEW.allocated_amount := COALESCE(NEW.initial_quote, 0) + COALESCE(NEW.extra_cost_approved, 0);
    
    -- Update utilized_amount
    NEW.utilized_amount := COALESCE(NEW.labour_cost, 0) + COALESCE(NEW.material_cost, 0) + COALESCE(NEW.extra_cost, 0);
    
    -- Update remaining_amount
    NEW.remaining_amount := NEW.allocated_amount - NEW.utilized_amount;
    
    -- Update timestamp
    NEW.updated_at := CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic budget calculation
DROP TRIGGER IF EXISTS trigger_update_budget_totals ON site_budgets;
CREATE TRIGGER trigger_update_budget_totals
    BEFORE INSERT OR UPDATE ON site_budgets
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_totals();

-- Function to create financial timeline entry
CREATE OR REPLACE FUNCTION create_financial_timeline_entry()
RETURNS TRIGGER AS $$
DECLARE
    v_event_type VARCHAR(50);
    v_description TEXT;
    v_amount DECIMAL(15, 2);
    v_previous_total DECIMAL(15, 2);
BEGIN
    -- Determine event type based on what changed
    IF TG_OP = 'INSERT' THEN
        v_event_type := 'INITIAL_QUOTE';
        v_description := 'Initial project quote set';
        v_amount := NEW.initial_quote;
        v_previous_total := 0;
        
        INSERT INTO financial_timeline (
            site_id, budget_id, event_type, event_description, 
            amount, previous_total, new_total, performed_by
        ) VALUES (
            NEW.site_id, NEW.budget_id, v_event_type, v_description,
            v_amount, v_previous_total, NEW.allocated_amount, NEW.allocated_by
        );
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- Check what changed
        IF OLD.extra_cost_approved != NEW.extra_cost_approved THEN
            v_event_type := 'EXTRA_COST_ADDED';
            v_description := 'Extra cost approved and added to budget';
            v_amount := NEW.extra_cost_approved - OLD.extra_cost_approved;
            v_previous_total := OLD.allocated_amount;
            
            INSERT INTO financial_timeline (
                site_id, budget_id, event_type, event_description, 
                amount, previous_total, new_total, performed_by
            ) VALUES (
                NEW.site_id, NEW.budget_id, v_event_type, v_description,
                v_amount, v_previous_total, NEW.allocated_amount, NEW.allocated_by
            );
        END IF;
        
        IF OLD.labour_cost != NEW.labour_cost THEN
            v_event_type := 'LABOUR_COST_UPDATED';
            v_description := 'Labour cost updated';
            v_amount := NEW.labour_cost - OLD.labour_cost;
            v_previous_total := OLD.utilized_amount;
            
            INSERT INTO financial_timeline (
                site_id, budget_id, event_type, event_description, 
                amount, previous_total, new_total, performed_by
            ) VALUES (
                NEW.site_id, NEW.budget_id, v_event_type, v_description,
                v_amount, v_previous_total, NEW.utilized_amount, NEW.allocated_by
            );
        END IF;
        
        IF OLD.material_cost != NEW.material_cost THEN
            v_event_type := 'MATERIAL_COST_UPDATED';
            v_description := 'Material cost updated';
            v_amount := NEW.material_cost - OLD.material_cost;
            v_previous_total := OLD.utilized_amount;
            
            INSERT INTO financial_timeline (
                site_id, budget_id, event_type, event_description, 
                amount, previous_total, new_total, performed_by
            ) VALUES (
                NEW.site_id, NEW.budget_id, v_event_type, v_description,
                v_amount, v_previous_total, NEW.utilized_amount, NEW.allocated_by
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for financial timeline
DROP TRIGGER IF EXISTS trigger_financial_timeline ON site_budgets;
CREATE TRIGGER trigger_financial_timeline
    AFTER INSERT OR UPDATE ON site_budgets
    FOR EACH ROW
    EXECUTE FUNCTION create_financial_timeline_entry();

-- Function to check for budget mismatches and create alerts
CREATE OR REPLACE FUNCTION check_budget_mismatch()
RETURNS TRIGGER AS $$
DECLARE
    v_utilization_pct DECIMAL(5, 2);
    v_over_budget DECIMAL(15, 2);
BEGIN
    -- Calculate utilization percentage
    IF NEW.allocated_amount > 0 THEN
        v_utilization_pct := (NEW.utilized_amount / NEW.allocated_amount) * 100;
    ELSE
        v_utilization_pct := 0;
    END IF;
    
    -- Check for over budget
    IF NEW.utilized_amount > NEW.allocated_amount THEN
        v_over_budget := NEW.utilized_amount - NEW.allocated_amount;
        
        INSERT INTO budget_mismatch_alerts (
            site_id, budget_id, alert_type, severity, message,
            current_amount, threshold_amount, difference_amount
        ) VALUES (
            NEW.site_id, NEW.budget_id, 'OVER_BUDGET', 'CRITICAL',
            'Project has exceeded allocated budget by ₹' || v_over_budget,
            NEW.utilized_amount, NEW.allocated_amount, v_over_budget
        );
    
    -- Check for near limit (90% utilization)
    ELSIF v_utilization_pct >= 90 AND v_utilization_pct < 100 THEN
        INSERT INTO budget_mismatch_alerts (
            site_id, budget_id, alert_type, severity, message,
            current_amount, threshold_amount, difference_amount
        ) VALUES (
            NEW.site_id, NEW.budget_id, 'NEAR_LIMIT', 'HIGH',
            'Project is at ' || v_utilization_pct || '% of allocated budget',
            NEW.utilized_amount, NEW.allocated_amount, NEW.remaining_amount
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for budget mismatch alerts
DROP TRIGGER IF EXISTS trigger_budget_mismatch ON site_budgets;
CREATE TRIGGER trigger_budget_mismatch
    AFTER INSERT OR UPDATE ON site_budgets
    FOR EACH ROW
    EXECUTE FUNCTION check_budget_mismatch();

-- ============================================
-- 7. Update realtime_updates for new events
-- ============================================
ALTER TABLE realtime_updates DROP CONSTRAINT IF EXISTS realtime_updates_update_type_check;
ALTER TABLE realtime_updates 
    ADD CONSTRAINT realtime_updates_update_type_check 
    CHECK (update_type IN (
        'LABOUR_ENTRY', 'LABOUR_CORRECTION', 'BILL_UPLOAD', 'BUDGET_UPDATE',
        'EXTRA_COST_REQUEST', 'EXTRA_COST_APPROVED', 'BUDGET_ALERT'
    ));

-- ============================================
-- Migration Complete
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✓ Enhanced budget schema migration completed';
    RAISE NOTICE '✓ Added cost breakdown columns';
    RAISE NOTICE '✓ Created extra_cost_requests table';
    RAISE NOTICE '✓ Created financial_timeline table';
    RAISE NOTICE '✓ Created budget_mismatch_alerts table';
    RAISE NOTICE '✓ Created automatic triggers for budget tracking';
    RAISE NOTICE '✓ Created cost breakdown view';
END $$;
