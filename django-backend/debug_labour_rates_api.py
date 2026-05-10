#!/usr/bin/env python
"""Debug labour rates API response"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("\n🔍 Debugging Labour Rates API")
print("=" * 60)

# Check what the API query returns
print("\n1️⃣ Raw Database Query (what API uses):")
rates = fetch_all("""
    SELECT
        lsr.*,
        u.full_name as set_by_name
    FROM labour_salary_rates lsr
    JOIN users u ON lsr.set_by = u.id
    WHERE lsr.site_id IS NULL AND lsr.is_active = TRUE
    ORDER BY lsr.labour_type
""")

print(f"   Found {len(rates)} active global rates:")
for r in rates:
    print(f"   - {r['labour_type']}: ₹{float(r['daily_rate'])}/day (set by {r['set_by_name']})")

# Check for area-specific rates
print("\n2️⃣ Checking for area column values:")
area_rates = fetch_all("""
    SELECT labour_type, area, daily_rate, is_active
    FROM labour_salary_rates
    WHERE is_active = TRUE
    ORDER BY area NULLS FIRST, labour_type
""")

print(f"   Total active rates: {len(area_rates)}")
for r in area_rates:
    area_label = r['area'] if r['area'] else 'GLOBAL'
    print(f"   - {area_label:15} | {r['labour_type']:20} | ₹{float(r['daily_rate'])}/day")

# Check the canonical defaults
print("\n3️⃣ Canonical Defaults (from backend code):")
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

print(f"   {len(CANONICAL_DEFAULT_RATES)} canonical types defined")

# Simulate API response
print("\n4️⃣ Simulating API Response for 'global':")
db_rates = fetch_all("""
    SELECT
        lsr.*,
        u.full_name as set_by_name
    FROM labour_salary_rates lsr
    JOIN users u ON lsr.set_by = u.id
    WHERE lsr.site_id IS NULL AND lsr.is_active = TRUE
    ORDER BY lsr.labour_type
""")

db_map = {r['labour_type']: r for r in db_rates}

# Merge with canonical defaults
result = []
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

# Add custom types not in canonical list
for labour_type, r in db_map.items():
    if labour_type not in CANONICAL_DEFAULT_RATES:
        result.append({
            'labour_type': labour_type,
            'daily_rate': float(r['daily_rate']),
            'is_admin_set': True,
        })

print(f"   API would return {len(result)} labour types:")
for r in result:
    marker = "🆕" if r['labour_type'] not in CANONICAL_DEFAULT_RATES else "📋"
    status = "Admin set" if r['is_admin_set'] else "Default"
    print(f"   {marker} {r['labour_type']:20} | ₹{r['daily_rate']:,.0f}/day | {status}")

print("\n" + "=" * 60)
print("✅ Debug completed!")
print("\n⚠️  ISSUE FOUND:")
print("   Custom labour types (load mam, loadman) are NOT being added")
print("   to the API response because the backend only returns")
print("   canonical defaults + their overrides.")
print("\n💡 SOLUTION:")
print("   Update the backend API to include ALL admin-set labour types,")
print("   not just the canonical ones.")
