#!/usr/bin/env python3

import os
import sys
import django
import json
from datetime import datetime

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all, fetch_one

print("=== DEBUGGING ENTRY SUBMISSION AND HISTORY ===")

# Get current user info
supervisor = fetch_one("SELECT id, username FROM users WHERE role_id = 2 LIMIT 1")
if not supervisor:
    print("❌ No supervisor found!")
    exit(1)

print(f"Testing with supervisor: {supervisor['username']} (ID: {supervisor['id']})")

# Check recent submissions
print("\n=== RECENT LABOUR ENTRIES ===")
recent_labour = fetch_all("""
    SELECT l.id, l.labour_type, l.labour_count, l.entry_date, l.entry_time,
           s.site_name
    FROM labour_entries l
    JOIN sites s ON l.site_id = s.id
    WHERE l.supervisor_id = %s
    ORDER BY COALESCE(l.entry_time, l.entry_date) DESC
    LIMIT 5
""", (supervisor['id'],))

print(f"Found {len(recent_labour)} labour entries:")
for entry in recent_labour:
    print(f"  - {entry['labour_type']}: {entry['labour_count']} workers")
    print(f"    Site: {entry['site_name']}")
    print(f"    Date: {entry['entry_date']}")
    print(f"    Time: {entry['entry_time'] or 'No time'}")
    print()

print("\n=== RECENT MATERIAL ENTRIES ===")
recent_materials = fetch_all("""
    SELECT m.id, m.material_type, m.quantity, m.unit, m.entry_date, m.updated_at,
           s.site_name
    FROM material_balances m
    JOIN sites s ON m.site_id = s.id
    WHERE m.supervisor_id = %s
    ORDER BY COALESCE(m.updated_at, m.entry_date) DESC
    LIMIT 5
""", (supervisor['id'],))

print(f"Found {len(recent_materials)} material entries:")
for entry in recent_materials:
    print(f"  - {entry['material_type']}: {entry['quantity']} {entry['unit']}")
    print(f"    Site: {entry['site_name']}")
    print(f"    Date: {entry['entry_date']}")
    print(f"    Updated: {entry['updated_at'] or 'No updated_at'}")
    print()

# Check if entries from today exist
today = datetime.now().date()
print(f"\n=== TODAY'S ENTRIES ({today}) ===")

today_labour = fetch_all("""
    SELECT COUNT(*) as count FROM labour_entries 
    WHERE supervisor_id = %s AND entry_date = %s
""", (supervisor['id'], today))

today_materials = fetch_all("""
    SELECT COUNT(*) as count FROM material_balances 
    WHERE supervisor_id = %s AND entry_date = %s
""", (supervisor['id'], today))

print(f"Today's labour entries: {today_labour[0]['count'] if today_labour else 0}")
print(f"Today's material entries: {today_materials[0]['count'] if today_materials else 0}")

# Check table structures for missing columns
print("\n=== CHECKING TABLE STRUCTURES ===")

print("Labour entries columns:")
labour_cols = fetch_all("""
    SELECT column_name FROM information_schema.columns 
    WHERE table_name = 'labour_entries' 
    ORDER BY ordinal_position
""")
for col in labour_cols:
    print(f"  - {col['column_name']}")

print("\nMaterial balances columns:")
material_cols = fetch_all("""
    SELECT column_name FROM information_schema.columns 
    WHERE table_name = 'material_balances' 
    ORDER BY ordinal_position
""")
for col in material_cols:
    print(f"  - {col['column_name']}")

# Check if created_at columns exist
labour_has_created_at = any(col['column_name'] == 'created_at' for col in labour_cols)
material_has_created_at = any(col['column_name'] == 'created_at' for col in material_cols)

print(f"\nLabour entries has created_at: {labour_has_created_at}")
print(f"Material balances has created_at: {material_has_created_at}")

if not labour_has_created_at:
    print("⚠️ Labour entries missing created_at column!")
if not material_has_created_at:
    print("⚠️ Material balances missing created_at column!")

print("\n=== SUMMARY ===")
print(f"Total labour entries: {len(recent_labour)}")
print(f"Total material entries: {len(recent_materials)}")
print(f"Today's submissions: {today_labour[0]['count'] if today_labour else 0} labour, {today_materials[0]['count'] if today_materials else 0} materials")
