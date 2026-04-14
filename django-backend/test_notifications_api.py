"""
Test the notifications API endpoint
"""
import requests
import json

BASE_URL = "http://192.168.1.9:8000/api"

# You'll need to get a valid admin token
# For now, let's just test if the endpoint responds
print("=" * 80)
print("TESTING NOTIFICATIONS API")
print("=" * 80)

# Test without authentication (should fail with 401)
print("\n1. Testing GET /notifications/ without auth...")
response = requests.get(f"{BASE_URL}/notifications/")
print(f"   Status: {response.status_code}")
print(f"   Response: {response.text[:200]}")

# To test with authentication, you need to:
# 1. Login as admin
# 2. Get the JWT token
# 3. Use it in the Authorization header

print("\n" + "=" * 80)
print("To test with authentication:")
print("1. Login as admin in the Flutter app")
print("2. Check the Flutter console for the JWT token")
print("3. Use this curl command:")
print()
print('curl -X GET "http://192.168.1.9:8000/api/notifications/" \\')
print('  -H "Authorization: Bearer YOUR_TOKEN_HERE" \\')
print('  -H "Content-Type: application/json"')
print("=" * 80)
