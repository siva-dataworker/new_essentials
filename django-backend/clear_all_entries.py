#!/usr/bin/env python3
"""
Clear all labour and material entries from the database
This will delete ALL data across ALL roles for a fresh start
"""
import os
import django
from django.conf import settings

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all

def clear_all_entries():
    print("🗑️  CLEARING ALL LABOUR AND MATERIAL ENTRIES...")
    print("⚠️  This will delete ALL data across ALL roles!")
    
    try:
        # Get counts before deletion
        labour_count = fetch_all("SELECT COUNT(*) as count FROM labour_entries")[0]['count']
        material_count = fetch_all("SELECT COUNT(*) as count FROM material_balances")[0]['count']
        change_requests_count = fetch_all("SELECT COUNT(*) as count FROM change_requests")[0]['count']
        
        print(f"📊 Current data:")
        print(f"   - Labour entries: {labour_count}")
        print(f"   - Material entries: {material_count}")
        print(f"   - Change requests: {change_requests_count}")
        
        if labour_count == 0 and material_count == 0:
            print("✅ No data to delete - database is already clean!")
            return
        
        # Delete all change requests first (foreign key dependency)
        print("\n🗑️  Deleting change requests...")
        execute_query("DELETE FROM change_requests")
        print("✅ Change requests deleted")
        
        # Delete all labour entries
        print("\n🗑️  Deleting labour entries...")
        execute_query("DELETE FROM labour_entries")
        print("✅ Labour entries deleted")
        
        # Delete all material balances
        print("\n🗑️  Deleting material balances...")
        execute_query("DELETE FROM material_balances")
        print("✅ Material balances deleted")
        
        # Verify deletion
        labour_count_after = fetch_all("SELECT COUNT(*) as count FROM labour_entries")[0]['count']
        material_count_after = fetch_all("SELECT COUNT(*) as count FROM material_balances")[0]['count']
        change_requests_count_after = fetch_all("SELECT COUNT(*) as count FROM change_requests")[0]['count']
        
        print(f"\n📊 After deletion:")
        print(f"   - Labour entries: {labour_count_after}")
        print(f"   - Material entries: {material_count_after}")
        print(f"   - Change requests: {change_requests_count_after}")
        
        if labour_count_after == 0 and material_count_after == 0 and change_requests_count_after == 0:
            print("\n🎉 SUCCESS! All entries deleted successfully!")
            print("\n🚀 READY FOR FRESH TESTING:")
            print("   ✅ Daily restrictions will work properly")
            print("   ✅ IST timezone will be applied to new entries")
            print("   ✅ Today's entries dropdown will show clean data")
            print("   ✅ History will be empty until new entries are added")
        else:
            print("\n❌ Some entries may not have been deleted properly")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    clear_all_entries()
