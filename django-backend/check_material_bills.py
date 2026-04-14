import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

cursor = connection.cursor()
cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'material_bills' ORDER BY ordinal_position")
print("Material Bills columns:")
for c in cursor.fetchall():
    print(f"  - {c[0]}")

cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'labour_entries' ORDER BY ordinal_position")
print("\nLabour Entries columns:")
for c in cursor.fetchall():
    print(f"  - {c[0]}")
