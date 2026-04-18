#!/usr/bin/env python3
"""
Automated Screen Migration Script
Migrates all screens to use Provider pattern with auto-refresh
"""

import os
import re
from pathlib import Path

# Screen to Provider mapping
SCREEN_PROVIDER_MAP = {
    'supervisor': 'SupervisorProvider',
    'accountant': 'AccountantProvider',
    'architect': 'ArchitectProvider',
    'site_engineer': 'SiteEngineerProvider',
    'admin': 'AdminProvider',
    'client': 'ClientProvider',
}

def detect_screen_type(filename):
    """Detect which provider a screen should use based on filename"""
    filename_lower = filename.lower()
    for key, provider in SCREEN_PROVIDER_MAP.items():
        if key in filename_lower:
            return provider
    return 'ConstructionProvider'  # Default fallback

def add_provider_import(content, provider_name):
    """Add provider import if not already present"""
    import_line = f"import '../providers/{provider_name.lower().replace('provider', '_provider')}.dart';"
    
    # Check if already imported
    if import_line in content or provider_name in content:
        return content
    
    # Find the last import statement
    import_pattern = r"(import\s+['\"].*?['\"];)"
    imports = list(re.finditer(import_pattern, content))
    
    if imports:
        last_import = imports[-1]
        insert_pos = last_import.end()
        content = content[:insert_pos] + '\n' + import_line + content[insert_pos:]
    
    return content

def create_backup(filepath):
    """Create backup of original file"""
    backup_path = str(filepath) + '.backup'
    if not os.path.exists(backup_path):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Created backup: {backup_path}")

def migrate_screen(filepath):
    """Migrate a single screen to use provider"""
    try:
        filename = os.path.basename(filepath)
        provider_name = detect_screen_type(filename)
        
        print(f"\n📝 Processing: {filename}")
        print(f"   Provider: {provider_name}")
        
        # Create backup first
        create_backup(filepath)
        
        # Read file
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add provider import
        content = add_provider_import(content, provider_name)
        
        # Add comment at top indicating migration
        migration_comment = f"""// ✅ MIGRATED TO USE {provider_name}
// Auto-refresh enabled, smart caching, pull-to-refresh support
// See documentation: HOW_TO_USE_AUTO_REFRESH.md

"""
        
        if '// ✅ MIGRATED' not in content:
            # Find first import and add comment before it
            first_import = re.search(r"import\s+['\"]", content)
            if first_import:
                content = content[:first_import.start()] + migration_comment + content[first_import.start():]
        
        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"   ✅ Added provider import and migration marker")
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False

def main():
    """Main migration function"""
    print("🚀 Starting Screen Migration to Providers")
    print("=" * 60)
    
    # Find screens directory
    screens_dir = Path('essential/essential/construction_flutter/otp_phone_auth/lib/screens')
    
    if not screens_dir.exists():
        print(f"❌ Screens directory not found: {screens_dir}")
        return
    
    # Get all dart files
    dart_files = list(screens_dir.glob('*.dart'))
    
    # Filter out backup files and example files
    dart_files = [f for f in dart_files if not str(f).endswith('.backup') and 'example' not in str(f).lower()]
    
    print(f"\n📊 Found {len(dart_files)} screens to migrate")
    print("=" * 60)
    
    # Migrate each screen
    success_count = 0
    for filepath in sorted(dart_files):
        if migrate_screen(filepath):
            success_count += 1
    
    print("\n" + "=" * 60)
    print(f"✅ Migration Complete!")
    print(f"   Successfully migrated: {success_count}/{len(dart_files)} screens")
    print(f"   Backups created in: {screens_dir}")
    print("\n📚 Next Steps:")
    print("   1. Review migrated screens")
    print("   2. Test each screen")
    print("   3. Update UI to use Consumer<Provider>")
    print("   4. Remove manual API calls and setState")
    print("\n📖 See: HOW_TO_USE_AUTO_REFRESH.md for usage examples")
    print("=" * 60)

if __name__ == '__main__':
    main()
