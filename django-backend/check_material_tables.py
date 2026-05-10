"""
Check material-related tables and their record counts
"""
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)
conn.autocommit = True

cursor = conn.cursor()

print("=" * 80)
print("MATERIAL-RELATED TABLES AND RECORD COUNTS")
print("=" * 80)

# Get all material-related tables
cursor.execute("""
    SELECT table_name, table_type
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name LIKE '%material%'
    ORDER BY table_name
""")

tables = cursor.fetchall()

print(f"\nFound {len(tables)} material-related tables/views:\n")

for table_name, table_type in tables:
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        icon = "📊" if table_type == "BASE TABLE" else "👁️"
        print(f"{icon} {table_name} ({table_type}): {count} records")
    except Exception as e:
        print(f"❌ {table_name} ({table_type}): Error - {e}")

cursor.close()
conn.close()
