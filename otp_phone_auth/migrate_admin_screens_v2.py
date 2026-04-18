#!/usr/bin/env python3
"""
Admin Screens Migration Script v2
Migrates admin screens to use AdminProvider with proper variable replacement
"""

import os
import re
import shutil
from pathlib import Path

# Configuration
SCREENS_DIR = Path("lib/screens")
BACKUP_SUFFIX = ".backup_v2"

# Admin screens to migrate (excluding login and already migrated)
ADMIN_SCREENS = [
    "admin_bills_view_screen.dart",
    "admin_budget_management_screen.dart",
    "admin_client_complaints_screen.dart",
    "admin_dashboard.dart",
    "admin_labour_count_screen.dart",
    "admin_labour_count_screen_improved.dart",
    "admin_labour_rates_screen.dart",
    "admin_material_purchases_screen.dart",
    "admin_profit_loss_improved.dart",
    "admin_profit_loss_screen.dart",
    "admin_site_comparison_screen.dart",
    "admin_site_documents_screen.dart",
    "admin_site_full_view.dart",
    # admin_sites_test_screen.dart - already migrated manually
    # admin_specialized_login_screen.dart - skip (login screen)
]

def create_backup(file_path):
    """Create a backup of the file"""
    backup_path = str(file_path) + BACKUP_SUFFIX
    shutil.copy2(file_path, backup_path)
    print(f"  ✅ Backup created: {backup_path}")
    return backup_path

def check_if_already_migrated(content):
    """Check if file already has Consumer<AdminProvider>"""
    return "Consumer<AdminProvider>" in content

def add_provider_imports(content):
    """Add provider imports if not present"""
    has_provider_import = "package:provider/provider.dart" in content
    has_admin_provider_import = "../providers/admin_provider.dart" in content
    
    if has_provider_import and has_admin_provider_import:
        return content, False
    
    # Find the last import statement
    import_pattern = r"(import\s+['\"].*?['\"];)"
    imports = list(re.finditer(import_pattern, content))
    
    if not imports:
        return content, False
    
    last_import = imports[-1]
    insert_pos = last_import.end()
    
    new_imports = []
    if not has_provider_import:
        new_imports.append("\nimport 'package:provider/provider.dart';")
    if not has_admin_provider_import:
        new_imports.append("\nimport '../providers/admin_provider.dart';")
    
    if new_imports:
        content = content[:insert_pos] + "".join(new_imports) + content[insert_pos:]
        return content, True
    
    return content, False

def wrap_build_with_consumer(content):
    """Wrap the build method with Consumer<AdminProvider>"""
    # Pattern to find the build method
    build_pattern = r"(@override\s+Widget\s+build\(BuildContext\s+context\)\s*\{)"
    
    match = re.search(build_pattern, content)
    if not match:
        return content, False
    
    # Check if already wrapped
    if "Consumer<AdminProvider>" in content[match.end():match.end()+200]:
        return content, False
    
    # Find the return statement after build method
    build_start = match.end()
    
    # Find the matching closing brace for the build method
    # This is complex, so we'll use a simpler approach:
    # Insert Consumer right after the opening brace
    
    insert_code = """
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return """
    
    # Find the return statement
    return_match = re.search(r"\s*return\s+", content[build_start:])
    if not return_match:
        return content, False
    
    return_pos = build_start + return_match.start()
    
    # Insert the Consumer wrapper
    content = content[:return_pos] + insert_code + content[return_pos + return_match.end():]
    
    # Now we need to close the Consumer before the build method closes
    # Find the closing brace of the build method
    # This is tricky, so we'll add a note for manual review
    
    return content, True

def replace_state_variables(content):
    """Replace local state variables with provider equivalents"""
    replacements = [
        # Sites related
        (r'\b_sites\b', 'adminProvider.sites'),
        (r'\b_isLoading\b', 'adminProvider.isLoadingSites'),
        (r'\b_sitesLoading\b', 'adminProvider.isLoadingSites'),
        
        # Loading states
        (r'\badminProvider\.isLoadingSites\s*=\s*true', '// Loading handled by provider'),
        (r'\badminProvider\.isLoadingSites\s*=\s*false', '// Loading handled by provider'),
        
        # Method calls
        (r'_loadSites\(\)', 'adminProvider.loadSites(forceRefresh: true)'),
    ]
    
    modified = False
    for pattern, replacement in replacements:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            modified = True
            content = new_content
    
    return content, modified

def comment_out_old_code(content):
    """Comment out old initState loading and setState calls"""
    # This is complex and risky, so we'll just add markers
    # for manual review instead
    
    # Add a comment at the top of initState if it exists
    init_pattern = r"(@override\s+void\s+initState\(\)\s*\{)"
    match = re.search(init_pattern, content)
    
    if match:
        insert_pos = match.end()
        comment = "\n    // TODO: Review and remove manual loading - now using AdminProvider\n"
        content = content[:insert_pos] + comment + content[insert_pos:]
        return content, True
    
    return content, False

def migrate_screen(screen_file):
    """Migrate a single screen file"""
    file_path = SCREENS_DIR / screen_file
    
    if not file_path.exists():
        print(f"  ⚠️  File not found: {file_path}")
        return False
    
    print(f"\n📄 Migrating: {screen_file}")
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already migrated
    if check_if_already_migrated(content):
        print(f"  ⏭️  Already migrated (has Consumer<AdminProvider>)")
        return True
    
    # Create backup
    create_backup(file_path)
    
    # Track if any changes were made
    changes_made = []
    
    # Step 1: Add provider imports
    content, modified = add_provider_imports(content)
    if modified:
        changes_made.append("Added provider imports")
    
    # Step 2: Replace state variables
    content, modified = replace_state_variables(content)
    if modified:
        changes_made.append("Replaced state variables")
    
    # Step 3: Comment out old code
    content, modified = comment_out_old_code(content)
    if modified:
        changes_made.append("Added TODO comments")
    
    # Write the modified content
    if changes_made:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"  ✅ Changes made:")
        for change in changes_made:
            print(f"     - {change}")
        
        print(f"  ⚠️  MANUAL REVIEW REQUIRED:")
        print(f"     - Wrap build method with Consumer<AdminProvider>")
        print(f"     - Update method signatures to accept adminProvider parameter")
        print(f"     - Remove old setState() calls")
        print(f"     - Test the screen thoroughly")
        
        return True
    else:
        print(f"  ℹ️  No automatic changes needed")
        return False

def main():
    """Main migration function"""
    print("=" * 60)
    print("Admin Screens Migration Script v2")
    print("=" * 60)
    print(f"\nScreens directory: {SCREENS_DIR}")
    print(f"Screens to migrate: {len(ADMIN_SCREENS)}")
    print(f"Backup suffix: {BACKUP_SUFFIX}")
    
    # Check if directory exists
    if not SCREENS_DIR.exists():
        print(f"\n❌ Error: Directory not found: {SCREENS_DIR}")
        return
    
    # Confirm before proceeding
    print("\n⚠️  This script will:")
    print("   1. Create backups of all files")
    print("   2. Add provider imports")
    print("   3. Replace some state variables")
    print("   4. Add TODO comments for manual review")
    print("\n⚠️  You will need to manually:")
    print("   1. Wrap build methods with Consumer<AdminProvider>")
    print("   2. Update method signatures")
    print("   3. Remove old setState() calls")
    print("   4. Test each screen")
    
    response = input("\nProceed? (yes/no): ").strip().lower()
    if response != 'yes':
        print("\n❌ Migration cancelled")
        return
    
    # Migrate each screen
    print("\n" + "=" * 60)
    print("Starting migration...")
    print("=" * 60)
    
    migrated = 0
    skipped = 0
    errors = 0
    
    for screen_file in ADMIN_SCREENS:
        try:
            if migrate_screen(screen_file):
                migrated += 1
            else:
                skipped += 1
        except Exception as e:
            print(f"  ❌ Error: {e}")
            errors += 1
    
    # Summary
    print("\n" + "=" * 60)
    print("Migration Summary")
    print("=" * 60)
    print(f"✅ Migrated: {migrated}")
    print(f"⏭️  Skipped: {skipped}")
    print(f"❌ Errors: {errors}")
    print(f"📊 Total: {len(ADMIN_SCREENS)}")
    
    if migrated > 0:
        print("\n⚠️  IMPORTANT: Manual steps required!")
        print("   1. Review each migrated file")
        print("   2. Wrap build methods with Consumer<AdminProvider>")
        print("   3. Update method signatures to accept adminProvider")
        print("   4. Remove old setState() calls")
        print("   5. Test each screen thoroughly")
        print(f"\n💾 Backups saved with suffix: {BACKUP_SUFFIX}")
        print("   To restore: cp file.dart{} file.dart".format(BACKUP_SUFFIX))
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
