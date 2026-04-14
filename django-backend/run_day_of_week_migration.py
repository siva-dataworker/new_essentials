import os
import sys
import django
from pathlib import Path

# Add the project directory to the Python path
BASE_DIR = Path(__file__).resolve().parent
sys.path.append(str(BASE_DIR))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import get_db_connection

def run_migration():
    """Run the day_of_week column migration"""
    print("🔄 Starting day_of_week migration...")
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Read the SQL file
        sql_file = BASE_DIR / 'add_day_of_week_column.sql'
        with open(sql_file, 'r') as f:
            sql_script = f.read()
        
        # Split into individual statements
        statements = [s.strip() for s in sql_script.split(';') if s.strip() and not s.strip().startswith('--')]
        
        print("📝 Executing SQL migration...")
        
        # Execute each statement
        for i, statement in enumerate(statements):
            if statement.strip():
                print(f"  Executing statement {i+1}/{len(statements)}...")
                cursor.execute(statement)
                conn.commit()
        
        # Get the verification results (last statement)
        if cursor.description:  # Check if there are results to fetch
            results = cursor.fetchall()
            if results:
                print("\n✅ Migration completed successfully!")
                print("\n📊 Current day_of_week distribution:")
                print("-" * 50)
                for row in results:
                    table_name, day, count = row
                    print(f"{table_name:20} | {day:10} | {count:5} entries")
                print("-" * 50)
        else:
            print("\n✅ Migration completed successfully!")
        
        cursor.close()
        conn.close()
        
        print("\n✨ Day of week column added and populated!")
        return True
        
    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = run_migration()
    sys.exit(0 if success else 1)
