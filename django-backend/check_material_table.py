#!/usr/bin/env python3

import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

print("=== CHECKING MATERIAL_BALANCES TABLE STRUCTURE ===")

# Check table structure
columns = fetch_all("""
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns 
    WHERE table_name = 'material_balances'
    ORDER BY ordinal_position
""")

print("material_balances table columns:")
for col in columns:
    print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")

print("\n=== CHECKING LABOUR_ENTRIES TABLE STRUCTURE ===")

# Check labour_entries table structure for comparison
labour_columns = fetch_all("""
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns 
    WHERE table_name = 'labour_entries'
    ORDER BY ordinal_position
""")

print("labour_entries table columns:")
for col in labour_columns:
    print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")

print("\n=== TESTING MATERIAL QUERY WITHOUT is_modified ===")

# Test material query without is_modified filter
supervisor_id = '5be9eb15-da04-4721-8fa2-ed5baf57a802'
material_query = """
    SELECT 
        m.id,
        m.site_id,
        m.material_type,
        m.quantity,
        m.unit,
        m.entry_date,
        m.updated_at,
        s.site_name,
        s.area,
        s.street
    FROM material_balances m
    JOIN sites s ON m.site_id = s.id
    WHERE m.supervisor_id = %s
    ORDER BY m.updated_at DESC
    LIMIT 5
"""
material_entries = fetch_all(material_query, (supervisor_id,))
print(f"Material entries found (without is_modified filter): {len(material_entries)}")

if material_entries:
    print("\nSample material entry:")
    sample = material_entries[0]
    for key, value in sample.items():
        print(f"  {key}: {value}")
