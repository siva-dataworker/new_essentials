#!/usr/bin/env python
"""Check labour_salary_rates table schema"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

# Check table schema
columns = fetch_all("""
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_name = 'labour_salary_rates'
    ORDER BY ordinal_position
""")

print("\n📋 labour_salary_rates Table Schema:")
print("=" * 60)
for col in columns:
    nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
    print(f"{col['column_name']:20} {col['data_type']:15} {nullable}")

print("\n" + "=" * 60)
print(f"Total columns: {len(columns)}")
