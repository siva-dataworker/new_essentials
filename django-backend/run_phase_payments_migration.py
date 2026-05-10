"""
Run Phase Payments Migration
This script creates the budget_phase_payments table and adds client_balance column
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query, fetch_all, fetch_one

def run_migration():
    """Run the phase payments migration"""
    print("\n" + "="*60)
    print("PHASE PAYMENTS MIGRATION")
    print("="*60)
    
    try:
        # Step 1: Create budget_phase_payments table
        print("\n📋 Step 1: Creating budget_phase_payments table...")
        execute_query("""
            CREATE TABLE IF NOT EXISTS budget_phase_payments (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
                budget_allocation_id UUID NOT NULL REFERENCES site_budget_allocation(id) ON DELETE CASCADE,
                phase_number INTEGER NOT NULL CHECK (phase_number BETWEEN 1 AND 5),
                phase_amount DECIMAL(15, 2) NOT NULL CHECK (phase_amount >= 0),
                payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
                recorded_by UUID NOT NULL REFERENCES users(id),
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(budget_allocation_id, phase_number)
            )
        """)
        print("✅ Table budget_phase_payments created successfully")
        
        # Step 2: Create indexes
        print("\n📋 Step 2: Creating indexes...")
        execute_query("""
            CREATE INDEX IF NOT EXISTS idx_phase_payments_site 
            ON budget_phase_payments(site_id)
        """)
        execute_query("""
            CREATE INDEX IF NOT EXISTS idx_phase_payments_budget 
            ON budget_phase_payments(budget_allocation_id)
        """)
        print("✅ Indexes created successfully")
        
        # Step 3: Add client_balance column
        print("\n📋 Step 3: Adding client_balance column to site_budget_allocation...")
        try:
            execute_query("""
                ALTER TABLE site_budget_allocation 
                ADD COLUMN IF NOT EXISTS client_balance DECIMAL(15, 2) DEFAULT 0
            """)
            print("✅ Column client_balance added successfully")
        except Exception as e:
            if "already exists" in str(e).lower():
                print("ℹ️  Column client_balance already exists")
            else:
                raise
        
        # Step 4: Update existing records
        print("\n📋 Step 4: Updating existing records...")
        execute_query("""
            UPDATE site_budget_allocation 
            SET client_balance = total_budget 
            WHERE client_balance IS NULL OR client_balance = 0
        """)
        print("✅ Existing records updated with client_balance = total_budget")
        
        # Step 5: Verify migration
        print("\n📋 Step 5: Verifying migration...")
        
        # Check if table exists
        table_check = fetch_one("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'budget_phase_payments'
            )
        """)
        
        if table_check and table_check['exists']:
            print("✅ Table budget_phase_payments exists")
            
            # Check table structure
            columns = fetch_all("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_name = 'budget_phase_payments'
                ORDER BY ordinal_position
            """)
            
            print("\n📊 Table Structure:")
            print("-" * 60)
            for col in columns:
                nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
                print(f"  {col['column_name']:<25} {col['data_type']:<20} {nullable}")
            print("-" * 60)
        
        # Check client_balance column
        balance_col = fetch_one("""
            SELECT EXISTS (
                SELECT FROM information_schema.columns 
                WHERE table_name = 'site_budget_allocation' 
                AND column_name = 'client_balance'
            )
        """)
        
        if balance_col and balance_col['exists']:
            print("\n✅ Column client_balance exists in site_budget_allocation")
            
            # Show sample data
            sample = fetch_all("""
                SELECT 
                    s.site_name,
                    sba.total_budget,
                    sba.client_balance,
                    sba.status
                FROM site_budget_allocation sba
                JOIN sites s ON sba.site_id = s.id
                WHERE sba.status = 'ACTIVE'
                LIMIT 5
            """)
            
            if sample:
                print("\n📊 Sample Budget Data:")
                print("-" * 80)
                print(f"{'Site Name':<30} {'Total Budget':<15} {'Client Balance':<15} {'Status':<10}")
                print("-" * 80)
                for row in sample:
                    print(f"{row['site_name']:<30} ₹{float(row['total_budget']):>13,.2f} ₹{float(row['client_balance'] or 0):>13,.2f} {row['status']:<10}")
                print("-" * 80)
        
        print("\n" + "="*60)
        print("✅ MIGRATION COMPLETED SUCCESSFULLY!")
        print("="*60)
        print("\n📝 Next Steps:")
        print("1. Restart Django server: python manage.py runserver")
        print("2. Hot restart Flutter app")
        print("3. Test phase payment feature in Budget → Allocation tab")
        print("\n" + "="*60)
        
    except Exception as e:
        print(f"\n❌ Migration failed: {str(e)}")
        import traceback
        traceback.print_exc()
        print("\n" + "="*60)
        sys.exit(1)

if __name__ == '__main__':
    run_migration()
