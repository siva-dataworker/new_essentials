import psycopg2
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def run_migration():
    """Add extra_cost columns to labour_entries and material_balances tables"""
    
    try:
        # Connect to database
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT', 5432),
            database=os.getenv('DB_NAME'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        
        cursor = conn.cursor()
        
        print("🔄 Adding extra_cost columns to database...")
        
        # Read and execute SQL file
        with open('add_extra_cost_columns.sql', 'r') as f:
            sql = f.read()
            cursor.execute(sql)
        
        conn.commit()
        
        print("✅ Extra cost columns added successfully!")
        print("\nVerifying changes...")
        
        # Verify labour_entries columns
        cursor.execute("""
            SELECT column_name, data_type, column_default
            FROM information_schema.columns 
            WHERE table_name = 'labour_entries'
                AND column_name IN ('extra_cost', 'extra_cost_notes', 'entry_time')
            ORDER BY column_name;
        """)
        
        print("\n📊 Labour Entries Columns:")
        for row in cursor.fetchall():
            print(f"  - {row[0]}: {row[1]} (default: {row[2]})")
        
        # Verify material_balances columns
        cursor.execute("""
            SELECT column_name, data_type, column_default
            FROM information_schema.columns 
            WHERE table_name = 'material_balances'
                AND column_name IN ('extra_cost', 'extra_cost_notes', 'updated_at')
            ORDER BY column_name;
        """)
        
        print("\n📦 Material Balances Columns:")
        for row in cursor.fetchall():
            print(f"  - {row[0]}: {row[1]} (default: {row[2]})")
        
        cursor.close()
        conn.close()
        
        print("\n✅ Migration completed successfully!")
        print("\nNext steps:")
        print("1. Update backend API to accept extra_cost")
        print("2. Update frontend to show timestamps and extra costs")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        if conn:
            conn.rollback()
        raise

if __name__ == '__main__':
    run_migration()
