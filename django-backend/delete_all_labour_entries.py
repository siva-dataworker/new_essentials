import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one

print("=" * 80)
print("DELETE ALL LABOUR ENTRIES")
print("=" * 80)

# Count current entries
count_result = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
current_count = count_result['count'] if count_result else 0

print(f"\n📊 Current labour entries: {current_count}")

if current_count == 0:
    print("\n✅ No labour entries to delete.")
    exit(0)

# Ask for confirmation
print("\n⚠️  WARNING: This will delete ALL labour entries from the database!")
print("   This action cannot be undone.")
confirmation = input("\nType 'DELETE ALL' to confirm: ")

if confirmation != 'DELETE ALL':
    print("\n❌ Deletion cancelled.")
    exit(0)

print("\n🗑️  Deleting all labour entries...")

try:
    # Delete related records first (if any foreign key constraints)
    
    # Delete from labour_cost_calculation (has FK to labour_entries)
    print("  - Deleting labour cost calculations...")
    execute_query("DELETE FROM labour_cost_calculation")
    
    # Delete from cash_entries if they reference labour_entries
    print("  - Deleting cash entries with labour entry references...")
    execute_query("DELETE FROM cash_entries WHERE source_entry_id IS NOT NULL")
    
    # Delete all labour entries
    print("  - Deleting labour entries...")
    execute_query("DELETE FROM labour_entries")
    
    # Verify deletion
    verify_result = fetch_one("SELECT COUNT(*) as count FROM labour_entries")
    remaining = verify_result['count'] if verify_result else 0
    
    if remaining == 0:
        print(f"\n✅ Successfully deleted {current_count} labour entries!")
        print("   All related records have been cleaned up.")
    else:
        print(f"\n⚠️  Warning: {remaining} entries still remain.")
        
except Exception as e:
    print(f"\n❌ Error deleting labour entries: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 80)
