#!/usr/bin/env python3
"""
Update backend URL across all Flutter service files
"""
import os
import re

# Old URLs to replace
OLD_URLS = [
    'https://new-essentials.onrender.com',
    'https://essentials-construction-project.onrender.com',
    'http://192.168.1.11:8000',
    'http://192.168.1.10:8000',
    'http://192.168.1.9:8000',
]

# New URL - localhost for development
NEW_URL = 'http://localhost:8000'

def update_file(filepath):
    """Update URLs in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        updated = False
        
        # Replace all old URLs
        for old_url in OLD_URLS:
            if old_url in content:
                content = content.replace(old_url, NEW_URL)
                updated = True
                print(f"  ✓ Replaced {old_url}")
        
        # Save if changed
        if updated and content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def update_directory(directory):
    """Recursively update all .dart files in directory"""
    updated_files = []
    
    for root, dirs, files in os.walk(directory):
        for filename in files:
            if filename.endswith('.dart'):
                filepath = os.path.join(root, filename)
                relative_path = os.path.relpath(filepath, directory)
                print(f"📝 {relative_path}")
                
                if update_file(filepath):
                    updated_files.append(relative_path)
                    print(f"  ✅ Updated")
                else:
                    print(f"  ⏭️  No changes needed")
                print()
    
    return updated_files

def main():
    """Main function to update all service files"""
    print("🔄 Updating backend URLs to:", NEW_URL)
    print()
    
    # Directories to update
    directories = [
        'otp_phone_auth/lib/services',
        'otp_phone_auth/lib/screens',
        'otp_phone_auth/lib/config',
    ]
    
    all_updated_files = []
    
    for directory in directories:
        if os.path.exists(directory):
            print(f"\n📁 Updating {directory}...")
            print("=" * 50)
            updated = update_directory(directory)
            all_updated_files.extend(updated)
        else:
            print(f"⚠️  Directory not found: {directory}")
    
    # Summary
    print("\n" + "=" * 50)
    print(f"✅ Updated {len(all_updated_files)} files:")
    for filename in all_updated_files:
        print(f"  - {filename}")
    
    print()
    print("🎉 All backend URLs updated to localhost!")
    print()
    print("⚠️  IMPORTANT:")
    print("1. Start Django backend: cd django-backend && python manage.py runserver")
    print("2. Test the app: flutter run")
    print("3. For physical device, use your computer's IP instead of localhost")

if __name__ == '__main__':
    main()
