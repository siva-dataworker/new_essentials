"""
Check sites table structure
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def check_sites_table():
    print("=" * 80)
    print("Checking sites table structure...")
    print("=" * 80)
    
    # Get table structure
    query = """
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'sites'
        ORDER BY ordinal_position;
    """
    
    columns = fetch_all(query)
    if columns:
        print("\n✅ Sites table structure:")
        for col in columns:
            print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")
    else:
        print("❌ Could not find sites table")
    
    print("\n" + "=" * 80)

if __name__ == '__main__':
    check_sites_table()
