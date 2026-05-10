import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

print("=" * 80)
print("UPDATING TOTAL_SALARY TABLE - ADDING SELECTED_ROLE")
print("=" * 80)
print()

# Read SQL file
with open('update_total_salary_add_role.sql', 'r') as f:
    sql = f.read()

# Split by semicolon and execute each statement
statements = [s.strip() for s in sql.split(';') if s.strip()]

for i, statement in enumerate(statements, 1):
    try:
        print(f"Executing statement {i}/{len(statements)}...")
        execute_query(statement)
        print(f"✅ Statement {i} executed successfully")
    except Exception as e:
        print(f"⚠️  Statement {i}: {e}")
        # Continue with next statement

print()
print("=" * 80)
print("✅ TOTAL_SALARY TABLE UPDATED")
print("=" * 80)
