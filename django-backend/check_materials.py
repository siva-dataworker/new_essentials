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

print("=== CHECKING MATERIAL BALANCES ===")

# Count material entries
count_result = fetch_one("SELECT COUNT(*) as count FROM material_balances")
total_count = count_result['count'] if count_result else 0
print(f"Total material entries: {total_count}")

if total_count > 0:
    print("\n=== RECENT MATERIAL ENTRIES ===")
    recent_materials = fetch_all("""
        SELECT m.material_type, m.quantity, m.unit, m.entry_date, 
               s.site_name, u.username, m.updated_at
        FROM material_balances m
        JOIN sites s ON m.site_id = s.id
        JOIN users u ON m.supervisor_id = u.id
        ORDER BY m.updated_at DESC
        LIMIT 5
    """)
    
    for entry in recent_materials:
        print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
        print(f"    Site: {entry['site_name']}")
        print(f"    By: {entry['username']}")
        print(f"    Date: {entry['entry_date']}")
        print(f"    Updated: {entry['updated_at']}")
        print()
else:
    print("❌ No material entries found!")
    print("\n=== CHECKING TABLE STRUCTURE ===")
    
    # Check if table exists
    table_check = fetch_one("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_name = 'material_balances'
    """)
    
    if table_check:
        print("✅ material_balances table exists")
        
        # Check columns
        columns = fetch_all("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'material_balances'
            ORDER BY ordinal_position
        """)
        
        print("Table columns:")
        for col in columns:
            print(f"  - {col['column_name']}: {col['data_type']}")
    else:
        print("❌ material_balances table does not exist!")

print("\n=== CHECKING LABOUR ENTRIES FOR COMPARISON ===")
labour_count = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
print(f"Total labour entries: {labour_count['count'] if labour_count else 0}")
