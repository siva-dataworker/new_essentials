"""
Create a test supervisor user if none exists
"""
import psycopg2
import uuid
from werkzeug.security import generate_password_hash

# Database connection parameters
DB_CONFIG = {
    'dbname': 'construction_db',
    'user': 'postgres',
    'password': 'admin123',
    'host': 'localhost',
    'port': '5432'
}

def create_test_supervisor():
    """Create a test supervisor user"""
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("Checking for existing supervisors...\n")
        
        # Check if any supervisors exist
        cursor.execute("""
            SELECT COUNT(*) FROM users WHERE role = 'Supervisor'
        """)
        
        count = cursor.fetchone()[0]
        
        if count > 0:
            print(f"✓ Found {count} supervisor(s) in database")
            
            # Update is_active for all supervisors
            cursor.execute("""
                UPDATE users 
                SET is_active = TRUE 
                WHERE role = 'Supervisor' AND (is_active IS NULL OR is_active = FALSE)
            """)
            updated = cursor.rowcount
            if updated > 0:
                print(f"✓ Activated {updated} supervisor(s)")
            
            conn.commit()
            print("\n✅ Supervisors are ready!")
        else:
            print("No supervisors found. Creating test supervisor...\n")
            
            # Create test supervisor
            supervisor_id = str(uuid.uuid4())
            username = "supervisor1"
            password = "password123"
            hashed_password = generate_password_hash(password)
            
            cursor.execute("""
                INSERT INTO users 
                (id, username, password, full_name, role, is_active, phone_number)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (supervisor_id, username, hashed_password, "Test Supervisor", "Supervisor", True, "1234567890"))
            
            conn.commit()
            
            print("✅ Test supervisor created successfully!")
            print(f"\nLogin credentials:")
            print(f"  Username: {username}")
            print(f"  Password: {password}")
        
        # Close connection
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    create_test_supervisor()
