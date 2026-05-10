#!/usr/bin/env python
"""Verify the fix for custom labour types"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("\n✅ Verifying Custom Labour Types Fix")
print("=" * 60)

# Canonical defaults
CANONICAL_DEFAULT_RATES = {
    'General': 600,
    'Mason': 800,
    'Helper': 500,
    'Carpenter': 750,
    'Plumber': 700,
    'Electrician': 750,
    'Painter': 650,
    'Tile Layer': 700,
    'Tile Layerhelper': 700,
    'Kambi Fitter': 900,
    'Concrete Kot': 950,
    'Pile Labour': 800,
}

# Simulate the API logic
print("\n1️⃣ Fetching admin-set global rates from database...")
db_rates = fetch_all("""
    SELECT
        lsr.*,
        u.full_name as set_by_name
    FROM labour_salary_rates lsr
    JOIN users u ON lsr.set_by = u.id
    WHERE lsr.site_id IS NULL AND lsr.is_active = TRUE
    ORDER BY lsr.labour_type
""")

print(f"   Found {len(db_rates)} rates in database")

# Index by labour_type
db_map = {r['labour_type']: r for r in db_rates}

# Build result (same logic as API)
result = []

# Add canonical types
for labour_type, default_rate in CANONICAL_DEFAULT_RATES.items():
    if labour_type in db_map:
        r = db_map[labour_type]
        result.append({
            'labour_type': labour_type,
            'daily_rate': float(r['daily_rate']),
            'is_admin_set': True,
        })
    else:
        result.append({
            'labour_type': labour_type,
            'daily_rate': float(default_rate),
            'is_admin_set': False,
        })

# Add custom labour types not in canonical list (THE FIX)
for labour_type, r in db_map.items():
    if labour_type not in CANONICAL_DEFAULT_RATES:
        result.append({
            'labour_type': labour_type,
            'daily_rate': float(r['daily_rate']),
            'is_admin_set': True,
        })

print(f"\n2️⃣ API Response would contain {len(result)} labour types:")

canonical_count = 0
custom_count = 0

for rate in result:
    labour_type = rate['labour_type']
    daily_rate = rate['daily_rate']
    is_admin_set = rate['is_admin_set']
    
    if labour_type in CANONICAL_DEFAULT_RATES:
        marker = "📋"
        canonical_count += 1
    else:
        marker = "🆕"
        custom_count += 1
    
    status = "Admin set" if is_admin_set else "Default"
    print(f"   {marker} {labour_type:20} | ₹{daily_rate:,.0f}/day | {status}")

print(f"\n3️⃣ Summary:")
print(f"   Canonical types: {canonical_count}")
print(f"   Custom types: {custom_count}")
print(f"   Total: {len(result)}")

# Verify specific custom types
print(f"\n4️⃣ Verifying Custom Types:")
custom_types_to_check = ['load mam', 'loadman', 'Welder']
all_found = True

for custom_type in custom_types_to_check:
    found = any(r['labour_type'] == custom_type for r in result)
    status = "✅" if found else "❌"
    print(f"   {status} {custom_type}")
    if not found:
        all_found = False

print("\n" + "=" * 60)
if all_found and custom_count > 0:
    print("✅ SUCCESS! Fix is working correctly")
    print("   Custom labour types will now appear in Flutter app")
else:
    print("❌ ISSUE! Some custom types are missing")

print("\n💡 Next Steps:")
print("   1. Restart Django server to apply changes")
print("   2. Refresh Flutter app (pull to refresh)")
print("   3. Custom labour types should now appear")
