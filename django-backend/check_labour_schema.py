#!/usr/bin/env python3
import os, django, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import fetch_all

cols = fetch_all("SELECT column_name FROM information_schema.columns WHERE table_name = 'labour_entries' ORDER BY ordinal_position")
print("Labour Entries Columns:")
for c in cols:
    print(f"  - {c['column_name']}")
