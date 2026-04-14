"""
Add change requests system to database
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

print("\n" + "=" * 70)
print("ADDING CHANGE REQUESTS SYSTEM")
print("=" * 70)

# Read SQL file
with open('add_change_requests_system.sql', 'r') as f:
    sql = f.read()

# Execute
print("\nExecuting SQL...")
try:
    # Split by statement and execute each
    statements = [s.strip() for s in sql.split(';') if s.strip() and not s.strip().startswith('--')]
    
    for statement in statements:
        if statement.upper() != 'COMMIT':
            execute_query(statement)
            print(f"✅ Executed: {statement[:50]}...")
    
    print("\n✅ Change requests system added successfully!")
    print("\nNew features:")
    print("  - change_requests table created")
    print("  - Supervisors can request changes")
    print("  - Accountants can modify entries")
    print("  - Both can track modified vs unmodified data")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    print("\nNote: Some errors are expected if tables already exist")

print("\n" + "=" * 70 + "\n")
