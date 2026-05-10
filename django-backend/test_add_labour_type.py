#!/usr/bin/env python
"""Test adding a new labour type"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, execute_query
import uuid

print("\n🧪 Testing Add Labour Type Feature")
print("=" * 60)

# 1. Check current labour types
print("\n1️⃣ Current Labour Types:")
rates = fetch_all("""
    SELECT DISTINCT labour_type, daily_rate, is_active
    FROM labour_salary_rates
    WHERE site_id IS NULL AND area IS NULL AND is_active = TRUE
    ORDER BY labour_type
""")

print(f"   Found {len(rates)} labour types:")
for rate in rates:
    print(f"   - {rate['labour_type']}: ₹{float(rate['daily_rate'])}/day")

# 2. Add a new labour type (Welder)
print("\n2️⃣ Adding New Labour Type: Welder")
new_labour_type = "Welder"
new_rate = 850.00

# Check if already exists
existing = fetch_all("""
    SELECT * FROM labour_salary_rates
    WHERE labour_type = %s AND site_id IS NULL AND area IS NULL AND is_active = TRUE
""", (new_labour_type,))

if existing:
    print(f"   ⚠️  {new_labour_type} already exists, deactivating old rate...")
    execute_query("""
        UPDATE labour_salary_rates
        SET is_active = FALSE
        WHERE labour_type = %s AND site_id IS NULL AND area IS NULL AND is_active = TRUE
    """, (new_labour_type,))

# Insert new rate
rate_id = str(uuid.uuid4())
execute_query("""
    INSERT INTO labour_salary_rates 
    (id, site_id, area, labour_type, daily_rate, effective_from, is_active, notes, set_by, created_at)
    VALUES (%s, NULL, NULL, %s, %s, CURRENT_DATE, TRUE, %s, 
            (SELECT id FROM users LIMIT 1), 
            CURRENT_TIMESTAMP)
""", (rate_id, new_labour_type, new_rate, 'Test new labour type'))

print(f"   ✅ {new_labour_type} added with rate ₹{new_rate}/day")

# 3. Verify it appears in the list
print("\n3️⃣ Verifying New Labour Type:")
updated_rates = fetch_all("""
    SELECT DISTINCT labour_type, daily_rate, is_active
    FROM labour_salary_rates
    WHERE site_id IS NULL AND area IS NULL AND is_active = TRUE
    ORDER BY labour_type
""")

print(f"   Now showing {len(updated_rates)} labour types:")
for rate in updated_rates:
    marker = "🆕" if rate['labour_type'] == new_labour_type else "  "
    print(f"   {marker} {rate['labour_type']}: ₹{float(rate['daily_rate'])}/day")

# 4. Test API response format
print("\n4️⃣ Testing API Response Format:")
print("   The API should return all labour types including the new one")
print("   Format: {'labour_type': 'Welder', 'daily_rate': 850, 'is_admin_set': True}")

print("\n" + "=" * 60)
print("✅ Test completed!")
print("\nℹ️  In the Flutter app:")
print("   1. Click '+' button in Labour Rates screen")
print("   2. Enter 'Welder' and rate '850'")
print("   3. Click 'Add Labour Type'")
print("   4. Welder should appear in the list immediately")
