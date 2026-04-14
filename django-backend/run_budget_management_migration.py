import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

print("=" * 60)
print("CREATING BUDGET MANAGEMENT SYSTEM")
print("=" * 60)

# Read SQL file
with open('create_budget_management_system.sql', 'r') as f:
    sql = f.read()

# Execute SQL
try:
    with connection.cursor() as cursor:
        cursor.execute(sql)
    
    print("\n✅ Budget Management System created successfully!")
    
    # Verify tables
    from api.database import fetch_all
    
    tables = [
        'site_budget_allocation',
        'labour_salary_rates',
        'material_cost_tracking',
        'labour_cost_calculation'
    ]
    
    print("\n📊 Verifying tables...")
    for table in tables:
        cols = fetch_all(f"""
            SELECT COUNT(*) as count
            FROM information_schema.columns
            WHERE table_name = '{table}'
        """)
        print(f"  ✅ {table}: {cols[0]['count']} columns")
    
    print("\n" + "=" * 60)
    print("✅ MIGRATION COMPLETE!")
    print("=" * 60)
    print("\nNew Features:")
    print("1. Site Budget Allocation")
    print("2. Labour Salary Rates")
    print("3. Material Cost Tracking")
    print("4. Auto Labour Cost Calculation")
    print("5. Budget Utilization Summary View")
    print("6. Auto Budget Status Updates")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
