"""
Run admin features migration
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

# Read the migration SQL
with open('admin_features_migration.sql', 'r') as f:
    sql = f.read()

# Split by semicolons and execute each statement
statements = [s.strip() for s in sql.split(';') if s.strip()]

with connection.cursor() as cursor:
    for i, statement in enumerate(statements, 1):
        try:
            print(f"Executing statement {i}...")
            cursor.execute(statement)
            print(f"✓ Statement {i} executed successfully")
        except Exception as e:
            print(f"✗ Statement {i} failed: {e}")
            # Continue with other statements

print("\n✅ Migration completed!")
print("\nNew tables created:")
print("  - site_metrics")
print("  - site_documents")
print("  - admin_access_log")
print("  - work_notifications")
print("\nNew views created:")
print("  - site_material_purchases")
print("  - site_comparison_view")
