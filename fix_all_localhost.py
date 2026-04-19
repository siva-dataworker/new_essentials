#!/usr/bin/env python3
"""
Script to replace all localhost:8000 URLs with production Render URL
"""

import os
import re

# Files to update
files_to_update = [
    'otp_phone_auth/lib/screens/supervisor_photo_upload_screen.dart',
    'otp_phone_auth/lib/screens/site_photo_gallery_screen.dart',
    'otp_phone_auth/lib/screens/site_engineer_document_screen.dart',
    'otp_phone_auth/lib/screens/simple_budget_screen.dart',
    'otp_phone_auth/lib/screens/admin_site_full_view.dart',
    'otp_phone_auth/lib/screens/admin_manage_users_screen.dart',
    'otp_phone_auth/lib/screens/accountant_entry_screen.dart',
    'otp_phone_auth/lib/screens/accountant_bills_screen.dart',
]

# Replacement patterns
replacements = [
    (r'http://localhost:8000/api', 'https://new-essentials.onrender.com/api'),
    (r'http://localhost:8000', 'https://new-essentials.onrender.com'),
    (r"'http://localhost:8000/api'", "'https://new-essentials.onrender.com/api'"),
    (r'"http://localhost:8000/api"', '"https://new-essentials.onrender.com/api"'),
]

def update_file(filepath):
    """Update a single file"""
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return False
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    changes_made = 0
    
    for pattern, replacement in replacements:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            changes_made += len(re.findall(pattern, content))
            content = new_content
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Updated {filepath} ({changes_made} changes)")
        return True
    else:
        print(f"⏭️  No changes needed in {filepath}")
        return False

def main():
    print("🔧 Fixing all localhost URLs to production Render URL...\n")
    
    total_updated = 0
    for filepath in files_to_update:
        if update_file(filepath):
            total_updated += 1
    
    print(f"\n✅ Updated {total_updated} files")
    print("🚀 Ready to commit and push!")

if __name__ == '__main__':
    main()
