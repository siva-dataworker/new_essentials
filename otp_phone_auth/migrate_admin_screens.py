#!/usr/bin/env python3
"""
Admin Screens Migration Script
Carefully migrates only admin screens to use AdminProvider
"""

import os
import re
import sys
from pathlib import Path

class AdminMigrator:
    def __init__(self, screens_dir):
        self.screens_dir = Path(screens_dir)
        self.migrated = []
        self.errors = []
        
    def add_imports(self, content):
        """Add provider imports"""
        if "import '../providers/admin_provider.dart'" in content:
            return content, False
        
        # Find last import
        imports = list(re.finditer(r"import\s+['\"].*?['\"];", content))
        if not imports:
            return content, False
        
        last_import = imports[-1]
        insert_pos = last_import.end()
        
        # Add provider import
        if 'package:provider/provider.dart' not in content:
            content = content[:insert_pos] + "\nimport 'package:provider/provider.dart';" + content[insert_pos:]
            insert_pos += len("\nimport 'package:provider/provider.dart';")
        
        content = content[:insert_pos] + "\nimport '../providers/admin_provider.dart';" + content[insert_pos:]
        return content, True
    
    def wrap_build(self, content):
        """Wrap build method with Consumer - simple approach"""
        # Find build method
        build_match = re.search(r'(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{', content)
        if not build_match:
            return content, False
        
        # Check if already wrapped
        check_area = content[build_match.start():build_match.start()+500]
        if 'Consumer<AdminProvider>' in check_area:
            return content, False
        
        # Find the return statement
        build_start = build_match.end()
        return_match = re.search(r'\s*return\s+', content[build_start:])
        if not return_match:
            return content, False
        
        return_pos = build_start + return_match.start()
        
        # Insert Consumer wrapper right before return
        consumer_start = '''
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        '''
        
        # Find the closing brace of build method
        brace_count = 1
        i = build_start
        build_end = -1
        
        while i < len(content) and brace_count > 0:
            if content[i] == '{':
                brace_count += 1
            elif content[i] == '}':
                brace_count -= 1
                if brace_count == 0:
                    build_end = i
                    break
            i += 1
        
        if build_end == -1:
            return content, False
        
        # Insert Consumer wrapper
        consumer_end = '''
      },
    );'''
        
        # Replace return with Consumer wrapper
        content = content[:return_pos] + consumer_start + content[return_pos:build_end] + consumer_end + content[build_end:]
        
        return content, True
    
    def migrate_screen(self, filepath):
        """Migrate a single admin screen"""
        try:
            filename = os.path.basename(filepath)
            
            # Skip login screen
            if 'login' in filename.lower():
                print(f"⏭️  Skipped: {filename} (login screen)")
                return True
            
            print(f"\n{'='*70}")
            print(f"📝 Migrating: {filename}")
            print(f"{'='*70}")
            
            # Read file
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Create backup
            backup_path = str(filepath) + '.backup_admin'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original_content)
            print(f"   💾 Backup created: {os.path.basename(backup_path)}")
            
            # Step 1: Add imports
            print("   Step 1: Adding imports...")
            content, changed1 = self.add_imports(content)
            if changed1:
                print("      ✅ Imports added")
            else:
                print("      ℹ️  Imports already present")
            
            # Step 2: Wrap build
            print("   Step 2: Wrapping build with Consumer...")
            content, changed2 = self.wrap_build(content)
            if changed2:
                print("      ✅ Build wrapped")
            else:
                print("      ℹ️  Already wrapped or couldn't wrap")
            
            # Write if changed
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"   ✅ Successfully migrated!")
                self.migrated.append(filename)
            else:
                print(f"   ℹ️  No changes needed")
            
            return True
            
        except Exception as e:
            print(f"   ❌ Error: {e}")
            self.errors.append(filename)
            return False
    
    def migrate_all_admin(self):
        """Migrate all admin screens"""
        print("🚀 Migrating Admin Screens to AdminProvider")
        print("=" * 70)
        
        # Get all admin screens
        admin_files = list(self.screens_dir.glob('admin_*.dart'))
        
        print(f"📊 Found {len(admin_files)} admin screens")
        print("=" * 70)
        
        for filepath in sorted(admin_files):
            self.migrate_screen(filepath)
        
        # Summary
        print("\n" + "=" * 70)
        print("✅ MIGRATION COMPLETE!")
        print("=" * 70)
        print(f"📊 Results:")
        print(f"   Total admin screens: {len(admin_files)}")
        print(f"   ✅ Successfully migrated: {len(self.migrated)}")
        print(f"   ❌ Errors: {len(self.errors)}")
        
        if self.migrated:
            print(f"\n✅ Migrated screens:")
            for screen in self.migrated:
                print(f"   - {screen}")
        
        if self.errors:
            print(f"\n❌ Errors in:")
            for screen in self.errors:
                print(f"   - {screen}")
        
        print("\n" + "=" * 70)
        print("🎉 NEXT STEPS:")
        print("=" * 70)
        print("1. Run: flutter pub get")
        print("2. Run: flutter analyze")
        print("3. Run: flutter run -d chrome")
        print("4. Test admin screens")
        print("\n💾 All backups saved with .backup_admin extension")
        print("=" * 70)

def main():
    screens_dir = 'lib/screens'
    
    if not os.path.exists(screens_dir):
        print(f"❌ Directory not found: {screens_dir}")
        return 1
    
    migrator = AdminMigrator(screens_dir)
    migrator.migrate_all_admin()
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
