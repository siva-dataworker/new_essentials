#!/usr/bin/env python3
"""
Fix timestamp defaults to use CURRENT_TIMESTAMP
This ensures all new entries automatically get IST timestamps
"""

import os
from decouple import config

# Get database connection details
db_url = config('DATABASE_URL')

# Parse the DATABASE_URL
# Format: postgresql://user:password@host:port/dbname
import re
match = re.match(r'postgresql://([^:]+):([^@]+)@([^:]+):(\d+)/(.+)', db_url)
if not match:
    print("❌ Could not parse DATABASE_URL")
    exit(1)

user, password, host, port, dbname = match.groups()

# Read SQL file
with open('fix_timestamp_defaults.sql', 'r') as f:
    sql_content = f.read()

# Use psql command to execute
import subprocess

# Set PGPASSWORD environment variable
env = os.environ.copy()
env['PGPASSWORD'] = password

# Execute SQL
print("🔧 Fixing timestamp defaults...")
result = subprocess.run(
    ['psql', '-h', host, '-p', port, '-U', user, '-d', dbname, '-c', sql_content],
    env=env,
    capture_output=True,
    text=True
)

if result.returncode == 0:
    print("✅ Timestamp defaults fixed successfully!")
    print("\n" + result.stdout)
else:
    print("❌ Error fixing timestamp defaults:")
    print(result.stderr)
    exit(1)
