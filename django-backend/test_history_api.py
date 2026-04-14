#!/usr/bin/env python3
"""
Test the history API to debug any issues
"""
import requests
import json

# Test the supervisor history API
def test_history_api():
    base_url = "http://192.168.1.7:8000/api"
    
    # First, let's test without authentication to see the error
    print("🔍 Testing supervisor history API...")
    
    try:
        response = requests.get(f"{base_url}/construction/supervisor/history/")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text[:500]}...")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Labour entries: {len(data.get('labour_entries', []))}")
            print(f"Material entries: {len(data.get('material_entries', []))}")
            
            if data.get('labour_entries'):
                print(f"First labour entry: {data['labour_entries'][0]}")
        
    except Exception as e:
        print(f"Error: {e}")

    # Test the new today entries API
    print("\n🔍 Testing today entries API...")
    try:
        response = requests.get(f"{base_url}/construction/today-entries-supervisor/")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text[:500]}...")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_history_api()
