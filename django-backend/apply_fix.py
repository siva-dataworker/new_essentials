"""
Apply the submitted_by_role fix
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

print("=" * 80)
print("FIXING submitted_by_role FIELD")
print("=" * 80)

# Update entries to match the actual user role
result = execute_query("""
    UPDATE labour_entries l
    SET submitted_by_role = u.role
    FROM users u
    WHERE l.supervisor_id = u.id
    AND (l.submitted_by_role IS NULL OR l.submitted_by_role != u.role)
""")

print(f"✅ Updated labour entries to match user roles")

print("\n" + "=" * 80)
print("VERIFYING THE FIX")
print("=" * 80)

entries = fetch_all("""
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
    ORDER BY l.entry_date DESC, l.labour_type
""")

for entry in entries:
    match_status = "✅" if entry['user_role'] == entry['submitted_by_role'] else "❌"
    print(f"{match_status} Date: {entry['entry_date']}, Type: {entry['labour_type']}, "
          f"Count: {entry['labour_count']}, Name: {entry['full_name']}, "
          f"User Role: {entry['user_role']}, Submitted By: {entry['submitted_by_role']}")

print("\n" + "=" * 80)
print("FIX COMPLETE!")
print("=" * 80)
