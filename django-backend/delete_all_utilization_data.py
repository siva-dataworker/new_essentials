import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one

print("=" * 80)
print("DELETE ALL UTILIZATION DATA")
print("=" * 80)

# Count current entries
labour_count = fetch_one("SELECT COUNT(*) as count FROM labour_entries")['count']
material_count = fetch_one("SELECT COUNT(*) as count FROM material_usage")['count']
cost_calc_count = fetch_one("SELECT COUNT(*) as count FROM labour_cost_calculation")['count']

print(f"\n📊 Current data:")
print(f"   Labour entries: {labour_count}")
print(f"   Material usage: {material_count}")
print(f"   Labour cost calculations: {cost_calc_count}")
print(f"   Total records: {labour_count + material_count + cost_calc_count}")

if labour_count == 0 and material_count == 0 and cost_calc_count == 0:
    print("\n✅ No utilization data to delete.")
    exit(0)

# Ask for confirmation
print("\n⚠️  WARNING: This will delete ALL utilization data:")
print("   - All labour entries")
print("   - All material usage records")
print("   - All labour cost calculations")
print("   - Cash entries linked to labour entries")
print("\n   This action cannot be undone!")
confirmation = input("\nType 'DELETE ALL' to confirm: ")

if confirmation != 'DELETE ALL':
    print("\n❌ Deletion cancelled.")
    exit(0)

print("\n🗑️  Deleting all utilization data...")

try:
    deleted_counts = {}
    
    # 1. Delete labour cost calculations (has FK to labour_entries)
    print("  - Deleting labour cost calculations...")
    execute_query("DELETE FROM labour_cost_calculation")
    deleted_counts['labour_cost_calculation'] = cost_calc_count
    
    # 2. Delete cash entries with labour entry references
    print("  - Deleting cash entries linked to labour entries...")
    cash_entries_result = fetch_one("SELECT COUNT(*) as count FROM cash_entries WHERE source_entry_id IS NOT NULL")
    cash_entries_count = cash_entries_result['count'] if cash_entries_result else 0
    execute_query("DELETE FROM cash_entries WHERE source_entry_id IS NOT NULL")
    deleted_counts['cash_entries'] = cash_entries_count
    
    # 3. Delete all labour entries
    print("  - Deleting labour entries...")
    execute_query("DELETE FROM labour_entries")
    deleted_counts['labour_entries'] = labour_count
    
    # 4. Delete all material usage
    print("  - Deleting material usage records...")
    execute_query("DELETE FROM material_usage")
    deleted_counts['material_usage'] = material_count
    
    # Verify deletion
    verify_labour = fetch_one("SELECT COUNT(*) as count FROM labour_entries")['count']
    verify_material = fetch_one("SELECT COUNT(*) as count FROM material_usage")['count']
    verify_cost = fetch_one("SELECT COUNT(*) as count FROM labour_cost_calculation")['count']
    
    print("\n✅ Deletion Summary:")
    print(f"   Labour entries deleted: {deleted_counts['labour_entries']}")
    print(f"   Material usage deleted: {deleted_counts['material_usage']}")
    print(f"   Labour cost calculations deleted: {deleted_counts['labour_cost_calculation']}")
    print(f"   Cash entries deleted: {deleted_counts['cash_entries']}")
    print(f"   Total records deleted: {sum(deleted_counts.values())}")
    
    if verify_labour == 0 and verify_material == 0 and verify_cost == 0:
        print("\n✅ All utilization data successfully deleted!")
    else:
        print(f"\n⚠️  Warning: Some records still remain:")
        if verify_labour > 0:
            print(f"   Labour entries: {verify_labour}")
        if verify_material > 0:
            print(f"   Material usage: {verify_material}")
        if verify_cost > 0:
            print(f"   Labour cost calculations: {verify_cost}")
        
except Exception as e:
    print(f"\n❌ Error deleting utilization data: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 80)
