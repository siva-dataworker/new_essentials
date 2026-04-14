"""
Quick test of client API
"""
import requests
import json

BASE_URL = 'http://192.168.1.9:8000/api'

# Login as client4
print("Logging in as client4...")
login_response = requests.post(
    f'{BASE_URL}/auth/login/',
    json={'username': 'client4', 'password': 'client4'}
)

print(f"Login status: {login_response.status_code}")
if login_response.status_code != 200:
    print(f"Login failed: {login_response.text}")
    exit(1)

login_data = login_response.json()
token = login_data['access_token']
print(f"✅ Logged in as {login_data['user']['username']}")
print(f"Role: {login_data['user']['role']}")

headers = {'Authorization': f'Bearer {token}'}

# Test new comprehensive API
print("\n" + "="*70)
print("Testing /api/client/site-details/")
print("="*70)
response = requests.get(f'{BASE_URL}/client/site-details/', headers=headers)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}")

# Test old supervisor photos API
print("\n" + "="*70)
print("Testing /api/construction/supervisor-photos/")
print("="*70)
site_id = '3ae88295-427b-49f6-8e50-4c02d0250617'  # client4's site
response2 = requests.get(
    f'{BASE_URL}/construction/supervisor-photos/',
    params={'site_id': site_id},
    headers=headers
)
print(f"Status: {response2.status_code}")
print(f"Response: {response2.text[:500]}")

# Test architect documents API
print("\n" + "="*70)
print("Testing /api/construction/architect-documents/")
print("="*70)
response3 = requests.get(
    f'{BASE_URL}/construction/architect-documents/',
    params={'site_id': site_id},
    headers=headers
)
print(f"Status: {response3.status_code}")
print(f"Response: {response3.text[:500]}")
