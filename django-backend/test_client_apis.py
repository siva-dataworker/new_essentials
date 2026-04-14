"""
Test Client Dashboard APIs
"""
import requests
import json

BASE_URL = 'http://192.168.1.9:8000/api'

def test_client_apis():
    print("\n" + "="*70)
    print("TESTING CLIENT DASHBOARD APIS")
    print("="*70)
    
    # Login as client4
    print("\n1. Logging in as client4...")
    login_response = requests.post(
        f'{BASE_URL}/auth/login/',
        json={
            'username': 'client4',
            'password': 'client4'  # Update with actual password
        }
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"Response: {login_response.text}")
        return
    
    login_data = login_response.json()
    token = login_data['access_token']
    print(f"✅ Login successful!")
    print(f"User: {login_data['user']['username']}")
    print(f"Role: {login_data['user']['role']}")
    
    headers = {'Authorization': f'Bearer {token}'}
    
    # Test 1: Get assigned sites
    print("\n2. Getting assigned sites...")
    sites_response = requests.get(
        f'{BASE_URL}/client/sites/',
        headers=headers
    )
    
    if sites_response.status_code == 200:
        sites_data = sites_response.json()
        print(f"✅ Found {sites_data['count']} assigned site(s)")
        if sites_data['sites']:
            site_id = sites_data['sites'][0]['id']
            print(f"   Site: {sites_data['sites'][0]['display_name']}")
            print(f"   Site ID: {site_id}")
        else:
            print("⚠️  No sites assigned")
            return
    else:
        print(f"❌ Failed: {sites_response.status_code}")
        print(f"Response: {sites_response.text}")
        return
    
    # Test 2: Get comprehensive site details
    print("\n3. Getting comprehensive site details...")
    details_response = requests.get(
        f'{BASE_URL}/client/site-details/',
        headers=headers
    )
    
    if details_response.status_code == 200:
        details_data = details_response.json()
        print(f"✅ Site details retrieved successfully")
        if details_data['sites']:
            site = details_data['sites'][0]
            print(f"\n   Site: {site['display_name']}")
            print(f"   Labour Summary:")
            print(f"      Total Days: {site['labour_summary']['total_days']}")
            print(f"      Total Labour: {site['labour_summary']['total_labour_count']}")
            print(f"      Last Entry: {site['labour_summary']['last_entry_date']}")
            print(f"   Photos: {len(site['photos'])} uploaded")
            print(f"   Architect Documents: {len(site['architect_documents'])}")
            print(f"   Engineer Documents: {len(site['engineer_documents'])}")
            print(f"   Extra Requirements: ₹{site['extra_requirements']['total_amount']}")
    else:
        print(f"❌ Failed: {details_response.status_code}")
        print(f"Response: {details_response.text}")
    
    # Test 3: Get labour summary
    print("\n4. Getting labour summary...")
    labour_response = requests.get(
        f'{BASE_URL}/client/labour-summary/',
        params={'site_id': site_id},
        headers=headers
    )
    
    if labour_response.status_code == 200:
        labour_data = labour_response.json()
        print(f"✅ Labour summary retrieved")
        print(f"   Total Days: {labour_data['summary']['total_days']}")
        print(f"   Total Labour: {labour_data['summary']['total_labour']}")
        print(f"   Avg per Day: {labour_data['summary']['avg_labour_per_day']:.1f}")
        print(f"   Entries: {len(labour_data['entries'])}")
    else:
        print(f"❌ Failed: {labour_response.status_code}")
        print(f"Response: {labour_response.text}")
    
    # Test 4: Get photos
    print("\n5. Getting photos...")
    photos_response = requests.get(
        f'{BASE_URL}/client/photos/',
        params={'site_id': site_id},
        headers=headers
    )
    
    if photos_response.status_code == 200:
        photos_data = photos_response.json()
        print(f"✅ Photos retrieved: {photos_data['count']} photos")
        if photos_data['photos']:
            print(f"   Latest photo:")
            photo = photos_data['photos'][0]
            print(f"      Time: {photo['time_of_day']}")
            print(f"      Date: {photo['uploaded_date']}")
            print(f"      By: {photo['supervisor_name']}")
    else:
        print(f"❌ Failed: {photos_response.status_code}")
        print(f"Response: {photos_response.text}")
    
    # Test 5: Get documents
    print("\n6. Getting documents...")
    docs_response = requests.get(
        f'{BASE_URL}/client/documents/',
        params={'site_id': site_id},
        headers=headers
    )
    
    if docs_response.status_code == 200:
        docs_data = docs_response.json()
        print(f"✅ Documents retrieved: {docs_data['count']} total")
        print(f"   Architect: {docs_data['architect_count']}")
        print(f"   Engineer: {docs_data['engineer_count']}")
        if docs_data['documents']:
            print(f"   Latest document:")
            doc = docs_data['documents'][0]
            print(f"      Title: {doc['title']}")
            print(f"      Type: {doc['document_type']}")
            print(f"      By: {doc['uploaded_by']} ({doc['role']})")
    else:
        print(f"❌ Failed: {docs_response.status_code}")
        print(f"Response: {docs_response.text}")
    
    print("\n" + "="*70)
    print("TEST COMPLETE")
    print("="*70 + "\n")

if __name__ == '__main__':
    test_client_apis()
