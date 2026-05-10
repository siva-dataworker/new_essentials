"""Drop the total_salary table from the database."""
import os, sys, django

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one

exists = fetch_one("""
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'total_salary'
    ) AS exists
""")

print('Table exists:', exists['exists'])

if exists['exists']:
    execute_query('DROP TABLE total_salary CASCADE')
    print('✅ total_salary table dropped successfully')
else:
    print('ℹ️  Table does not exist — nothing to drop')
