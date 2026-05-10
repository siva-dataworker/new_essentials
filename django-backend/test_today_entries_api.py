#!/usr/bin/env python3
"""
Test the today entries API to verify it's filtering by user correctly
"""
import requests
import json

BASE_URL = "http://localhost:8000/api"

def test_today_entries():
    print("=" * 60)
    print("TESTING TODAY ENTRIES API")
    print("=" * 60)
    
    # You need to get actual tokens for jack and aravind
    # For now, this is a template
    
    print("\n1. Testing as Supervisor (jack)")
    print("-" * 60)
    # Replace with actual jack's token
    jack_token = "JACK_TOKEN_HERE"
    
    response = requests.get(
        f"{BASE_URL}/construction/aggregated-today-entries/",
        headers={"Authorization": f"Bearer {jack_token}"}
    )
    
    if response.status_code == 200:
        data = response.json()
        entries = data.get('entries', [])
        print(f"✅ Status: {response.status_code}")
        print(f"📊 Entries count: {len(entries)}")
        print(f"📝 Entries: {json.dumps(entries, indent=2)}")
    else:
        print(f"❌ Status: {response.status_code}")
        print(f"❌ Error: {response.text}")
    
    print("\n2. Testing as Site Engineer (aravind)")
    print("-" * 60)
    # Replace with actual aravind's token
    aravind_token = "ARAVIND_TOKEN_HERE"
    
    response = requests.get(
        f"{BASE_URL}/construction/aggregated-today-entries/",
        headers={"Authorization": f"Bearer {aravind_token}"}
    )
    
    if response.status_code == 200:
        data = response.json()
        entries = data.get('entries', [])
        print(f"✅ Status: {response.status_code}")
        print(f"📊 Entries count: {len(entries)}")
        print(f"📝 Entries: {json.dumps(entries, indent=2)}")
    else:
        print(f"❌ Status: {response.status_code}")
        print(f"❌ Error: {response.text}")
    
    print("\n" + "=" * 60)
    print("TEST COMPLETE")
    print("=" * 60)
    print("\nExpected Results:")
    print("- Jack (Supervisor) should see 3 entries")
    print("- Aravind (Site Engineer) should see 3 entries")
    print("- They should NOT see each other's entries")

if __name__ == '__main__':
    print("\n⚠️  NOTE: You need to replace JACK_TOKEN_HERE and ARAVIND_TOKEN_HERE")
    print("with actual JWT tokens from the app.\n")
    # test_today_entries()  # Uncomment when you have tokens
