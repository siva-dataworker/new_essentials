#!/usr/bin/env python3
"""
Safe Screen Migration Script
Handles StatefulWidget screens properly to avoid compilation errors
"""

import os
import re
import sys
from pathlib import Path
from datetime import datetime

# Provider mapping
PROVIDER_MAP = {
    'supervisor': 'SupervisorProvider',
    'accountant': 'AccountantProvider',
    'architect': 'ArchitectProvider',
    'site_engineer': 'SiteEngineerProvider',
    'admin': 'AdminProvider',
    'client': 'ClientProvider',
    'owner': 'AdminProvider',
}

class SafeMigrator:
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
        
        return 'ConstructionProvider'
    
    def add_provider_imports(self, content, provider_name):
        """Add provider imports if not present"""
        provider_file = provider_name.replace('Provider', '_provider').lower()
        
        # Check if already imported
        if f"import '../providers/{provider_file}.dart'" in content:
            return content, False
        
        # Find the last import statement
        import_pattern = r"import\s+['\"].*?['\"];"
        imports = list(re.finditer(import_pattern, content))
        
        if not imports:
            return content, False
        
        last_import = imports[-1]
        insert_pos = last_import.end()
        
        # Add provider package import if not present
        if 'package:provider/provider.dart' not in content:
            content = content[:insert_pos] + "\nimport 'package:provider/provider.dart';" + content[insert_pos:]
            insert_pos += len("\nimport 'package:provider/provider.dart';")
        
        # Add specific provider import
        provider_import = f"\nimport '../providers/{provider_file}.dart';"
        content = content[:insert_pos] + provider_import + content[insert_pos:]
        
        return content, True
    
    def wrap_build_safely(self, content, provider_name):
        """
        Safely wrap build method with Consumer
        This approach preserves all StatefulWidget functionality
        """
        # Find the build method
        build_pattern = r'(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{'
        build_match = re.search(build_pattern, content)
        
        if not build_match:
            return content, False
        
        # Check if already wrapped
        check_start = build_match.start()
        check_end = min(check_start + 1000, len(content))
        if f'Consumer<{provider_name}>' in content[check_start:check_end]:
            return content, False
        
        build_start = build_match.end()
        
        # Find the matching closing brace for the build method
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
        
        # Extract the entire build method body
        build_body = content[build_start:build_end]
        
        # Create new build method with Consumer wrapper
        # IMPORTANT: We keep the original context parameter name
        # and add provider as a new parameter in the Consumer builder
        new_build_body = f'''
    return Consumer<{provider_name}>(
      builder: (context, provider, child) {{
        // Original build method body
        {build_body.strip()}
      }},
    );
  '''
        
        # Replace the build method body
        new_content = content[:build_start] + new_build_body + content[build_end:]
        
        return new_content, True
    
    def replace_state_variables(self, content):
        """
        Replace local state variables with provider equivalents
        Only in safe contexts (not in declarations)
        """
        changes_made = False
        
        # Patterns to replace (only in usage, not declarations)
        replacements = [
            # Common patterns
            (r'(?<!List<[^>]*>\s)(?<!Map<[^>]*>\s)(?<!bool\s)(?<!String\?\s)(?<!int\s)(?<!double\s)\b_sites\b(?!\s*=\s*\[)', 'provider.sites'),
            (r'(?<!bool\s)\b_isLoading\b(?!\s*=)', 'provider.isLoading'),
            (r'(?<!String\?\s)\b_error\b(?!\s*=)', 'provider.error'),
            (r'(?<!List<[^>]*>\s)\b_areas\b(?!\s*=\s*\[)', 'provider.areas'),
            (r'(?<!List<[^>]*>\s)\b_streets\b(?!\s*=\s*\[)', 'provider.streets'),
            (r'(?<!List<[^>]*>\s)\b_materials\b(?!\s*=\s*\[)', 'provider.materials'),
            (r'(?<!List<[^>]*>\s)\b_entries\b(?!\s*=\s*\[)', 'provider.entries'),
            (r'(?<!List<[^>]*>\s)\b_documents\b(?!\s*=\s*\[)', 'provider.documents'),
            (r'(?<!List<[^>]*>\s)\b_complaints\b(?!\s*=\s*\[)', 'provider.complaints'),
            (r'(?<!Map<[^>]*>\s)\b_todayEntries\b(?!\s*=)', 'provider.todayEntries'),
            (r'(?<!Map<[^>]*>\s)\b_historyData\b(?!\s*=)', 'provider.historyData'),
        ]
        
        for pattern, replacement in replacements:
            if re.search(pattern, content):
                content = re.sub(pattern, replacement, content)
                changes_made = True
        
        return content, changes_made
    
    def add_migration_comment(self, content, provider_name):
        """Add helpful migration comment at the top of the State class"""
        # Find the State class
        state_class_pattern = r'(class\s+_\w+State\s+extends\s+State<\w+>\s*\{)'
        state_match = re.search(state_class_pattern, content)
        
        if not state_match:
            return content, False
        
        # Check if comment already exists
        if '// MIGRATED TO PROVIDER' in content:
            return content, False
        
        comment = f'''
  // ============================================================
  // MIGRATED TO PROVIDER PATTERN
  // Provider: {provider_name}
  // - Data loads automatically from provider
  // - Auto-refresh every 30 seconds
  // - Use provider.data instead of local _data variables
  // - Remove manual API calls from initState
  // ============================================================
  
'''
        
        insert_pos = state_match.end()
        content = content[:insert_pos] + comment + content[insert_pos:]
        
        return content, True
    
    def migrate_screen(self, filepath):
        """Migrate a single screen safely"""
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
                'with_provider.dart',
                '.backup',
            ]
            
            if any(skip in filename for skip in skip_files):
                print(f"⏭️  Skipped: {filename}")
                self.stats['skipped'] += 1
                return True
            
            provider_name = self.detect_provider(filename)
            
            print(f"\n{'='*70}")
            print(f"📝 Migrating: {filename}")
            print(f"   Provider: {provider_name}")
            print(f"{'='*70}")
            
            # Read file
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            changes = []
            
            # Step 1: Add provider imports
            print("   Step 1: Adding provider imports...")
            content, changed = self.add_provider_imports(content, provider_name)
            if changed:
                print("      ✅ Imports added")
                changes.append("imports")
            else:
                print("      ℹ️  Imports already present")
            
            # Step 2: Add migration comment
            print("   Step 2: Adding migration comment...")
            content, changed = self.add_migration_comment(content, provider_name)
            if changed:
                print("      ✅ Comment added")
                changes.append("comment")
            else:
                print("      ℹ️  Comment already present")
            
            # Step 3: Wrap build method with Consumer
            print("   Step 3: Wrapping build method with Consumer...")
            content, changed = self.wrap_build_safely(content, provider_name)
            if changed:
                print("      ✅ Build method wrapped")
                changes.append("consumer")
            else:
                print("      ℹ️  Already wrapped or couldn't wrap")
            
            # Step 4: Replace state variables (conservative)
            print("   Step 4: Replacing state variables...")
            content, changed = self.replace_state_variables(content)
            if changed:
                print("      ✅ Variables replaced")
                changes.append("variables")
            else:
                print("      ℹ️  No variables to replace")
            
            # Write back if changed
            if content != original_content:
                # Create backup
                backup_path = str(filepath) + '.backup3'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # Write new content
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"\n   ✅ Successfully migrated! Changes: {', '.join(changes)}")
                print(f"   💾 Backup saved: {os.path.basename(backup_path)}")
                self.stats['success'] += 1
            else:
                print(f"\n   ℹ️  No changes needed")
                self.stats['skipped'] += 1
            
            return True
            
        except Exception as e:
            print(f"\n   ❌ Error: {e}")
            import traceback
            traceback.print_exc()
            self.stats['errors'] += 1
            return False
    
    def migrate_all(self):
        """Migrate all screens"""
        print("🚀 Starting Safe Screen Migration")
        print("=" * 70)
        print(f"📂 Screens directory: {self.screens_dir}")
        print("=" * 70)
        print("\nThis script will:")
        print("1. Add provider imports")
        print("2. Add migration comments")
        print("3. Wrap build methods with Consumer")
        print("4. Replace state variables conservatively")
        print("5. Keep all StatefulWidget functionality intact")
        print("=" * 70)
        
        if not self.screens_dir.exists():
            print(f"❌ Directory not found: {self.screens_dir}")
            return False
        
        # Get all dart files
        dart_files = list(self.screens_dir.glob('*.dart'))
        self.stats['total'] = len(dart_files)
        
        print(f"\n📊 Found {len(dart_files)} screen files")
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
        print(f"   ✅ Successfully migrated: {self.stats['success']}")
        print(f"   ⏭️  Skipped: {self.stats['skipped']}")
        print(f"   ❌ Errors: {self.stats['errors']}")
        print(f"   📈 Success rate: {(self.stats['success'] / max(self.stats['total'], 1) * 100):.1f}%")
        
        print("\n" + "=" * 70)
        print("🎉 NEXT STEPS:")
        print("=" * 70)
        print("1. Run: flutter pub get")
        print("2. Check for compilation errors: flutter analyze")
        print("3. If there are errors, check the specific screens")
        print("4. You may need to manually adjust some screens")
        print("5. Run the app: flutter run -d chrome")
        print("6. Test each screen:")
        print("   - Data loads automatically")
        print("   - Wait 30 seconds - auto-refresh works")
        print("   - Pull down - manual refresh works")
        print("\n💾 All original files backed up with .backup3 extension")
        print("\n⚠️  IMPORTANT:")
        print("   - Some screens may still need manual adjustments")
        print("   - Check for 'TODO' comments in migrated files")
        print("   - Test thoroughly before deploying")
        print("=" * 70)
        
        return True

def main():
    """Main function"""
    if len(sys.argv) > 1:
        screens_dir = sys.argv[1]
    else:
        screens_dir = 'lib/screens'
    
    if not os.path.exists(screens_dir):
        print(f"❌ Directory not found: {screens_dir}")
        print(f"\n💡 Usage: python safe_migration.py [screens_directory]")
        return 1
    
    print("\n" + "=" * 70)
    print("⚠️  WARNING: This will modify your screen files!")
    print("=" * 70)
    print("Backups will be created with .backup3 extension")
    print("You can restore from backups if needed")
    print("=" * 70)
    
    response = input("\nContinue? (yes/no): ")
    if response.lower() not in ['yes', 'y']:
        print("Migration cancelled.")
        return 0
    
    migrator = SafeMigrator(screens_dir)
    success = migrator.migrate_all()
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
