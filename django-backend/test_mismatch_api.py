import requests
import json

# Test the mismatch API endpoint
url = "http://localhost:8000/api/construction/labor-mismatches/"

# You'll need to get a valid JWT token from the accountant user
# For now, let's just test if the endpoint is accessible
print("Testing mismatch API endpoint...")
print(f"URL: {url}\n")

try:
    response = requests.get(url)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
except Exception as e:
    print(f"Error: {e}")
