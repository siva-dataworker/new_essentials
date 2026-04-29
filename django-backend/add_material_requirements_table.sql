-- Material Requirements Table
-- Supervisors can submit material requirements for their sites
-- Admin can view all material requirements

CREATE TABLE IF NOT EXISTS material_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    supervisor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    material_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,  -- e.g., 'bags', 'tons', 'pieces', 'sq.ft'
    priority VARCHAR(20) DEFAULT 'normal',  -- 'urgent', 'normal', 'low'
    notes TEXT,
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'approved', 'ordered', 'delivered'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_material_requirements_site ON material_requirements(site_id);
CREATE INDEX IF NOT EXISTS idx_material_requirements_supervisor ON material_requirements(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_material_requirements_status ON material_requirements(status);
CREATE INDEX IF NOT EXISTS idx_material_requirements_created ON material_requirements(created_at DESC);

-- Comments
COMMENT ON TABLE material_requirements IS 'Material requirements submitted by supervisors';
COMMENT ON COLUMN material_requirements.priority IS 'urgent, normal, or low';
COMMENT ON COLUMN material_requirements.status IS 'pending, approved, ordered, or delivered';
