#!/usr/bin/env python3
"""
Apply material requirements table migration to database
"""
import psycopg
from decouple import config
from urllib.parse import quote_plus

# Database connection from individual components
DB_NAME = config('DB_NAME', default='postgres')
DB_USER = config('DB_USER', default='postgres')
DB_PASSWORD = config('DB_PASSWORD')
DB_HOST = config('DB_HOST')
DB_PORT = config('DB_PORT', default='5432')

# URL encode the password to handle special characters
encoded_password = quote_plus(DB_PASSWORD)
DATABASE_URL = f"postgresql://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

def apply_migration():
    try:
        # Read SQL file
        with open('add_material_requirements_table.sql', 'r') as f:
            sql = f.read()
        
        # Connect and execute
        print(f"Connecting to database at {DB_HOST}...")
        with psycopg.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                cur.execute(sql)
                conn.commit()
                print("✅ Material requirements table created successfully!")
                
                # Verify table exists
                cur.execute("""
                    SELECT COUNT(*) FROM information_schema.tables 
                    WHERE table_name = 'material_requirements'
                """)
                count = cur.fetchone()[0]
                if count > 0:
                    print("✅ Table verified in database")
                else:
                    print("❌ Table not found after creation")
                    
    except Exception as e:
        print(f"❌ Error applying migration: {e}")
        return False
    
    return True

if __name__ == '__main__':
    print("Applying material requirements migration...")
    success = apply_migration()
    if success:
        print("\n🎉 Migration completed successfully!")
    else:
        print("\n❌ Migration failed!")
