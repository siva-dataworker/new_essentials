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
print("CHECKING MATERIAL_TYPE VALUES ACROSS TABLES")
print("=" * 80)

# Check material_master table
print("\n1. MATERIAL_MASTER TABLE")
print("-" * 80)
cursor.execute("""
    SELECT material_name, COUNT(*) as count
    FROM material_master
    GROUP BY material_name
    ORDER BY material_name
""")
materials = cursor.fetchall()
print(f"Total unique materials in material_master: {len(materials)}")
for mat in materials:
    print(f"  - {mat[0]} (used {mat[1]} time(s))")

# Check material_usage table
print("\n2. MATERIAL_USAGE TABLE (Supervisor entries)")
print("-" * 80)
cursor.execute("""
    SELECT material_type, COUNT(*) as count
    FROM material_usage
    GROUP BY material_type
    ORDER BY count DESC, material_type
""")
usage_materials = cursor.fetchall()
print(f"Total unique material types in material_usage: {len(usage_materials)}")
for mat in usage_materials:
    print(f"  - {mat[0]} (used {mat[1]} time(s))")

# Check material_bills table
print("\n3. MATERIAL_BILLS TABLE (Accountant bills)")
print("-" * 80)
cursor.execute("""
    SELECT material_type, COUNT(*) as count
    FROM material_bills
    GROUP BY material_type
    ORDER BY count DESC, material_type
""")
bill_materials = cursor.fetchall()
print(f"Total unique material types in material_bills: {len(bill_materials)}")
for mat in bill_materials:
    print(f"  - {mat[0]} (used {mat[1]} time(s))")

# Check material_requirements table
print("\n4. MATERIAL_REQUIREMENTS TABLE (Supervisor requests)")
print("-" * 80)
cursor.execute("""
    SELECT material_name, COUNT(*) as count
    FROM material_requirements
    GROUP BY material_name
    ORDER BY count DESC, material_name
""")
req_materials = cursor.fetchall()
print(f"Total unique material names in material_requirements: {len(req_materials)}")
for mat in req_materials:
    print(f"  - {mat[0]} (requested {mat[1]} time(s))")

# Find materials in usage/bills but NOT in material_master
print("\n5. MATERIALS NOT IN MATERIAL_MASTER")
print("-" * 80)
cursor.execute("""
    SELECT DISTINCT material_type
    FROM material_usage
    WHERE material_type NOT IN (SELECT material_name FROM material_master)
    ORDER BY material_type
""")
missing_from_usage = cursor.fetchall()
print(f"From material_usage: {len(missing_from_usage)} materials")
for mat in missing_from_usage:
    print(f"  - {mat[0]}")

cursor.execute("""
    SELECT DISTINCT material_type
    FROM material_bills
    WHERE material_type NOT IN (SELECT material_name FROM material_master)
    ORDER BY material_type
""")
missing_from_bills = cursor.fetchall()
print(f"\nFrom material_bills: {len(missing_from_bills)} materials")
for mat in missing_from_bills:
    print(f"  - {mat[0]}")

# Summary
print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"Material Master: {len(materials)} unique materials")
print(f"Material Usage: {len(usage_materials)} unique types")
print(f"Material Bills: {len(bill_materials)} unique types")
print(f"Material Requirements: {len(req_materials)} unique names")
print(f"Missing from master (usage): {len(missing_from_usage)}")
print(f"Missing from master (bills): {len(missing_from_bills)}")

cursor.close()
conn.close()
