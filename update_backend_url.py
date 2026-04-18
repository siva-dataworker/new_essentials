#!/usr/bin/env python3
"""
Update backend URL across all Flutter service files
"""
import os
import re

# Old URLs to replace
OLD_URLS = [
    'http://192.168.1.11:8000',
    'http://192.168.1.10:8000',
    'http://192.168.1.9:8000',
    'http://localhost:8000',
    'https://essentials-construction-project.onrender.com',
]

# New URL
NEW_URL = 'https://new-essentials.onrender.com'

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

def main():
    """Main function to update all service files"""
    print("🔄 Updating backend URLs to:", NEW_URL)
    print()
    
    # Service files directory
    services_dir = 'otp_phone_auth/lib/services'
    
    if not os.path.exists(services_dir):
        print(f"❌ Directory not found: {services_dir}")
        return
    
    updated_files = []
    
    # Update all .dart files in services directory
    for filename in os.listdir(services_dir):
        if filename.endswith('.dart'):
            filepath = os.path.join(services_dir, filename)
            print(f"📝 {filename}")
            
            if update_file(filepath):
                updated_files.append(filename)
                print(f"  ✅ Updated")
            else:
                print(f"  ⏭️  No changes needed")
            print()
    
    # Summary
    print("=" * 50)
    print(f"✅ Updated {len(updated_files)} files:")
    for filename in updated_files:
        print(f"  - {filename}")
    
    print()
    print("🎉 All backend URLs updated successfully!")
    print()
    print("Next steps:")
    print("1. Test the app: flutter run")
    print("2. Commit changes: git add . && git commit -m 'Update backend URL to Render'")
    print("3. Push to GitHub: git push origin main")

if __name__ == '__main__':
    main()
