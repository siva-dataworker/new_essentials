#!/usr/bin/env python3
"""
Complete Screen Migration Script
Automatically implements the 4-step migration pattern for all screens
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

class CompleteMigrator:
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
    
    def wrap_build_with_consumer(self, content, provider_name):
        """Step 1: Wrap build method with Consumer"""
        # Find the build method
        build_pattern = r'(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{'
        build_match = re.search(build_pattern, content)
        
        if not build_match:
            return content, False
        
        # Check if already wrapped with Consumer
        if f'Consumer<{provider_name}>' in content:
            return content, False
        
        # Find the opening brace of build method
        build_start = build_match.end()
        
        # Find the return statement
        return_pattern = r'\s*return\s+'
        return_match = re.search(return_pattern, content[build_start:])
        
        if not return_match:
            return content, False
        
        return_pos = build_start + return_match.end()
        
        # Find the matching closing brace for the build method
        # We need to find where the build method ends
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
        
        # Extract the return statement content
        return_content = content[return_pos:build_end].strip()
        
        # Remove trailing semicolon if present
        if return_content.endswith(';'):
            return_content = return_content[:-1].strip()
        
        # Create the new build method with Consumer
        new_build = f'''  @override
  Widget build(BuildContext context) {{
    return Consumer<{provider_name}>(
      builder: (context, provider, child) {{
        return {return_content};
      }},
    );
  }}'''
        
        # Replace the old build method
        old_build = content[build_match.start():build_end + 1]
        content = content.replace(old_build, new_build, 1)
        
        return content, True
    
    def replace_local_variables(self, content, provider_name):
        """Step 2: Replace local state variables with provider data"""
        changes_made = False
        
        # Common variable replacements
        replacements = [
            (r'\b_sites\b', 'provider.sites'),
            (r'\b_isLoading\b', 'provider.isLoading'),
            (r'\b_error\b', 'provider.error'),
            (r'\b_areas\b', 'provider.areas'),
            (r'\b_streets\b', 'provider.streets'),
            (r'\b_materials\b', 'provider.materials'),
            (r'\b_entries\b', 'provider.entries'),
            (r'\b_documents\b', 'provider.documents'),
            (r'\b_complaints\b', 'provider.complaints'),
            (r'\b_todayEntries\b', 'provider.todayEntries'),
            (r'\b_historyData\b', 'provider.historyData'),
            (r'\b_bills\b', 'provider.bills'),
            (r'\b_agreements\b', 'provider.agreements'),
            (r'\b_reports\b', 'provider.reports'),
            (r'\b_workUpdates\b', 'provider.workUpdates'),
            (r'\b_photos\b', 'provider.photos'),
            (r'\b_budget\b', 'provider.budget'),
            (r'\b_profitLoss\b', 'provider.profitLoss'),
            (r'\b_progress\b', 'provider.progress'),
            (r'\b_estimations\b', 'provider.estimations'),
        ]
        
        # Only replace in build method and helper methods, not in state declarations
        for pattern, replacement in replacements:
            # Find all matches
            matches = list(re.finditer(pattern, content))
            
            for match in reversed(matches):  # Reverse to maintain positions
                # Check if this is not a declaration (not preceded by type or var/final)
                start = max(0, match.start() - 50)
                context_before = content[start:match.start()]
                
                # Skip if it's a declaration
                if re.search(r'(List|Map|String|bool|int|double|var|final|late)\s*<[^>]*>?\s*$', context_before):
                    continue
                
                # Skip if it's in a comment
                if '//' in context_before.split('\n')[-1]:
                    continue
                
                # Replace
                content = content[:match.start()] + replacement + content[match.end():]
                changes_made = True
        
        return content, changes_made
    
    def add_pull_to_refresh(self, content, provider_name):
        """Step 3: Add RefreshIndicator for pull-to-refresh"""
        changes_made = False
        
        # Check if RefreshIndicator already exists
        if 'RefreshIndicator' in content:
            return content, False
        
        # Find ListView, GridView, or SingleChildScrollView in build method
        scrollable_widgets = [
            r'ListView\.builder\s*\(',
            r'ListView\s*\(',
            r'GridView\.builder\s*\(',
            r'GridView\s*\(',
            r'SingleChildScrollView\s*\(',
            r'CustomScrollView\s*\(',
        ]
        
        for pattern in scrollable_widgets:
            matches = list(re.finditer(pattern, content))
            
            for match in reversed(matches):
                # Find the complete widget (matching parentheses)
                start = match.start()
                paren_count = 0
                i = match.end() - 1
                widget_end = -1
                
                while i < len(content):
                    if content[i] == '(':
                        paren_count += 1
                    elif content[i] == ')':
                        paren_count -= 1
                        if paren_count == 0:
                            widget_end = i + 1
                            break
                    i += 1
                
                if widget_end == -1:
                    continue
                
                # Check if this is inside the build method
                build_pattern = r'Widget\s+build\s*\(\s*BuildContext\s+context\s*\)'
                build_matches = list(re.finditer(build_pattern, content[:start]))
                
                if not build_matches:
                    continue
                
                # Extract the widget
                widget_content = content[start:widget_end]
                
                # Wrap with RefreshIndicator
                wrapped = f'''RefreshIndicator(
          onRefresh: () => provider.refreshData(),
          child: {widget_content},
        )'''
                
                content = content[:start] + wrapped + content[widget_end:]
                changes_made = True
                break
            
            if changes_made:
                break
        
        return content, changes_made
    
    def remove_old_code(self, content):
        """Step 4: Remove old initState, setState, and manual loading code"""
        changes_made = False
        
        # Remove state variable declarations
        state_vars = [
            r'^\s*List<[^>]+>\s+_sites\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_areas\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_streets\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_materials\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_entries\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_documents\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_complaints\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_bills\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_agreements\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_workUpdates\s*=\s*\[\];?\s*$',
            r'^\s*List<[^>]+>\s+_photos\s*=\s*\[\];?\s*$',
            r'^\s*Map<[^>]+>\s+_[a-zA-Z]+\s*=\s*\{\};?\s*$',
            r'^\s*bool\s+_isLoading\s*=\s*false;?\s*$',
            r'^\s*bool\s+_isLoading\s*=\s*true;?\s*$',
            r'^\s*String\?\s+_error;?\s*$',
            r'^\s*String\?\s+_selectedArea;?\s*$',
            r'^\s*String\?\s+_selectedStreet;?\s*$',
            r'^\s*String\?\s+_selectedSite;?\s*$',
        ]
        
        for pattern in state_vars:
            if re.search(pattern, content, re.MULTILINE):
                content = re.sub(pattern, '  // Removed: Using provider state', content, flags=re.MULTILINE)
                changes_made = True
        
        # Comment out initState method
        init_pattern = r'(@override\s+)?void\s+initState\s*\(\s*\)\s*\{[^}]*\}'
        if re.search(init_pattern, content, re.DOTALL):
            def comment_init(match):
                lines = match.group(0).split('\n')
                commented = '\n'.join('  // ' + line if line.strip() else line for line in lines)
                return f'\n  // REMOVED: initState - Provider handles initialization\n{commented}\n'
            
            content = re.sub(init_pattern, comment_init, content, flags=re.DOTALL)
            changes_made = True
        
        # Comment out manual loading methods
        load_methods = [
            r'Future<void>\s+_load[A-Z][a-zA-Z]*\s*\([^)]*\)\s*async\s*\{[^}]*\}',
            r'void\s+_load[A-Z][a-zA-Z]*\s*\([^)]*\)\s*\{[^}]*\}',
        ]
        
        for pattern in load_methods:
            matches = list(re.finditer(pattern, content, re.DOTALL))
            for match in reversed(matches):
                lines = match.group(0).split('\n')
                commented = '\n'.join('  // ' + line if line.strip() else line for line in lines)
                content = content[:match.start()] + f'\n  // REMOVED: Manual loading - Provider handles this\n{commented}\n' + content[match.end():]
                changes_made = True
        
        return content, changes_made
    
    def migrate_screen(self, filepath):
        """Migrate a single screen with all 4 steps"""
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
                'with_provider.dart',
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
            total_changes = 0
            
            # Step 1: Wrap build with Consumer
            print("   Step 1: Wrapping build method with Consumer...")
            content, changed = self.wrap_build_with_consumer(content, provider_name)
            if changed:
                print("      ✅ Build method wrapped")
                total_changes += 1
            else:
                print("      ℹ️  Already wrapped or no changes needed")
            
            # Step 2: Replace local variables
            print("   Step 2: Replacing local variables with provider data...")
            content, changed = self.replace_local_variables(content, provider_name)
            if changed:
                print("      ✅ Variables replaced")
                total_changes += 1
            else:
                print("      ℹ️  No variables to replace")
            
            # Step 3: Add pull-to-refresh
            print("   Step 3: Adding pull-to-refresh...")
            content, changed = self.add_pull_to_refresh(content, provider_name)
            if changed:
                print("      ✅ Pull-to-refresh added")
                total_changes += 1
            else:
                print("      ℹ️  Already has refresh or no scrollable widget")
            
            # Step 4: Remove old code
            print("   Step 4: Removing old initState/setState code...")
            content, changed = self.remove_old_code(content)
            if changed:
                print("      ✅ Old code removed/commented")
                total_changes += 1
            else:
                print("      ℹ️  No old code to remove")
            
            # Write back if changed
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"\n   ✅ Successfully migrated with {total_changes} changes!")
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
        print("🚀 Starting Complete Screen Migration")
        print("=" * 70)
        print(f"📂 Screens directory: {self.screens_dir}")
        print("=" * 70)
        
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
        print(f"   ✅ Successfully migrated: {self.stats['success']}")
        print(f"   ⏭️  Skipped: {self.stats['skipped']}")
        print(f"   ❌ Errors: {self.stats['errors']}")
        print(f"   📈 Success rate: {(self.stats['success'] / max(self.stats['total'], 1) * 100):.1f}%")
        
        print("\n" + "=" * 70)
        print("🎉 NEXT STEPS:")
        print("=" * 70)
        print("1. Test each screen to verify it works")
        print("2. Check for any compilation errors")
        print("3. Verify auto-refresh works (wait 30 seconds)")
        print("4. Test pull-to-refresh on each screen")
        print("5. Update MIGRATION_PROGRESS.md")
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
        print(f"\n💡 Usage: python complete_migration.py [screens_directory]")
        return 1
    
    migrator = CompleteMigrator(screens_dir)
    success = migrator.migrate_all()
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
