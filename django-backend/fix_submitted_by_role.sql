-- Fix submitted_by_role for existing entries
-- Update entries to match the actual user role

UPDATE labour_entries l
SET submitted_by_role = u.role
FROM users u
WHERE l.supervisor_id = u.id
AND (l.submitted_by_role IS NULL OR l.submitted_by_role != u.role);

-- Verify the fix
SELECT 
    l.id,
    l.entry_date,
    l.labour_type,
    l.labour_count,
    u.full_name,
    u.role as user_role,
    l.submitted_by_role
FROM labour_entries l
JOIN users u ON l.supervisor_id = u.id
WHERE l.entry_date >= '2026-02-14'
ORDER BY l.entry_date DESC, l.labour_type;
