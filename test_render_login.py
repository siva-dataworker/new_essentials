"""
Detailed login test
"""
import requests
import json

BASE_URL = "https://essentials-construction-project.onrender.com"

print("Testing login with detailed response...")
response = requests.post(
    f"{BASE_URL}/api/auth/login/",
    json={"username": "admin", "password": "admin123"},
    timeout=30
)

print(f"Status: {response.status_code}")
print(f"\nFull Response:")
print(json.dumps(response.json(), indent=2))
