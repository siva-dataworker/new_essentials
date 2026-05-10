"""
Test the GET materials endpoint directly
"""
from api.database import fetch_all

print("=" * 80)
print("TESTING GET MATERIALS QUERY")
print("=" * 80)

try:
    materials = fetch_all("""
        SELECT id, material_name, created_at
        FROM material_master
        ORDER BY material_name ASC
    """)
    
    print(f"\nTotal materials: {len(materials)}")
    print("\nMaterials:")
    for m in materials:
        print(f"  - ID: {m['id']}")
        print(f"    Name: {m['material_name']}")
        print(f"    Created: {m['created_at']}")
        print()
    
    # Format as API response
    response = {
        'materials': [
            {
                'id': str(m['id']),
                'name': m['material_name'],
                'created_at': m['created_at'].isoformat() if m.get('created_at') else None
            }
            for m in materials
        ]
    }
    
    print("API Response format:")
    import json
    print(json.dumps(response, indent=2))
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
