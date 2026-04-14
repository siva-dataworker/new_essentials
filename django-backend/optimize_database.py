"""
Apply database optimizations for faster site queries
"""
import psycopg2
from psycopg2 import sql

# Database connection parameters
DB_CONFIG = {
    'dbname': 'construction_db',
    'user': 'postgres',
    'password': 'admin123',
    'host': 'localhost',
    'port': '5432'
}

def optimize_database():
    """Apply database optimizations"""
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("Applying database optimizations...")
        
        # Create indexes
        optimizations = [
            ("idx_sites_status", "CREATE INDEX IF NOT EXISTS idx_sites_status ON sites(status)"),
            ("idx_sites_customer_site", "CREATE INDEX IF NOT EXISTS idx_sites_customer_site ON sites(customer_name, site_name)"),
            ("idx_sites_status_customer_site", "CREATE INDEX IF NOT EXISTS idx_sites_status_customer_site ON sites(status, customer_name, site_name)"),
        ]
        
        for index_name, query in optimizations:
            try:
                cursor.execute(query)
                print(f"✓ Created index: {index_name}")
            except Exception as e:
                print(f"✗ Error creating {index_name}: {e}")
        
        # Analyze table
        cursor.execute("ANALYZE sites")
        print("✓ Analyzed sites table")
        
        # Commit changes
        conn.commit()
        print("\n✅ Database optimization completed successfully!")
        
        # Close connection
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    optimize_database()
