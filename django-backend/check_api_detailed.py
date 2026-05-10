import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

# Get the accountant user ID (from previous context)
accountant_id = '9e44a225-c64c-4cb8-9e37-87577069a047'

# Run the exact same query as the API (with DISTINCT ON fix)
labour_query = """
    SELECT DISTINCT ON (l.id)
        l.id,
        l.site_id,
        l.labour_type,
        l.labour_count,
        l.entry_date,
        l.entry_time,
        l.extra_cost,
        l.extra_cost_notes,
        l.submitted_by_role,
        l.notes,
        s.site_name,
        s.customer_name,
        s.area,
        s.street,
        u.full_name as supervisor_name,
        u.username as supervisor_username,
        r.role_name as user_role,
        COALESCE(lsr.daily_rate,
            CASE l.labour_type
                WHEN 'General' THEN 600
                WHEN 'Mason' THEN 800
                WHEN 'Helper' THEN 500
                WHEN 'Carpenter' THEN 750
                WHEN 'Plumber' THEN 700
                WHEN 'Electrician' THEN 750
                WHEN 'Painter' THEN 650
                WHEN 'Tile Layer' THEN 700
                WHEN 'Tile Layerhelper' THEN 700
                WHEN 'Kambi Fitter' THEN 900
                WHEN 'Concrete Kot' THEN 950
                WHEN 'Pile Labour' THEN 800
                ELSE 900
            END
        ) AS daily_rate,
        (l.labour_count * COALESCE(lsr.daily_rate,
            CASE l.labour_type
                WHEN 'General' THEN 600
                WHEN 'Mason' THEN 800
                WHEN 'Helper' THEN 500
                WHEN 'Carpenter' THEN 750
                WHEN 'Plumber' THEN 700
                WHEN 'Electrician' THEN 750
                WHEN 'Painter' THEN 650
                WHEN 'Tile Layer' THEN 700
                WHEN 'Tile Layerhelper' THEN 700
                WHEN 'Kambi Fitter' THEN 900
                WHEN 'Concrete Kot' THEN 950
                WHEN 'Pile Labour' THEN 800
                ELSE 900
            END
        )) AS total_cost
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    JOIN users u ON l.supervisor_id = u.id
    JOIN roles r ON u.role_id = r.id
    LEFT JOIN labour_salary_rates lsr
        ON lsr.site_id IS NULL
        AND lsr.labour_type = l.labour_type
        AND lsr.is_active = TRUE
    ORDER BY l.id, lsr.created_at DESC, l.entry_time DESC
    LIMIT 200
"""

labour_entries = fetch_all(labour_query)

print("=" * 80)
print("DETAILED API QUERY RESULTS")
print("=" * 80)
print(f"\n📊 Total Entries Returned: {len(labour_entries)}")

total_salary = sum(float(e.get('total_cost', 0) or 0) for e in labour_entries)
print(f"💰 Total Salary: ₹{total_salary:,.2f}")

print(f"\n📋 All {len(labour_entries)} Entries:\n")
for i, entry in enumerate(labour_entries, 1):
    print(f"{i}. ID: {entry['id']}")
    print(f"   Date: {entry['entry_date']}")
    print(f"   Site: {entry['site_name']}")
    print(f"   Labour Type: {entry['labour_type']}")
    print(f"   Count: {entry['labour_count']}")
    print(f"   Daily Rate: ₹{entry['daily_rate']}")
    print(f"   Total Cost: ₹{entry['total_cost']}")
    print(f"   Submitted By: {entry['supervisor_name']} ({entry['user_role']})")
    print()

# Check for duplicates
entry_ids = [str(e['id']) for e in labour_entries]
if len(entry_ids) != len(set(entry_ids)):
    print("⚠️  WARNING: DUPLICATE ENTRIES FOUND!")
    from collections import Counter
    duplicates = [id for id, count in Counter(entry_ids).items() if count > 1]
    print(f"   Duplicate IDs: {duplicates}")
else:
    print("✅ No duplicate entries found")

print("\n" + "=" * 80)
