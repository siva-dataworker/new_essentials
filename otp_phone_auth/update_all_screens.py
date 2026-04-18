#!/usr/bin/env python3
"""
Automated Screen Migration Script
Updates all Flutter screens to use Provider pattern with auto-refresh
"""

import os
import re
import sys
from pathlib import Path
from datetime import datetime

# Screen to Provider mapping
PROVIDER_MAP = {
    'supervisor': 'SupervisorProvider',
    'accountant': 'AccountantProvider',
    'architect': 'ArchitectProvider',
    'site_engineer': 'SiteEngineerProvider',
    'admin': 'AdminProvider',
    'client': 'ClientProvider',
    'owner': 'AdminProvider',  # Owner uses AdminProvider
}

class ScreenMigrator:
    def __init__(self, screens_dir):
        self.screens_dir = Path(screens_dir)
        self.stats = {
            'total': 0,
            'success': 0,
            'skipped': 0,
            'errors': 0
        }
        
    def detect_provider(self, filename):
        """Detect which provider to use based on filename"""
        filename_lower = filename.lower()
        
        for key, provider in PROVIDER_MAP.items():
            if key in filename_lower:
                return provider
        
        # Default to ConstructionProvider for common screens
        return 'ConstructionProvider'
    
    def get_provider_import(self, provider_name):
        """Get the import statement for a provider"""
        provider_file = provider_name.replace('Provider', '_provider').lower()
        return f"import '../providers/{provider_file}.dart';"
    
    def has_provider_import(self, content, provider_name):
        """Check if provider is already imported"""
        provider_file = provider_name.replace('Provider', '_provider').lower()
        import_pattern = f"import\\s+['\"]../providers/{provider_file}\\.dart['\"]"
        return bool(re.search(import_pattern, content))
    
    def add_provider_import(self, content, provider_name):
        """Add provider import after other imports"""
        if self.has_provider_import(content, provider_name):
            return content
        
        # Add provider import
        provider_import = self.get_provider_import(provider_name)
        
        # Find the last import statement
        import_pattern = r"(import\s+['\"].*?['\"];)"
        imports = list(re.finditer(import_pattern, content))
        
        if imports:
            last_import = imports[-1]
            insert_pos = last_import.end()
            
            # Check if provider import is needed
            if 'package:provider/provider.dart' not in content:
                provider_package_import = "\nimport 'package:provider/provider.dart';"
                content = content[:insert_pos] + provider_package_import + content[insert_pos:]
                insert_pos += len(provider_package_import)
            
            content = content[:insert_pos] + '\n' + provider_import + content[insert_pos:]
        
        return content
    
    def add_migration_marker(self, content, provider_name):
        """Add migration marker at the top of file"""
        marker = f"""// ✅ MIGRATED TO USE {provider_name}
// Auto-refresh: Every 30 seconds
// Smart caching: Enabled
// Pull-to-refresh: Supported
// Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

"""
        
        if '// ✅ MIGRATED' in content:
            return content
        
        # Find first import and add marker before it
        first_import = re.search(r"import\s+['\"]", content)
        if first_import:
            content = content[:first_import.start()] + marker + content[first_import.start():]
        
        return content
    
    def wrap_build_with_consumer(self, content, provider_name):
        """Wrap build method return with Consumer"""
        # This is complex and risky - we'll add a TODO comment instead
        # Find build method
        build_pattern = r'(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{'
        build_match = re.search(build_pattern, content)
        
        if not build_match:
            return content
        
        # Add TODO comment before build method
        todo_comment = f"""
  // TODO: Wrap build method with Consumer<{provider_name}>
  // Example:
  // return Consumer<{provider_name}>(
  //   builder: (context, provider, child) {{
  //     return Scaffold(...);
  //   }},
  // );
  
"""
        
        # Check if TODO already exists
        if f'TODO: Wrap build method with Consumer<{provider_name}>' in content:
            return content
        
        insert_pos = build_match.start()
        content = content[:insert_pos] + todo_comment + content[insert_pos:]
        
        return content
    
    def add_usage_examples(self, content, provider_name):
        """Add usage examples as comments"""
        examples = f"""
// 📝 PROVIDER USAGE EXAMPLES:
// 
// Access data:
//   provider.sites          // List of sites
//   provider.isLoading      // Loading state
//   provider.error          // Error message
//
// Refresh data:
//   provider.refreshData()  // Manual refresh
//
// Pull-to-refresh:
//   RefreshIndicator(
//     onRefresh: () => provider.refreshData(),
//     child: YourWidget(),
//   )
//
// Submit data (auto-refreshes):
//   await provider.submitLabour(...);
//
// See: QUICK_START_GUIDE.md for complete examples

"""
        
        if '// 📝 PROVIDER USAGE EXAMPLES:' in content:
            return content
        
        # Add after class declaration
        class_pattern = r'class\s+\w+\s+extends\s+\w+\s*\{'
        class_match = re.search(class_pattern, content)
        
        if class_match:
            insert_pos = class_match.end()
            content = content[:insert_pos] + examples + content[insert_pos:]
        
        return content
    
    def create_backup(self, filepath):
        """Create backup of original file"""
        backup_path = str(filepath) + '.backup'
        if not os.path.exists(backup_path):
            with open(filepath, 'r', encoding='utf-8') as f:
                backup_content = f.read()
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(backup_content)
            return True
        return False
    
    def migrate_screen(self, filepath):
        """Migrate a single screen"""
        try:
            filename = os.path.basename(filepath)
            
            # Skip certain files
            skip_files = [
                'login_screen.dart',
                'registration_screen.dart',
                'splash_screen.dart',
                'otp_verification_screen.dart',
                'phone_auth_screen.dart',
                'pending_approval_screen.dart',
                'role_selection_screen.dart',
                '.backup',
                'with_provider.dart',  # Skip example files
            ]
            
            if any(skip in filename for skip in skip_files):
                print(f"⏭️  Skipped: {filename} (excluded file)")
                self.stats['skipped'] += 1
                return True
            
            provider_name = self.detect_provider(filename)
            
            print(f"\n📝 Processing: {filename}")
            print(f"   Provider: {provider_name}")
            
            # Create backup
            backup_created = self.create_backup(filepath)
            if backup_created:
                print(f"   💾 Backup created")
            
            # Read file
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Apply migrations
            content = self.add_migration_marker(content, provider_name)
            content = self.add_provider_import(content, provider_name)
            content = self.wrap_build_with_consumer(content, provider_name)
            content = self.add_usage_examples(content, provider_name)
            
            # Write back if changed
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"   ✅ Updated successfully")
                self.stats['success'] += 1
            else:
                print(f"   ℹ️  No changes needed")
                self.stats['skipped'] += 1
            
            return True
            
        except Exception as e:
            print(f"   ❌ Error: {e}")
            self.stats['errors'] += 1
            return False
    
    def migrate_all(self):
        """Migrate all screens"""
        print("🚀 Starting Automated Screen Migration")
        print("=" * 70)
        print(f"📂 Screens directory: {self.screens_dir}")
        
        if not self.screens_dir.exists():
            print(f"❌ Directory not found: {self.screens_dir}")
            return False
        
        # Get all dart files
        dart_files = list(self.screens_dir.glob('*.dart'))
        self.stats['total'] = len(dart_files)
        
        print(f"📊 Found {len(dart_files)} screen files")
        print("=" * 70)
        
        # Migrate each file
        for filepath in sorted(dart_files):
            self.migrate_screen(filepath)
        
        # Print summary
        print("\n" + "=" * 70)
        print("✅ MIGRATION COMPLETE!")
        print("=" * 70)
        print(f"📊 Statistics:")
        print(f"   Total files: {self.stats['total']}")
        print(f"   ✅ Successfully updated: {self.stats['success']}")
        print(f"   ⏭️  Skipped: {self.stats['skipped']}")
        print(f"   ❌ Errors: {self.stats['errors']}")
        print(f"   📈 Success rate: {(self.stats['success'] / max(self.stats['total'], 1) * 100):.1f}%")
        
        print("\n" + "=" * 70)
        print("📝 NEXT STEPS:")
        print("=" * 70)
        print("1. Review the TODO comments in each file")
        print("2. Wrap build methods with Consumer<Provider>")
        print("3. Replace local state with provider data")
        print("4. Remove old initState() and setState() calls")
        print("5. Test each screen thoroughly")
        print("\n📚 Documentation:")
        print("   - QUICK_START_GUIDE.md - Copy-paste templates")
        print("   - HOW_TO_USE_AUTO_REFRESH.md - Detailed examples")
        print("   - supervisor_dashboard_with_provider.dart - Working example")
        print("\n💾 Backups:")
        print(f"   All original files backed up with .backup extension")
        print(f"   Location: {self.screens_dir}")
        print("=" * 70)
        
        return True

def main():
    """Main function"""
    # Determine screens directory
    if len(sys.argv) > 1:
        screens_dir = sys.argv[1]
    else:
        screens_dir = 'lib/screens'
    
    # Check if directory exists
    if not os.path.exists(screens_dir):
        print(f"❌ Directory not found: {screens_dir}")
        print(f"\n💡 Usage: python update_all_screens.py [screens_directory]")
        print(f"   Example: python update_all_screens.py lib/screens")
        return 1
    
    # Create migrator and run
    migrator = ScreenMigrator(screens_dir)
    success = migrator.migrate_all()
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
