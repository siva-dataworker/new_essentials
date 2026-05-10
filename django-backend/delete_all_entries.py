"""
Delete All Material and Labour Entries
WARNING: This will permanently delete all labour and material entries from the database!
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

def confirm_deletion():
    """Ask for confirmation before deleting"""
    print("=" * 80)
    print("⚠️  WARNING: DELETE ALL ENTRIES")
    print("=" * 80)
    print()
    print("This script will PERMANENTLY DELETE:")
    print("  - All labour entries")
    print("  - All material entries")
    print()
    
    # Count current entries
    labour_count_query = "SELECT COUNT(*) as count FROM labour_entries"
    material_count_query = "SELECT COUNT(*) as count FROM material_usage"
    
    labour_result = fetch_all(labour_count_query)
    material_result = fetch_all(material_count_query)
    
    labour_count = labour_result[0]['count'] if labour_result else 0
    material_count = material_result[0]['count'] if material_result else 0
    
    print(f"📊 Current Counts:")
    print(f"   Labour Entries: {labour_count}")
    print(f"   Material Entries: {material_count}")
    print()
    
    if labour_count == 0 and material_count == 0:
        print("✅ No entries to delete!")
        return False
    
    print("⚠️  This action CANNOT be undone!")
    print()
    response = input("Type 'DELETE ALL' to confirm (or anything else to cancel): ")
    
    return response == 'DELETE ALL'

def delete_all_entries():
    """Delete all labour and material entries"""
    try:
        print()
        print("🗑️  Deleting all entries...")
        print()
        
        # Delete labour entries
        print("Deleting labour entries...")
        labour_delete_query = "DELETE FROM labour_entries"
        execute_query(labour_delete_query)
        print("✅ Labour entries deleted")
        
        # Delete material entries
        print("Deleting material entries...")
        material_delete_query = "DELETE FROM material_usage"
        execute_query(material_delete_query)
        print("✅ Material entries deleted")
        
        print()
        print("=" * 80)
        print("✅ ALL ENTRIES DELETED SUCCESSFULLY")
        print("=" * 80)
        print()
        
        # Verify deletion
        labour_result = fetch_all("SELECT COUNT(*) as count FROM labour_entries")
        material_result = fetch_all("SELECT COUNT(*) as count FROM material_usage")
        
        labour_count = labour_result[0]['count'] if labour_result else 0
        material_count = material_result[0]['count'] if material_result else 0
        
        print("📊 Final Counts:")
        print(f"   Labour Entries: {labour_count}")
        print(f"   Material Entries: {material_count}")
        print()
        
        if labour_count == 0 and material_count == 0:
            print("✅ Verification successful - all entries deleted")
        else:
            print("⚠️  Warning: Some entries may still exist")
        
    except Exception as e:
        print(f"❌ Error deleting entries: {e}")
        return False
    
    return True

def main():
    if confirm_deletion():
        delete_all_entries()
    else:
        print()
        print("❌ Deletion cancelled")
        print()

if __name__ == '__main__':
    main()
