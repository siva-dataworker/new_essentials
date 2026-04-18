#!/usr/bin/env python3
"""
Final Screen Migration Script - Careful Implementation
Updates all Flutter screens to use Provider pattern with auto-refresh
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

class CarefulMigrator:
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
    
    def has_provider_import(self, content, provider_name):
        """Check if provider is already imported"""
        provider_file = provider_name.replace('Provider', '_provider').lower()
        return f"import '../providers/{provider_file}.dart'" in content or \
               f'import "../providers/{provider_file}.dart"' in content
    
    def add_provider_imports(self, content, provider_name):
        """Add provider imports if not present"""
        if self.has_provider_import(content, provider_name):
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
        provider_file = provider_name.replace('Provider', '_provider').lower()
        provider_import = f"\nimport '../providers/{provider_file}.dart';"
        content = content[:insert_pos] + provider_import + content[insert_pos:]
        
        return content, True
    
    def is_stateless_widget(self, content):
        """Check if this is a StatelessWidget"""
        return 'extends StatelessWidget' in content
    
    def wrap_stateless_build(self, content, provider_name):
        """Wrap StatelessWidget build method with Consumer"""
        # Find the build method
        build_pattern = r'(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{'
        build_match = re.search(build_pattern, content)
        
        if not build_match:
            return content, False
        
        # Check if already wrapped
        if f'Consumer<{provider_name}>' in content[build_match.start():build_match.start()+500]:
            return content, False
        
        # Find the return statement after build
        build_end = build_match.end()
        
        # Find the first 'return' after the opening brace
        return_match = re.search(r'\s*return\s+', content[build_end:])
        if not return_match:
            return content, False
        
        return_start = build_end + return_match.end()
        
        # Find the semicolon that ends the return statement
        # We need to match braces/parentheses properly
        brace_count = 0
        paren_count = 0
        bracket_count = 0
        i = return_start
        return_end = -1
        
        while i < len(content):
            char = content[i]
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
            elif char == '(':
                paren_count += 1
            elif char == ')':
                paren_count -= 1
            elif char == '[':
                bracket_count += 1
            elif char == ']':
                bracket_count -= 1
            elif char == ';' and brace_count == 0 and paren_count == 0 and bracket_count == 0:
                return_end = i
                break
            i += 1
        
        if return_end == -1:
            return content, False
        
        # Extract the widget being returned
        returned_widget = content[return_start:return_end].strip()
        
        # Create the new return statement with Consumer
        new_return = f'''return Consumer<{provider_name}>(
      builder: (context, provider, child) {{
        return {returned_widget};
      }},
    );'''
        
        # Replace the old return statement
        content = content[:build_end] + '\n    ' + new_return + content[return_end+1:]
        
        return content, True
    
    def wrap_stateful_build(self, content, provider_name):
        """Wrap StatefulWidget build method with Consumer"""
        # Find the State class
        state_class_pattern = r'class\s+_\w+State\s+extends\s+State<\w+>'
        state_match = re.search(state_class_pattern, content)
        
        if not state_match:
            return content, False
        
        # Find the build method after the State class
        build_pattern = r'(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{'
        build_match = re.search(build_pattern, content[state_match.end():])
        
        if not build_match:
            return content, False
        
        build_start = state_match.end() + build_match.start()
        build_body_start = state_match.end() + build_match.end()
        
        # Check if already wrapped
        if f'Consumer<{provider_name}>' in content[build_start:build_start+500]:
            return content, False
        
        # Find the return statement
        return_match = re.search(r'\s*return\s+', content[build_body_start:])
        if not return_match:
            return content, False
        
        return_start = build_body_start + return_match.end()
        
        # Find the semicolon that ends the return statement
        brace_count = 0
        paren_count = 0
        bracket_count = 0
        i = return_start
        return_end = -1
        
        while i < len(content):
            char = content[i]
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
            elif char == '(':
                paren_count += 1
            elif char == ')':
                paren_count -= 1
            elif char == '[':
                bracket_count += 1
            elif char == ']':
                bracket_count -= 1
            elif char == ';' and brace_count == 0 and paren_count == 0 and bracket_count == 0:
                return_end = i
                break
            i += 1
        
        if return_end == -1:
            return content, False
        
        # Extract the widget being returned
        returned_widget = content[return_start:return_end].strip()
        
        # Create the new return statement with Consumer
        new_return = f'''return Consumer<{provider_name}>(
      builder: (context, provider, child) {{
        return {returned_widget};
      }},
    );'''
        
        # Replace the old return statement
        content = content[:build_body_start] + '\n    ' + new_return + content[return_end+1:]
        
        return content, True
    
    def comment_out_initstate(self, content):
        """Comment out initState method"""
        # Find initState method
        init_pattern = r'(@override\s+)?void\s+initState\s*\(\s*\)\s*\{[^}]*(?:\{[^}]*\}[^}]*)*\}'
        
        def comment_block(match):
            block = match.group(0)
            lines = block.split('\n')
            commented = '\n'.join('  // ' + line if line.strip() else line for line in lines)
            return f'\n  // REMOVED: initState - Provider handles initialization\n{commented}\n'
        
        if re.search(init_pattern, content, re.DOTALL):
            content = re.sub(init_pattern, comment_block, content, flags=re.DOTALL, count=1)
            return content, True
        
        return content, False
    
    def comment_out_load_methods(self, content):
        """Comment out manual loading methods"""
        # Pattern for load methods
        load_pattern = r'(Future<void>|void)\s+(_load[A-Z]\w*)\s*\([^)]*\)\s*(?:async\s*)?\{(?:[^{}]|\{[^{}]*\})*\}'
        
        def comment_method(match):
            method = match.group(0)
            lines = method.split('\n')
            commented = '\n'.join('  // ' + line if line.strip() else line for line in lines)
            return f'\n  // REMOVED: Manual loading - Provider handles this\n{commented}\n'
        
        matches = list(re.finditer(load_pattern, content, re.DOTALL))
        if matches:
            # Process in reverse to maintain positions
            for match in reversed(matches):
                content = content[:match.start()] + comment_method(match) + content[match.end():]
            return content, True
        
        return content, False
    
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
            
            # Step 2: Wrap build method with Consumer
            print("   Step 2: Wrapping build method with Consumer...")
            if self.is_stateless_widget(content):
                content, changed = self.wrap_stateless_build(content, provider_name)
            else:
                content, changed = self.wrap_stateful_build(content, provider_name)
            
            if changed:
                print("      ✅ Build method wrapped")
                changes.append("consumer")
            else:
                print("      ℹ️  Already wrapped or couldn't wrap")
            
            # Step 3: Comment out initState
            print("   Step 3: Commenting out initState...")
            content, changed = self.comment_out_initstate(content)
            if changed:
                print("      ✅ initState commented out")
                changes.append("initState")
            else:
                print("      ℹ️  No initState found")
            
            # Step 4: Comment out load methods
            print("   Step 4: Commenting out load methods...")
            content, changed = self.comment_out_load_methods(content)
            if changed:
                print("      ✅ Load methods commented out")
                changes.append("loadMethods")
            else:
                print("      ℹ️  No load methods found")
            
            # Write back if changed
            if content != original_content:
                # Create backup
                backup_path = str(filepath) + '.backup2'
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
        print("🚀 Starting Final Screen Migration")
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
        print("1. Run: flutter pub get")
        print("2. Check for compilation errors: flutter analyze")
        print("3. Run the app: flutter run -d chrome")
        print("4. Test each screen:")
        print("   - Data loads automatically")
        print("   - Wait 30 seconds - auto-refresh works")
        print("   - Pull down - manual refresh works")
        print("\n💾 All original files backed up with .backup2 extension")
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
        print(f"\n💡 Usage: python migrate_screens_final.py [screens_directory]")
        return 1
    
    migrator = CarefulMigrator(screens_dir)
    success = migrator.migrate_all()
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
