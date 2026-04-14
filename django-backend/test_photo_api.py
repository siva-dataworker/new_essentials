"""
Test photo API
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

# Get the photo that exists
photo = fetch_all("""
    SELECT 
        w.id,
        w.site_id,
        w.update_type,
        w.image_url,
        w.description,
        w.update_date,
        w.uploaded_at,
        u.full_name as uploaded_by,
        r.role_name as uploaded_by_role
    FROM work_updates w
    JOIN users u ON w.engineer_id = u.id
    JOIN roles r ON u.role_id = r.id
    ORDER BY w.uploaded_at DESC
    LIMIT 1
""")

print("\n=== PHOTO API TEST ===")
if photo:
    p = photo[0]
    print(f"Photo found!")
    print(f"  ID: {p['id']}")
    print(f"  Site ID: {p['site_id']}")
    print(f"  Type: {p['update_type']}")
    print(f"  Image URL: {p['image_url']}")
    print(f"  Description: {p['description']}")
    print(f"  Date: {p['update_date']}")
    print(f"  Uploaded At: {p['uploaded_at']}")
    print(f"  Uploaded By: {p['uploaded_by']}")
    print(f"  Role: {p['uploaded_by_role']}")
    
    # Format as API response
    print("\n=== API RESPONSE FORMAT ===")
    response = {
        'id': str(p['id']),
        'update_type': p['update_type'],
        'image_url': p['image_url'],
        'description': p['description'],
        'update_date': p['update_date'].isoformat() if p['update_date'] else None,
        'created_at': p['uploaded_at'].isoformat() if p['uploaded_at'] else None,
        'uploaded_by': p['uploaded_by'],
        'uploaded_by_role': p['uploaded_by_role'],
    }
    print(response)
else:
    print("No photos found")
