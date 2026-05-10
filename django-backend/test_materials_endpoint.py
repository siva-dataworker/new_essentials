"""
Test script to verify the materials endpoint is working
Run this to check if the API returns proper JSON
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

def test_materials_query():
    """Test the materials database query"""
    print("\n" + "="*60)
    print("TESTING MATERIALS ENDPOINT")
    print("="*60)
    
    try:
        print("\n🔍 Executing query...")
        materials = fetch_all("""
            SELECT id, material_name, created_at
            FROM material_master
            ORDER BY material_name ASC
        """)
        
        print(f"\n✅ Query successful! Found {len(materials)} materials:")
        print("-"*60)
        
        if materials:
            for m in materials:
                print(f"  • {m['material_name']} (ID: {m['id']})")
        else:
            print("  ⚠️  No materials found in database")
            print("  💡 You may need to add materials first")
        
        print("\n" + "="*60)
        print("RESPONSE FORMAT:")
        print("="*60)
        response_data = {
            'materials': [
                {
                    'id': str(m['id']),
                    'name': m['material_name'],
                    'created_at': m['created_at'].isoformat() if m.get('created_at') else None
                }
                for m in materials
            ]
        }
        
        import json
        print(json.dumps(response_data, indent=2))
        
        print("\n✅ Test completed successfully!")
        print("="*60)
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        print("\n" + "="*60)

if __name__ == '__main__':
    test_materials_query()
