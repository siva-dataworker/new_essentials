#!/usr/bin/env python
"""
Update budget_utilization_summary view to read from cash_entries table
This ensures budget utilization shows only accountant-confirmed entries
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_one

def update_budget_view():
    """Update the budget_utilization_summary view"""
    print("🔧 Updating budget_utilization_summary view...")
    print("   This will change labour cost source from labour_cost_calculation to cash_entries")
    print()
    
    # Read SQL file
    sql_file = os.path.join(os.path.dirname(__file__), 'update_budget_view_for_cash_entries.sql')
    with open(sql_file, 'r') as f:
        sql = f.read()
    
    try:
        # Execute SQL
        execute_query(sql)
        print("✅ View updated successfully!")
        print()
        
        # Verify view exists
        result = fetch_one("""
            SELECT COUNT(*) as count
            FROM information_schema.views
            WHERE table_name = 'budget_utilization_summary'
        """)
        
        if result and result['count'] > 0:
            print("✅ View verified in database")
            print()
            print("📊 What changed:")
            print("   BEFORE: Labour costs from labour_cost_calculation (raw entries)")
            print("   AFTER:  Labour costs from cash_entries (accountant-confirmed)")
            print()
            print("✅ Budget utilization will now show:")
            print("   - Only accountant-confirmed labour entries")
            print("   - Accurate cash expenditure")
            print("   - Correct labour costs")
            print()
            print("🔄 Next steps:")
            print("   1. Restart Django backend")
            print("   2. Refresh Budget Utilization screen in app")
            print("   3. Labour costs should now match cash_entries table")
        else:
            print("❌ View not found after update")
            
    except Exception as e:
        print(f"❌ Error updating view: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    update_budget_view()
