import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

print("=" * 80)
print("CREATING TOTAL_SALARY TABLE (SIMPLE VERSION)")
print("=" * 80)
print()

# Read SQL file
with open('create_total_salary_simple.sql', 'r') as f:
    sql = f.read()

# Execute
try:
    execute_query(sql)
    print("✅ total_salary table created successfully")
except Exception as e:
    print(f"Error: {e}")

print()
print("=" * 80)
print("✅ SETUP COMPLETE")
print("=" * 80)
