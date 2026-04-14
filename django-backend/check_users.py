"""
Check users in the database
"""
import psycopg2

# Database connection parameters
DB_CONFIG = {
    'dbname': 'construction_db',
    'user': 'postgres',
    'password': 'admin123',
    'host': 'localhost',
    'port': '5432'
}

def check_users():
    """Check users in database"""
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("Checking users in database...\n")
        
        # Get all users
        cursor.execute("""
            SELECT id, username, full_name, role, is_active, status
            FROM users
            ORDER BY role, username
        """)
        
        users = cursor.fetchall()
        
        if not users:
            print("❌ No users found in database!")
        else:
            print(f"Found {len(users)} users:\n")
            print(f"{'Username':<20} {'Full Name':<25} {'Role':<15} {'Active':<10} {'Status':<15}")
            print("-" * 90)
            
            for user in users:
                user_id, username, full_name, role, is_active, status = user
                print(f"{username:<20} {full_name or 'N/A':<25} {role:<15} {str(is_active):<10} {status or 'N/A':<15}")
        
        # Count by role
        print("\n\nUsers by role:")
        cursor.execute("""
            SELECT role, COUNT(*) as count, 
                   SUM(CASE WHEN is_active THEN 1 ELSE 0 END) as active_count
            FROM users
            GROUP BY role
        """)
        
        role_counts = cursor.fetchall()
        for role, count, active_count in role_counts:
            print(f"  {role}: {count} total, {active_count} active")
        
        # Close connection
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_users()
