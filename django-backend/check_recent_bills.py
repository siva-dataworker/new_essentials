import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

print("=" * 60)
print("RECENT MATERIAL BILLS")
print("=" * 60)

bills = fetch_all("""
    SELECT 
        id,
        bill_number,
        vendor_name,
        material_type,
        quantity,
        unit,
        total_amount,
        upload_date,
        file_url
    FROM material_bills
    ORDER BY uploaded_at DESC
    LIMIT 5
""")

if bills:
    for bill in bills:
        print(f"\nBill ID: {bill['id']}")
        print(f"  Bill Number: {bill['bill_number']}")
        print(f"  Vendor: {bill['vendor_name']}")
        print(f"  Material: {bill['material_type']}")
        print(f"  Quantity: {bill['quantity']} {bill['unit']}")
        print(f"  Amount: {bill['total_amount']}")
        print(f"  Date: {bill['upload_date']}")
        print(f"  File: {bill['file_url']}")
else:
    print("\nNo bills found!")
