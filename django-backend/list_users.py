#!/usr/bin/env python3
import os, django, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

users = fetch_all('SELECT id, username, full_name FROM users ORDER BY username')
print("\nUsers in database:")
print("-" * 60)
for u in users:
    print(f"{u['username']:15} | {u['full_name']:20} | ID: {u['id']}")
