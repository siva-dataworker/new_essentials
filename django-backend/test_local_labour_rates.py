#!/usr/bin/env python
"""Test local labour rates feature"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, execute_query
import uuid

print("\n🧪 Testing Local Labour Rates Feature")
print("=" * 60)

# 1. Check areas available
print("\n1️⃣ Available Areas:")
areas = fetch_all("SELECT DISTINCT area FROM sites WHERE area IS NOT NULL ORDER BY area")
for area in areas:
    print(f"   - {area['area']}")

# 2. Check current labour rates
print("\n2️⃣ Current Labour Rates:")
rates = fetch_all("""
    SELECT 
        COALESCE(area, 'GLOBAL') as rate_area,
        labour_type,
        daily_rate,
        is_active
    FROM labour_salary_rates
    WHERE is_active = TRUE
    ORDER BY area NULLS FIRST, labour_type
""")

if rates:
    for rate in rates:
        print(f"   {rate['rate_area']:15} | {rate['labour_type']:20} | ₹{float(rate['daily_rate']):,.0f}/day")
else:
    print("   No rates set yet")

# 3. Test setting a local rate
print("\n3️⃣ Testing Local Rate Creation:")
if areas:
    test_area = areas[0]['area']
    test_labour_type = 'Mason'
    test_rate = 900.00
    
    print(f"   Setting {test_labour_type} rate for {test_area} to ₹{test_rate}/day")
    
    # Deactivate existing
    execute_query("""
        UPDATE labour_salary_rates
        SET is_active = FALSE
        WHERE area = %s AND labour_type = %s AND is_active = TRUE
    """, (test_area, test_labour_type))
    
    # Insert new rate
    rate_id = str(uuid.uuid4())
    execute_query("""
        INSERT INTO labour_salary_rates 
        (id, area, labour_type, daily_rate, effective_from, is_active, notes, set_by, created_at)
        VALUES (%s, %s, %s, %s, CURRENT_DATE, TRUE, %s, 
                (SELECT id FROM users LIMIT 1), 
                CURRENT_TIMESTAMP)
    """, (rate_id, test_area, test_labour_type, test_rate, 'Test local rate'))
    
    print(f"   ✅ Local rate created with ID: {rate_id}")
    
    # Verify
    verify = fetch_all("""
        SELECT area, labour_type, daily_rate
        FROM labour_salary_rates
        WHERE area = %s AND labour_type = %s AND is_active = TRUE
    """, (test_area, test_labour_type))
    
    if verify:
        print(f"   ✅ Verified: {verify[0]['labour_type']} in {verify[0]['area']} = ₹{float(verify[0]['daily_rate'])}/day")
    else:
        print("   ❌ Verification failed")
else:
    print("   ⚠️  No areas available for testing")

# 4. Show rate priority logic
print("\n4️⃣ Rate Priority Logic:")
print("   1. Site-specific rate (site_id set, area NULL)")
print("   2. Area-specific rate (area set, site_id NULL)")
print("   3. Global rate (both NULL)")

print("\n" + "=" * 60)
print("✅ Test completed!")
