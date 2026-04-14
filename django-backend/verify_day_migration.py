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

from api.database import fetch_all

def verify_migration():
    """Verify the day_of_week migration"""
    print("🔍 Verifying day_of_week migration...")
    print("=" * 60)
    
    # Check labour_entries
    print("\n📊 Labour Entries by Day:")
    print("-" * 60)
    labour_by_day = fetch_all("""
        SELECT day_of_week, COUNT(*) as count, 
               MIN(entry_date) as first_date, 
               MAX(entry_date) as last_date
        FROM labour_entries
        WHERE day_of_week IS NOT NULL
        GROUP BY day_of_week
        ORDER BY 
            CASE day_of_week
                WHEN 'Monday' THEN 1
                WHEN 'Tuesday' THEN 2
                WHEN 'Wednesday' THEN 3
                WHEN 'Thursday' THEN 4
                WHEN 'Friday' THEN 5
                WHEN 'Saturday' THEN 6
                WHEN 'Sunday' THEN 7
            END
    """)
    
    for row in labour_by_day:
        print(f"  {row['day_of_week']:10} | {row['count']:3} entries | {row['first_date']} to {row['last_date']}")
    
    # Check material_balances
    print("\n📦 Material Balances by Day:")
    print("-" * 60)
    material_by_day = fetch_all("""
        SELECT day_of_week, COUNT(*) as count,
               MIN(entry_date) as first_date,
               MAX(entry_date) as last_date
        FROM material_balances
        WHERE day_of_week IS NOT NULL
        GROUP BY day_of_week
        ORDER BY 
            CASE day_of_week
                WHEN 'Monday' THEN 1
                WHEN 'Tuesday' THEN 2
                WHEN 'Wednesday' THEN 3
                WHEN 'Thursday' THEN 4
                WHEN 'Friday' THEN 5
                WHEN 'Saturday' THEN 6
                WHEN 'Sunday' THEN 7
            END
    """)
    
    for row in material_by_day:
        print(f"  {row['day_of_week']:10} | {row['count']:3} entries | {row['first_date']} to {row['last_date']}")
    
    # Sample entries
    print("\n📝 Sample Labour Entries with Day:")
    print("-" * 60)
    sample_labour = fetch_all("""
        SELECT labour_type, labour_count, entry_date, day_of_week
        FROM labour_entries
        ORDER BY entry_date DESC
        LIMIT 5
    """)
    
    for row in sample_labour:
        print(f"  {row['day_of_week']:10} | {row['entry_date']} | {row['labour_type']:15} | {row['labour_count']} workers")
    
    print("\n" + "=" * 60)
    print("✅ Migration verification complete!")
    print("\nNext steps:")
    print("1. Restart backend: python manage.py runserver 0.0.0.0:8000")
    print("2. Test time validation endpoint")
    print("3. Continue with Step 2 implementation")

if __name__ == '__main__':
    verify_migration()
