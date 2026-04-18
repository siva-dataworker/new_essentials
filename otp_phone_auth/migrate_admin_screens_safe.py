#!/usr/bin/env python3
"""
Safe Admin Screens Migration Script
Migrates admin screens to use AdminProvider with careful validation
"""

import os
import re
import shutil
import subprocess
from pathlib import Path
from datetime import datetime

# Configuration
SCREENS_DIR = Path("lib/screens")
BACKUP_SUFFIX = ".backup_safe"
LOG_FILE = "migration_safe.log"

# Admin screens to migrate
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
    "admin_sites_test_screen.dart",
]

# Skip login screen
SKIP_SCREENS = ["admin_specialized_login_screen.dart"]

class MigrationLogger:
    def __init__(self, log_file):
        self.log_file = log_file
        self.logs = []
        
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}"
        self.logs.append(log_entry)
        print(log_entry)
        
    def save(self):
        with open(self.log_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(self.logs))

logger = MigrationLogger(LOG_FILE)

def backup_file(file_path):
    """Create a backup of the file"""
    backup_path = str(file_path) + BACKUP_SUFFIX
    shutil.copy2(file_path, backup_path)
    logger.log(f"Backed up: {file_path.name}")
    return backup_path

def restore_file(file_path, backup_path):
    """Restore file from backup"""
    shutil.copy2(backup_path, file_path)
    logger.log(f"Restored: {file_path.name}", "WARNING")

def check_syntax(file_path):
    """Check if file has syntax errors using flutter analyze"""
    try:
        result = subprocess.run(
            ["flutter", "analyze", str(file_path)],
            capture_output=True,
            text=True,
            timeout=30
        )
        # Check for errors (not warnings)
        if "error" in result.stdout.lower() or "error" in result.stderr.lower():
            return False, result.stdout + result.stderr
        return True, "OK"
    except Exception as e:
        logger.log(f"Syntax check failed: {e}", "ERROR")
        return False, str(e)

def add_imports(content, file_name):
    """Add provider imports if not present"""
    if "import '../providers/admin_provider.dart';" in content:
        logger.log(f"{file_name}: Imports already present")
        return content, False
    
    # Find the last import statement
    import_pattern = r"(import\s+['\"].*?['\"];)"
    imports = list(re.finditer(import_pattern, content))
    
    if not imports:
        logger.log(f"{file_name}: No imports found", "WARNING")
        return content, False
    
    last_import = imports[-1]
    insert_pos = last_import.end()
    
    new_imports = "\nimport 'package:provider/provider.dart';\nimport '../providers/admin_provider.dart';"
    
    new_content = content[:insert_pos] + new_imports + content[insert_pos:]
    logger.log(f"{file_name}: Added imports")
    return new_content, True

def wrap_build_with_consumer(content, file_name):
    """Wrap build method with Consumer<AdminProvider>"""
    
    # Check if already wrapped
    if "Consumer<AdminProvider>" in content:
        logger.log(f"{file_name}: Already wrapped with Consumer")
        return content, False
    
    # Find the build method
    # Pattern: @override\n  Widget build(BuildContext context) {\n    return
    build_pattern = r"(@override\s+Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{)\s*(return\s+)"
    
    match = re.search(build_pattern, content, re.MULTILINE | re.DOTALL)
    if not match:
        logger.log(f"{file_name}: Could not find build method", "WARNING")
        return content, False
    
    # Find the matching closing brace for the build method
    # This is complex, so we'll use a simpler approach:
    # Just wrap the return statement
    
    build_start = match.start(2)  # Start of 'return'
    
    # Find the widget being returned (Scaffold, Consumer, etc.)
    # Look for the pattern: return WidgetName(
    return_widget_pattern = r"return\s+(\w+)\s*\("
    widget_match = re.search(return_widget_pattern, content[build_start:])
    
    if not widget_match:
        logger.log(f"{file_name}: Could not find return widget", "WARNING")
        return content, False
    
    widget_name = widget_match.group(1)
    logger.log(f"{file_name}: Found return widget: {widget_name}")
    
    # Find the closing of the build method
    # Count braces to find the matching closing brace
    brace_count = 0
    build_method_start = match.start(1)
    i = build_method_start
    start_counting = False
    
    while i < len(content):
        if content[i] == '{':
            brace_count += 1
            start_counting = True
        elif content[i] == '}':
            brace_count -= 1
            if start_counting and brace_count == 0:
                build_method_end = i
                break
        i += 1
    else:
        logger.log(f"{file_name}: Could not find build method end", "WARNING")
        return content, False
    
    # Extract the build method content
    build_content = content[build_start:build_method_end]
    
    # Wrap with Consumer
    wrapped_content = f"""return Consumer<AdminProvider>(
      builder: (context, provider, child) {{
        {build_content.strip()}
      }},
    );"""
    
    # Replace in original content
    new_content = content[:build_start] + wrapped_content + content[build_method_end:]
    
    logger.log(f"{file_name}: Wrapped build method with Consumer")
    return new_content, True

def replace_state_variables(content, file_name):
    """Replace local state variables with provider equivalents"""
    
    replacements = [
        # Sites
        (r'\b_sites\b', 'provider.sites'),
        (r'\bsites\b(?!\()', 'provider.sites'),  # Avoid replacing sites()
        
        # Loading states
        (r'\b_isLoading\b', 'provider.isLoadingSites'),
        (r'\b_sitesLoading\b', 'provider.isLoadingSites'),
        (r'\bisLoading\b', 'provider.isLoadingSites'),
        
        # Error states
        (r'\b_error\b', 'provider.error'),
        (r'\berror\b', 'provider.error'),
    ]
    
    modified = False
    new_content = content
    
    for pattern, replacement in replacements:
        if re.search(pattern, new_content):
            # Only replace in non-comment, non-string contexts
            # This is a simplified approach
            count = len(re.findall(pattern, new_content))
            new_content = re.sub(pattern, replacement, new_content)
            if count > 0:
                logger.log(f"{file_name}: Replaced {count} occurrences of {pattern}")
                modified = True
    
    return new_content, modified

def comment_out_initstate(content, file_name):
    """Comment out initState method that loads data"""
    
    # Find initState method
    initstate_pattern = r"(@override\s+void\s+initState\s*\(\s*\)\s*\{[^}]*\})"
    
    matches = list(re.finditer(initstate_pattern, content, re.MULTILINE | re.DOTALL))
    
    if not matches:
        logger.log(f"{file_name}: No initState found")
        return content, False
    
    modified = False
    new_content = content
    
    for match in matches:
        initstate_code = match.group(1)
        
        # Check if it contains loading calls
        if any(keyword in initstate_code for keyword in ['_load', 'load', 'fetch', 'get']):
            # Comment it out
            commented = "/* MIGRATED TO PROVIDER\n" + initstate_code + "\n*/"
            new_content = new_content.replace(initstate_code, commented)
            logger.log(f"{file_name}: Commented out initState")
            modified = True
    
    return new_content, modified

def comment_out_manual_loading(content, file_name):
    """Comment out manual loading methods"""
    
    # Find methods that look like loading methods
    loading_pattern = r"(Future<void>\s+_load\w+\s*\([^)]*\)\s*async\s*\{[^}]*\})"
    
    matches = list(re.finditer(loading_pattern, content, re.MULTILINE | re.DOTALL))
    
    if not matches:
        logger.log(f"{file_name}: No manual loading methods found")
        return content, False
    
    modified = False
    new_content = content
    
    for match in matches:
        loading_code = match.group(1)
        
        # Comment it out
        commented = "/* MIGRATED TO PROVIDER\n" + loading_code + "\n*/"
        new_content = new_content.replace(loading_code, commented)
        logger.log(f"{file_name}: Commented out loading method")
        modified = True
    
    return new_content, modified

def migrate_screen(file_path):
    """Migrate a single screen file"""
    logger.log(f"\n{'='*60}")
    logger.log(f"Migrating: {file_path.name}")
    logger.log(f"{'='*60}")
    
    # Read original content
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
    except Exception as e:
        logger.log(f"Failed to read {file_path.name}: {e}", "ERROR")
        return False
    
    # Create backup
    backup_path = backup_file(file_path)
    
    # Apply migrations step by step
    content = original_content
    any_changes = False
    
    # Step 1: Add imports
    content, changed = add_imports(content, file_path.name)
    any_changes = any_changes or changed
    
    # Step 2: Wrap build with Consumer
    content, changed = wrap_build_with_consumer(content, file_path.name)
    any_changes = any_changes or changed
    
    # Step 3: Replace state variables
    content, changed = replace_state_variables(content, file_path.name)
    any_changes = any_changes or changed
    
    # Step 4: Comment out initState
    content, changed = comment_out_initstate(content, file_path.name)
    any_changes = any_changes or changed
    
    # Step 5: Comment out manual loading
    content, changed = comment_out_manual_loading(content, file_path.name)
    any_changes = any_changes or changed
    
    if not any_changes:
        logger.log(f"{file_path.name}: No changes needed")
        return True
    
    # Write modified content
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        logger.log(f"{file_path.name}: Changes written")
    except Exception as e:
        logger.log(f"Failed to write {file_path.name}: {e}", "ERROR")
        restore_file(file_path, backup_path)
        return False
    
    # Check syntax
    logger.log(f"{file_path.name}: Checking syntax...")
    syntax_ok, error_msg = check_syntax(file_path)
    
    if not syntax_ok:
        logger.log(f"{file_path.name}: Syntax errors detected!", "ERROR")
        logger.log(f"Error: {error_msg[:200]}", "ERROR")
        restore_file(file_path, backup_path)
        return False
    
    logger.log(f"{file_path.name}: ✅ Migration successful!")
    return True

def main():
    """Main migration function"""
    logger.log("="*60)
    logger.log("SAFE ADMIN SCREENS MIGRATION")
    logger.log("="*60)
    logger.log(f"Timestamp: {datetime.now()}")
    logger.log(f"Screens directory: {SCREENS_DIR}")
    logger.log(f"Backup suffix: {BACKUP_SUFFIX}")
    logger.log("")
    
    # Check if screens directory exists
    if not SCREENS_DIR.exists():
        logger.log(f"Screens directory not found: {SCREENS_DIR}", "ERROR")
        return
    
    # Get list of admin screens
    screens_to_migrate = []
    for screen_name in ADMIN_SCREENS:
        if screen_name in SKIP_SCREENS:
            logger.log(f"Skipping: {screen_name}")
            continue
        
        screen_path = SCREENS_DIR / screen_name
        if screen_path.exists():
            screens_to_migrate.append(screen_path)
        else:
            logger.log(f"Not found: {screen_name}", "WARNING")
    
    logger.log(f"\nFound {len(screens_to_migrate)} screens to migrate")
    logger.log("")
    
    # Migrate each screen
    successful = 0
    failed = 0
    
    for screen_path in screens_to_migrate:
        if migrate_screen(screen_path):
            successful += 1
        else:
            failed += 1
    
    # Summary
    logger.log("\n" + "="*60)
    logger.log("MIGRATION SUMMARY")
    logger.log("="*60)
    logger.log(f"Total screens: {len(screens_to_migrate)}")
    logger.log(f"Successful: {successful}")
    logger.log(f"Failed: {failed}")
    logger.log("")
    
    if failed > 0:
        logger.log("⚠️  Some migrations failed. Check the log for details.", "WARNING")
        logger.log("Failed screens have been restored from backup.", "WARNING")
    else:
        logger.log("✅ All migrations successful!")
    
    logger.log(f"\nLog saved to: {LOG_FILE}")
    logger.save()

if __name__ == "__main__":
    main()
