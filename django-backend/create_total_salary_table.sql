-- Create total_salary table to track net salary (labour entries - cash entries)
CREATE TABLE IF NOT EXISTS total_salary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    
    -- Salary breakdown
    total_labour_cost DECIMAL(12, 2) NOT NULL DEFAULT 0, -- Total from labour_entries
    total_cash_paid DECIMAL(12, 2) NOT NULL DEFAULT 0,   -- Total from cash_entries
    net_salary DECIMAL(12, 2) NOT NULL DEFAULT 0,        -- total_labour_cost - total_cash_paid
    
    -- Worker counts
    total_workers INTEGER NOT NULL DEFAULT 0,
    
    -- Metadata
    calculated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure only one entry per site per date
    UNIQUE(site_id, entry_date)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_total_salary_site ON total_salary(site_id);
CREATE INDEX IF NOT EXISTS idx_total_salary_date ON total_salary(entry_date);
CREATE INDEX IF NOT EXISTS idx_total_salary_site_date ON total_salary(site_id, entry_date);

-- Add comment
COMMENT ON TABLE total_salary IS 'Stores calculated net salary per site per date. Net salary = Total labour cost - Total cash paid. Updated automatically when cash entries are added.';

-- Create trigger function to update total_salary when cash_entries change
CREATE OR REPLACE FUNCTION update_total_salary()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate and update total_salary for the affected site and date
    INSERT INTO total_salary (site_id, entry_date, total_labour_cost, total_cash_paid, net_salary, total_workers)
    SELECT 
        COALESCE(NEW.site_id, OLD.site_id) as site_id,
        COALESCE(NEW.entry_date, OLD.entry_date) as entry_date,
        COALESCE(
            (SELECT SUM(l.labour_count * COALESCE(lsr.daily_rate,
                CASE l.labour_type
                    WHEN 'General' THEN 600
                    WHEN 'Mason' THEN 800
                    WHEN 'Helper' THEN 500
                    WHEN 'Carpenter' THEN 750
                    WHEN 'Plumber' THEN 700
                    WHEN 'Electrician' THEN 750
                    WHEN 'Painter' THEN 650
                    WHEN 'Tile Layer' THEN 700
                    ELSE 900
                END
            ))
            FROM labour_entries l
            LEFT JOIN labour_salary_rates lsr 
                ON lsr.site_id IS NULL 
                AND lsr.labour_type = l.labour_type 
                AND lsr.is_active = TRUE
            WHERE l.site_id = COALESCE(NEW.site_id, OLD.site_id)
            AND l.entry_date = COALESCE(NEW.entry_date, OLD.entry_date)),
        0) as total_labour_cost,
        COALESCE(
            (SELECT SUM(total_cost) 
            FROM cash_entries 
            WHERE site_id = COALESCE(NEW.site_id, OLD.site_id)
            AND entry_date = COALESCE(NEW.entry_date, OLD.entry_date)),
        0) as total_cash_paid,
        COALESCE(
            (SELECT SUM(l.labour_count * COALESCE(lsr.daily_rate,
                CASE l.labour_type
                    WHEN 'General' THEN 600
                    WHEN 'Mason' THEN 800
                    WHEN 'Helper' THEN 500
                    WHEN 'Carpenter' THEN 750
                    WHEN 'Plumber' THEN 700
                    WHEN 'Electrician' THEN 750
                    WHEN 'Painter' THEN 650
                    WHEN 'Tile Layer' THEN 700
                    ELSE 900
                END
            ))
            FROM labour_entries l
            LEFT JOIN labour_salary_rates lsr 
                ON lsr.site_id IS NULL 
                AND lsr.labour_type = l.labour_type 
                AND lsr.is_active = TRUE
            WHERE l.site_id = COALESCE(NEW.site_id, OLD.site_id)
            AND l.entry_date = COALESCE(NEW.entry_date, OLD.entry_date)),
        0) - COALESCE(
            (SELECT SUM(total_cost) 
            FROM cash_entries 
            WHERE site_id = COALESCE(NEW.site_id, OLD.site_id)
            AND entry_date = COALESCE(NEW.entry_date, OLD.entry_date)),
        0) as net_salary,
        COALESCE(
            (SELECT SUM(labour_count) 
            FROM labour_entries 
            WHERE site_id = COALESCE(NEW.site_id, OLD.site_id)
            AND entry_date = COALESCE(NEW.entry_date, OLD.entry_date)),
        0) as total_workers
    ON CONFLICT (site_id, entry_date) 
    DO UPDATE SET
        total_labour_cost = EXCLUDED.total_labour_cost,
        total_cash_paid = EXCLUDED.total_cash_paid,
        net_salary = EXCLUDED.net_salary,
        total_workers = EXCLUDED.total_workers,
        updated_at = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for INSERT, UPDATE, DELETE on cash_entries
DROP TRIGGER IF EXISTS trigger_update_total_salary_insert ON cash_entries;
CREATE TRIGGER trigger_update_total_salary_insert
AFTER INSERT ON cash_entries
FOR EACH ROW
EXECUTE FUNCTION update_total_salary();

DROP TRIGGER IF EXISTS trigger_update_total_salary_update ON cash_entries;
CREATE TRIGGER trigger_update_total_salary_update
AFTER UPDATE ON cash_entries
FOR EACH ROW
EXECUTE FUNCTION update_total_salary();

DROP TRIGGER IF EXISTS trigger_update_total_salary_delete ON cash_entries;
CREATE TRIGGER trigger_update_total_salary_delete
AFTER DELETE ON cash_entries
FOR EACH ROW
EXECUTE FUNCTION update_total_salary();
