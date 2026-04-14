import requests
import json

# Test the admin sites endpoint
url = 'http://192.168.1.7:8000/api/admin/sites/'

try:
    response = requests.get(url)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
except Exception as e:
    print(f"Error: {e}")
