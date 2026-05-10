"""
Test the materials API endpoint
"""
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Database connection
conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)

cursor = conn.cursor()

print("=" * 80)
print("TESTING MATERIAL_MASTER TABLE STRUCTURE")
print("=" * 80)

# Check table structure
cursor.execute("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = 'material_master'
    ORDER BY ordinal_position
""")
columns = cursor.fetchall()
print("\nTable columns:")
for col in columns:
    print(f"  - {col[0]} ({col[1]})")

# Check actual data
cursor.execute("""
    SELECT * FROM material_master
""")
materials = cursor.fetchall()
print(f"\nTotal materials: {len(materials)}")
print("\nMaterial data:")
for mat in materials:
    print(f"  {mat}")

# Get column names
cursor.execute("SELECT * FROM material_master LIMIT 0")
colnames = [desc[0] for desc in cursor.description]
print(f"\nColumn names: {colnames}")

cursor.close()
conn.close()
