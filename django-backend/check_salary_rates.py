import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

# Check labour_salary_rates table
query = """
    SELECT 
        id,
        site_id,
        labour_type,
        daily_rate,
        is_active,
        created_at
    FROM labour_salary_rates
    WHERE is_active = TRUE
    ORDER BY labour_type, daily_rate
"""

rates = fetch_all(query)

print("=" * 80)
print("LABOUR SALARY RATES TABLE")
print("=" * 80)
print(f"\n📊 Total Active Rates: {len(rates)}\n")

if rates:
    for rate in rates:
        print(f"Labour Type: {rate['labour_type']}")
        print(f"  Site ID: {rate['site_id'] or 'NULL (Global)'}")
        print(f"  Daily Rate: ₹{rate['daily_rate']}")
        print(f"  Created: {rate['created_at']}")
        print()
else:
    print("No active rates found in labour_salary_rates table")

print("=" * 80)
