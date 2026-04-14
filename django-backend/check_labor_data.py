"""
Quick script to check labor entry data
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 80)
print("SUPERVISOR ENTRIES (labour_entries table)")
print("=" * 80)
supervisor_entries = fetch_all("""
    SELECT 
        l.id,
        l.site_id,
        l.entry_date,
        l.labour_type,
        l.labour_count,
        l.supervisor_id,
        u.full_name as supervisor_name,
        u.role as user_role
    FROM labour_entries l
    JOIN users u ON l.supervisor_id = u.id
    WHERE l.entry_date >= '2026-02-14'
    ORDER BY l.entry_date DESC, l.labour_type
""")
for entry in supervisor_entries:
    print(f"ID: {entry['id']}, Date: {entry['entry_date']}, Type: {entry['labour_type']}, "
          f"Count: {entry['labour_count']}, Name: {entry['supervisor_name']}, Role: {entry['user_role']}")

print("\n" + "=" * 80)
print("SITE ENGINEER ENTRIES (site_engineer_entries table)")
print("=" * 80)
engineer_entries = fetch_all("""
    SELECT 
        se.id,
        se.site_id,
        se.entry_date,
        se.labour_type,
        se.labour_count,
        se.site_engineer_id,
        u.full_name as engineer_name,
        u.role as user_role
    FROM site_engineer_entries se
    JOIN users u ON se.site_engineer_id = u.id
    WHERE se.entry_date >= '2026-02-14'
    ORDER BY se.entry_date DESC, se.labour_type
""")
for entry in engineer_entries:
    print(f"ID: {entry['id']}, Date: {entry['entry_date']}, Type: {entry['labour_type']}, "
          f"Count: {entry['labour_count']}, Name: {entry['engineer_name']}, Role: {entry['user_role']}")

print("\n" + "=" * 80)
print("USER ROLES")
print("=" * 80)
users = fetch_all("""
    SELECT id, full_name, role, phone_number
    FROM users
    WHERE full_name IN ('aravind', 'shhsjs')
""")
for user in users:
    print(f"ID: {user['id']}, Name: {user['full_name']}, Role: {user['role']}, Phone: {user['phone_number']}")
