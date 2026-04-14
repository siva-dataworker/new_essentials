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

print("=== CHECKING USERS TABLE ===")

# Check table structure
columns = fetch_all("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'users'
    ORDER BY ordinal_position
""")

print("Users table columns:")
for col in columns:
    print(f"  - {col['column_name']}: {col['data_type']}")

print("\n=== SAMPLE USERS ===")
users = fetch_all("SELECT * FROM users LIMIT 3")
for user in users:
    print(f"User: {user}")
    break
