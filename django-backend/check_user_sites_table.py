"""
Check user_sites table structure
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def check_user_sites_table():
    print("=" * 80)
    print("Checking user_sites table structure...")
    print("=" * 80)
    
    # Get table structure
    query = """
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'user_sites'
        ORDER BY ordinal_position;
    """
    
    columns = fetch_all(query)
    if columns:
        print("\n✅ user_sites table structure:")
        for col in columns:
            print(f"  - {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")
    else:
        print("❌ Could not find user_sites table")
    
    # Get sample data
    print("\nSample data:")
    sample_query = "SELECT * FROM user_sites LIMIT 5"
    samples = fetch_all(sample_query)
    for sample in samples:
        print(f"  {sample}")
    
    print("\n" + "=" * 80)

if __name__ == '__main__':
    check_user_sites_table()
