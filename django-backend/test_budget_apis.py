"""
Test Budget Management APIs
"""
import os
import sys
import django
import requests
from pathlib import Path
from decimal import Decimal

# Setup Django
sys.path.append(str(Path(__file__).parent))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

# Base URL
BASE_URL = 'http://localhost:8000/api'

def test_budget_apis():
    """Test budget management APIs"""
    print("=" * 60)
    print("Testing Budget Management APIs")
    print("=" * 60)
    
    # Step 1: Login as Admin
    print("\n1. Logging in as Admin...")
    login_response = requests.post(f'{BASE_URL}/auth/login/', json={
        'email': 'admin@example.com',  # Update with actual admin email
        'password': 'admin123'  # Update with actual password
    })
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.text}")
        return False
    
    token = login_response.json().get('token')
    print(f"✓ Logged in successfully")
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    # Step 2: Get all sites
    print("\n2. Getting all sites...")
    sites_response = requests.get(f'{BASE_URL}/admin/sites/', headers=headers)
    
    if sites_response.status_code != 200:
        print(f"❌ Failed to get sites: {sites_response.text}")
        return False
    
    sites = sites_response.json().get('sites', [])
    if not sites:
        print("❌ No sites found")
        return False
    
    site_id = sites[0]['site_id']
    site_name = sites[0]['site_name']
    print(f"✓ Found {len(sites)} sites. Using site: {site_name} (ID: {site_id})")
    
    # Step 3: Set budget for site
    print(f"\n3. Setting budget for site {site_name}...")
    budget_amount = 5000000.00  # 50 lakhs
    
    set_budget_response = requests.post(
        f'{BASE_URL}/admin/sites/budget/set/',
        headers=headers,
        json={
            'site_id': site_id,
            'budget_amount': budget_amount
        }
    )
    
    if set_budget_response.status_code not in [200, 201]:
        print(f"❌ Failed to set budget: {set_budget_response.text}")
        return False
    
    budget_data = set_budget_response.json()
    print(f"✓ Budget set successfully")
    print(f"  Budget ID: {budget_data['budget']['budget_id']}")
    print(f"  Allocated: ₹{budget_data['budget']['allocated_amount']:,.2f}")
    print(f"  Remaining: ₹{budget_data['budget']['remaining_amount']:,.2f}")
    
    # Step 4: Get budget for site
    print(f"\n4. Getting budget for site {site_name}...")
    get_budget_response = requests.get(
        f'{BASE_URL}/admin/sites/{site_id}/budget/',
        headers=headers
    )
    
    if get_budget_response.status_code != 200:
        print(f"❌ Failed to get budget: {get_budget_response.text}")
        return False
    
    budget = get_budget_response.json()['budget']
    print(f"✓ Budget retrieved successfully")
    print(f"  Allocated: ₹{budget['allocated_amount']:,.2f}")
    print(f"  Utilized: ₹{budget['utilized_amount']:,.2f}")
    print(f"  Remaining: ₹{budget['remaining_amount']:,.2f}")
    
    # Step 5: Get budget utilization
    print(f"\n5. Getting budget utilization...")
    utilization_response = requests.get(
        f'{BASE_URL}/admin/sites/{site_id}/budget/utilization/',
        headers=headers
    )
    
    if utilization_response.status_code != 200:
        print(f"❌ Failed to get utilization: {utilization_response.text}")
        return False
    
    utilization = utilization_response.json()
    print(f"✓ Utilization retrieved successfully")
    print(f"  Utilization: {utilization['utilization_percentage']}%")
    
    # Step 6: Get all sites budgets
    print(f"\n6. Getting all sites budgets...")
    all_budgets_response = requests.get(
        f'{BASE_URL}/admin/budgets/all/',
        headers=headers
    )
    
    if all_budgets_response.status_code != 200:
        print(f"❌ Failed to get all budgets: {all_budgets_response.text}")
        return False
    
    all_budgets = all_budgets_response.json()
    print(f"✓ Retrieved budgets for {all_budgets['count']} sites")
    
    # Step 7: Get real-time updates
    print(f"\n7. Getting real-time updates...")
    updates_response = requests.get(
        f'{BASE_URL}/admin/realtime-updates/',
        headers=headers
    )
    
    if updates_response.status_code != 200:
        print(f"❌ Failed to get updates: {updates_response.text}")
        return False
    
    updates = updates_response.json()
    print(f"✓ Retrieved {updates['count']} real-time updates")
    
    if updates['count'] > 0:
        print("\n  Recent updates:")
        for update in updates['updates'][:3]:  # Show first 3
            print(f"    - {update['update_type']} at {update['site_name']}")
    
    # Step 8: Get audit trail
    print(f"\n8. Getting audit trail for site {site_name}...")
    audit_response = requests.get(
        f'{BASE_URL}/admin/sites/{site_id}/audit-trail/',
        headers=headers,
        params={'page': 1, 'page_size': 10}
    )
    
    if audit_response.status_code != 200:
        print(f"❌ Failed to get audit trail: {audit_response.text}")
        return False
    
    audit = audit_response.json()
    print(f"✓ Retrieved {audit['total_count']} audit log entries")
    
    if audit['total_count'] > 0:
        print("\n  Recent changes:")
        for log in audit['logs'][:3]:  # Show first 3
            print(f"    - {log['table_name']}.{log['field_name']} changed by {log['changed_by_role']}")
    
    print("\n" + "=" * 60)
    print("✅ All tests passed successfully!")
    print("=" * 60)
    
    return True

if __name__ == '__main__':
    try:
        success = test_budget_apis()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
