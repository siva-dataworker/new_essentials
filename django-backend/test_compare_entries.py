from api.database import fetch_all
from datetime import datetime

# Check for entries on May 8, 2026
entries = fetch_all('''
    SELECT 
        l.id,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        l.submitted_by_role,
        s.site_name,
        s.customer_name,
        u.full_name
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date = %s
    ORDER BY l.entry_date DESC
    LIMIT 10
''', ('2026-05-08',))

print(f'Found {len(entries)} entries for 2026-05-08:')
for e in entries:
    role = e.get('submitted_by_role', 'Unknown')
    print(f'  - {e["site_name"]}: {e["labour_type"]} x {e["labour_count"]} (Role: {role}) by {e["full_name"]}')

# Test the actual endpoint logic
print('\n--- Testing Supervisor entries ---')
supervisor_entries = fetch_all('''
    SELECT
        l.id,
        l.site_id,
        s.site_name,
        s.customer_name,
        l.supervisor_id,
        u.full_name as submitted_by,
        l.labour_type,
        l.labour_count,
        l.entry_date,
        l.entry_time,
        l.created_at as submitted_at
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date = %s AND (l.submitted_by_role = 'Supervisor' OR l.submitted_by_role IS NULL)
    ORDER BY l.site_id, l.entry_time DESC
''', ('2026-05-08',))

print(f'Supervisor entries: {len(supervisor_entries)}')
for e in supervisor_entries:
    print(f'  - Site: {e["site_name"]}, Labour: {e["labour_type"]} x {e["labour_count"]}')

print('\n--- Testing Site Engineer entries ---')
engineer_entries = fetch_all('''
    SELECT
        l.id,
        l.site_id,
        s.site_name,
        s.customer_name,
        l.supervisor_id as engineer_id,
        u.full_name as submitted_by,
        l.labour_type,
        l.labour_count,
        l.entry_date,
        l.entry_time,
        l.created_at as submitted_at
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date = %s AND l.submitted_by_role = 'Site Engineer'
    ORDER BY l.site_id, l.entry_time DESC
''', ('2026-05-08',))

print(f'Site Engineer entries: {len(engineer_entries)}')
for e in engineer_entries:
    print(f'  - Site: {e["site_name"]}, Labour: {e["labour_type"]} x {e["labour_count"]}')
