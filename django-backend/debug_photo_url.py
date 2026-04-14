"""
Debug photo URL issue
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings
from api.database import fetch_all

# Get the photo
photo = fetch_all("""
    SELECT * FROM work_updates 
    ORDER BY uploaded_at DESC 
    LIMIT 1
""")

if photo:
    p = photo[0]
    print("\n=== PHOTO URL DEBUG ===")
    print(f"Image URL in DB: {p['image_url']}")
    print(f"\nDjango Settings:")
    print(f"  MEDIA_URL: {settings.MEDIA_URL}")
    print(f"  MEDIA_ROOT: {settings.MEDIA_ROOT}")
    print(f"  BASE_DIR: {settings.BASE_DIR}")
    
    # Check if file exists
    if p['image_url'].startswith('/media/'):
        # Remove /media/ prefix
        relative_path = p['image_url'].replace('/media/', '')
        full_path = os.path.join(settings.MEDIA_ROOT, relative_path)
        print(f"\nFile Path:")
        print(f"  Relative: {relative_path}")
        print(f"  Full: {full_path}")
        print(f"  Exists: {os.path.exists(full_path)}")
        
        if os.path.exists(full_path):
            print(f"  Size: {os.path.getsize(full_path)} bytes")
        else:
            print(f"  ❌ FILE NOT FOUND!")
            # Check media directory
            media_dir = os.path.join(settings.MEDIA_ROOT, 'site_photos')
            print(f"\nMedia directory: {media_dir}")
            print(f"  Exists: {os.path.exists(media_dir)}")
            if os.path.exists(media_dir):
                files = os.listdir(media_dir)
                print(f"  Files in directory: {files}")
    
    # What the URL should be
    print(f"\nExpected URL format:")
    print(f"  http://192.168.1.7:8000{p['image_url']}")
    
else:
    print("No photos found")
