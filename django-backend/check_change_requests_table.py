"""
Check change_requests table structure
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("\n" + "=" * 70)
print("CHECKING CHANGE_REQUESTS TABLE STRUCTURE")
print("=" * 70)

# Check table structure
print("\nTable columns:")
try:
    result = fetch_all("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'change_requests'
        ORDER BY ordinal_position
    """)
    
    if len(result) == 0:
        print("   ❌ Table not found or no columns")
    else:
        for col in result:
            print(f"   - {col['column_name']}: {col['data_type']}")
            
except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n" + "=" * 70 + "\n")
