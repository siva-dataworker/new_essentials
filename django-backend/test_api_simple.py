"""
Simple test without emojis
"""
import requests
import json

BASE_URL = 'http://192.168.1.9:8000/api'

# Login
login_response = requests.post(
    f'{BASE_URL}/auth/login/',
    json={'username': 'client4', 'password': 'client4'}
)

if login_response.status_code != 200:
    print(f"Login failed: {login_response.status_code}")
    print(login_response.text)
    exit(1)

token = login_response.json()['access_token']
print("Logged in successfully")

headers = {'Authorization': f'Bearer {token}'}

# Test API
print("\nTesting /api/client/site-details/...")
response = requests.get(f'{BASE_URL}/client/site-details/', headers=headers)
print(f"Status: {response.status_code}")
print(f"Response:\n{json.dumps(response.json(), indent=2)}")
