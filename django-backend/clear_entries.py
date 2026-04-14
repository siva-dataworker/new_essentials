"""
Clear all labour and material entries from database
"""
import os
import sys
import django

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one

print("Clearing all labour and material entries...")

# Count before deletion
labour_count = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
material_count = fetch_one("SELECT COUNT(*) as count FROM material_balances")

print(f"Found {labour_count['count']} labour entries")
print(f"Found {material_count['count']} material entries")

# Delete all entries
execute_query("DELETE FROM labour_entries")
execute_query("DELETE FROM material_balances")

print("✅ All labour and material entries deleted")

# Verify
labour_count_after = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
material_count_after = fetch_one("SELECT COUNT(*) as count FROM material_balances")

print(f"Labour entries remaining: {labour_count_after['count']}")
print(f"Material entries remaining: {material_count_after['count']}")
