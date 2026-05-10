#!/usr/bin/env python3
"""
Recalculate total_salary for all existing cash_entries
This script finds all unique (site_id, entry_date, source_type) combinations
and recalculates total_salary for each
"""
import os
import django
import sys

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all
from api.views_cash_and_salary import calculate_total_salary_internal

def recalculate_all():
    """Recalculate total_salary for all existing cash entries"""
    
    print("=" * 60)
    print("RECALCULATING TOTAL SALARY")
    print("=" * 60)
    
    # Get all unique (site_id, entry_date, source_type) combinations
    print("\n1. Finding unique cash entry combinations...")
    combinations = fetch_all("""
        SELECT DISTINCT 
            ce.site_id,
            ce.entry_date,
            ce.source_type,
            s.site_name
        FROM cash_entries ce
        JOIN sites s ON ce.site_id = s.id
        ORDER BY ce.entry_date DESC, s.site_name
    """)
    
    if not combinations:
        print("   ℹ️  No cash entries found")
        return
    
    print(f"   Found {len(combinations)} unique combinations:")
    for combo in combinations:
        print(f"   - {combo['site_name']} | {combo['entry_date']} | {combo['source_type']}")
    
    # Recalculate for each combination
    print("\n2. Recalculating total_salary...")
    success_count = 0
    error_count = 0
    
    for combo in combinations:
        site_id = combo['site_id']
        entry_date = combo['entry_date']
        source_type = combo['source_type']
        site_name = combo['site_name']
        
        try:
            result = calculate_total_salary_internal(site_id, entry_date, source_type)
            print(f"   ✅ {site_name} | {entry_date} | {source_type}")
            print(f"      Labour: ₹{result['total_labour_cost']} | Cash: ₹{result['total_cash_paid']} | Net: ₹{result['net_salary']}")
            success_count += 1
        except Exception as e:
            print(f"   ❌ {site_name} | {entry_date} | {source_type}")
            print(f"      Error: {e}")
            error_count += 1
    
    print("\n" + "=" * 60)
    print("RECALCULATION COMPLETE")
    print("=" * 60)
    print(f"\n✅ Success: {success_count}")
    print(f"❌ Errors: {error_count}")
    print(f"📊 Total: {len(combinations)}")

if __name__ == '__main__':
    recalculate_all()
