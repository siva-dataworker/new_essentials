"""
Simple database check - run with: python simple_db_check.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

print("\n" + "=" * 60)
print("SIMPLE DATABASE CHECK")
print("=" * 60)

# Count entries
print("\n1. Counting entries in database...")
labour_count_query = "SELECT COUNT(*) as count FROM labour_entries"
labour_result = fetch_one(labour_count_query)
print(f"   Labour entries: {labour_result['count'] if labour_result else 0}")

material_count_query = "SELECT COUNT(*) as count FROM material_balances"
material_result = fetch_one(material_count_query)
print(f"   Material entries: {material_result['count'] if material_result else 0}")

# If there are entries, show them
if labour_result and labour_result['count'] > 0:
    print("\n2. Recent labour entries:")
    recent_labour = fetch_all("""
        SELECT l.labour_type, l.labour_count, l.entry_date, 
               s.site_name, u.full_name as supervisor
        FROM labour_entries l
        LEFT JOIN sites s ON l.site_id = s.id
        LEFT JOIN users u ON l.supervisor_id = u.id
        ORDER BY l.entry_time DESC
        LIMIT 5
    """)
    for entry in recent_labour:
        print(f"   - {entry['labour_type']}: {entry['labour_count']} workers")
        print(f"     Site: {entry['site_name']}, Supervisor: {entry['supervisor']}")
        print(f"     Date: {entry['entry_date']}")
else:
    print("\n2. ⚠️ NO LABOUR ENTRIES IN DATABASE")
    print("   This means supervisor hasn't submitted any data yet")
    print("   OR data submission is failing")

if material_result and material_result['count'] > 0:
    print("\n3. Recent material entries:")
    recent_materials = fetch_all("""
        SELECT m.material_type, m.quantity, m.unit, m.entry_date,
               s.site_name, u.full_name as supervisor
        FROM material_balances m
        LEFT JOIN sites s ON m.site_id = s.id
        LEFT JOIN users u ON m.supervisor_id = u.id
        ORDER BY m.updated_at DESC
        LIMIT 5
    """)
    for entry in recent_materials:
        print(f"   - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
        print(f"     Site: {entry['site_name']}, Supervisor: {entry['supervisor']}")
        print(f"     Date: {entry['entry_date']}")
else:
    print("\n3. ⚠️ NO MATERIAL ENTRIES IN DATABASE")

# Check if sites exist
print("\n4. Checking sites...")
sites = fetch_all("SELECT COUNT(*) as count FROM sites")
if sites and sites[0]['count'] > 0:
    print(f"   ✅ Found {sites[0]['count']} sites in database")
    sample_sites = fetch_all("SELECT site_name, area, street FROM sites LIMIT 3")
    for site in sample_sites:
        print(f"   - {site['site_name']} ({site['area']}, {site['street']})")
else:
    print("   ❌ NO SITES IN DATABASE - This is a problem!")

# Check supervisors
print("\n5. Checking supervisors...")
supervisors = fetch_all("""
    SELECT u.username, u.full_name, r.role_name, u.status
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE r.role_name = 'Supervisor'
""")
if supervisors:
    print(f"   ✅ Found {len(supervisors)} supervisors")
    for sup in supervisors:
        status_icon = "✅" if sup['status'] == 'APPROVED' else "⏳"
        print(f"   {status_icon} {sup['username']} - {sup['full_name']} ({sup['status']})")
else:
    print("   ❌ NO SUPERVISORS IN DATABASE")

print("\n" + "=" * 60)
print("DIAGNOSIS:")
print("=" * 60)

if labour_result and labour_result['count'] == 0:
    print("❌ PROBLEM: No data in database")
    print("   Possible causes:")
    print("   1. Supervisor hasn't submitted any entries yet")
    print("   2. Data submission is failing (check Flutter app errors)")
    print("   3. Backend API not saving data properly")
    print("\n   SOLUTION: Try submitting data from Flutter app and check for errors")
else:
    print("✅ Data exists in database")
    print("   If not showing in app, the problem is in the API queries")

print("=" * 60 + "\n")
