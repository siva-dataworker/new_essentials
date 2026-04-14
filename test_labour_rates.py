#!/usr/bin/env python3
"""
Test script to verify labour rates consistency across Admin, Site Engineer, and Supervisor
"""
import requests
import json

BASE_URL = "http://127.0.0.1:8000/api"

# Test credentials
ADMIN_CREDENTIALS = {"username": "admin", "password": "admin123"}
SUPERVISOR_CREDENTIALS = {"username": "nsjskakaka", "password": "Test123"}  # Using actual supervisor username
SITE_ENGINEER_CREDENTIALS = {"username": "aravind", "password": "Test123"}  # Using actual site engineer username

def login(credentials):
    """Login and get JWT token"""
    try:
        response = requests.post(f"{BASE_URL}/auth/login/", json=credentials)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            token = data.get('access_token')  # Changed from 'access' to 'access_token'
            if token:
                print(f"   ✓ Token received")
                return token
            else:
                print(f"   ✗ No access token in response: {data}")
                return None
        else:
            print(f"   ✗ Login failed: {response.text}")
            return None
    except Exception as e:
        print(f"   ✗ Exception: {e}")
        return None

def get_labour_rates(token, role_name):
    """Get global labour rates"""
    if not token:
        print(f"{role_name} - No token available")
        return None
        
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/budget/labour-rates/global/", headers=headers)
    
    print(f"\n{role_name} - Response Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        rates = data.get('rates', [])
        print(f"\n{'='*60}")
        print(f"{role_name} - Labour Rates (Total: {len(rates)} types)")
        print(f"{'='*60}")
        
        rate_dict = {}
        for rate in rates:
            labour_type = rate['labour_type']
            daily_rate = rate['daily_rate']
            is_admin_set = rate.get('is_admin_set', False)
            set_by = rate.get('set_by', 'Default')
            
            rate_dict[labour_type] = daily_rate
            
            status = "✓ Admin Set" if is_admin_set else "○ Default"
            print(f"{labour_type:20} ₹{daily_rate:>6.0f}/day  {status:15} by: {set_by or 'System'}")
        
        return rate_dict
    else:
        print(f"{role_name} - Failed to get rates: {response.status_code}")
        return None

def compare_rates(admin_rates, supervisor_rates, engineer_rates):
    """Compare rates across all roles"""
    print(f"\n{'='*60}")
    print("COMPARISON SUMMARY")
    print(f"{'='*60}")
    
    all_types = set()
    if admin_rates:
        all_types.update(admin_rates.keys())
    if supervisor_rates:
        all_types.update(supervisor_rates.keys())
    if engineer_rates:
        all_types.update(engineer_rates.keys())
    
    all_match = True
    for labour_type in sorted(all_types):
        admin_rate = admin_rates.get(labour_type, 'N/A') if admin_rates else 'N/A'
        super_rate = supervisor_rates.get(labour_type, 'N/A') if supervisor_rates else 'N/A'
        eng_rate = engineer_rates.get(labour_type, 'N/A') if engineer_rates else 'N/A'
        
        # Check if all rates match
        rates = [admin_rate, super_rate, eng_rate]
        rates = [r for r in rates if r != 'N/A']
        
        if len(set(rates)) == 1:
            status = "✓ MATCH"
        else:
            status = "✗ MISMATCH"
            all_match = False
        
        print(f"{labour_type:20} Admin: ₹{admin_rate if admin_rate != 'N/A' else 'N/A':>6}  "
              f"Supervisor: ₹{super_rate if super_rate != 'N/A' else 'N/A':>6}  "
              f"Engineer: ₹{eng_rate if eng_rate != 'N/A' else 'N/A':>6}  {status}")
    
    print(f"\n{'='*60}")
    if all_match:
        print("✓ ALL RATES MATCH - System is consistent!")
    else:
        print("✗ RATES MISMATCH - There are inconsistencies!")
    print(f"{'='*60}\n")

def main():
    print("Testing Labour Rates Consistency")
    print("="*60)
    
    # Login as Admin
    print("\n1. Logging in as Admin...")
    admin_token = login(ADMIN_CREDENTIALS)
    
    # Login as Supervisor
    print("2. Logging in as Supervisor...")
    supervisor_token = login(SUPERVISOR_CREDENTIALS)
    
    # Login as Site Engineer
    print("3. Logging in as Site Engineer...")
    engineer_token = login(SITE_ENGINEER_CREDENTIALS)
    
    # Get rates for each role
    admin_rates = None
    supervisor_rates = None
    engineer_rates = None
    
    if admin_token:
        admin_rates = get_labour_rates(admin_token, "ADMIN")
    
    if supervisor_token:
        supervisor_rates = get_labour_rates(supervisor_token, "SUPERVISOR")
    
    if engineer_token:
        engineer_rates = get_labour_rates(engineer_token, "SITE ENGINEER")
    
    # Compare rates
    if admin_rates or supervisor_rates or engineer_rates:
        compare_rates(admin_rates, supervisor_rates, engineer_rates)
    else:
        print("\n✗ Failed to retrieve rates from any role")

if __name__ == "__main__":
    main()
