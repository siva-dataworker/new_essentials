"""
Delete all materials from material_master table
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
print("DELETING ALL MATERIALS FROM MATERIAL_MASTER TABLE")
print("=" * 80)

# Check current count
cursor.execute("SELECT COUNT(*) FROM material_master")
count_before = cursor.fetchone()[0]
print(f"\nMaterials before deletion: {count_before}")

# Delete all materials
cursor.execute("DELETE FROM material_master")
conn.commit()

# Check count after deletion
cursor.execute("SELECT COUNT(*) FROM material_master")
count_after = cursor.fetchone()[0]
print(f"Materials after deletion: {count_after}")

print(f"\n✅ Successfully deleted {count_before} materials")
print("\nNow admin can add materials via the app, and they will be available for:")
print("  - Supervisors (material balance submission)")
print("  - Site Engineers (material inventory)")
print("  - Accountants (material bills)")

cursor.close()
conn.close()
