#!/usr/bin/env python3
"""
Run architect documents migration
Creates architect_documents and architect_complaints tables
"""

import os
import sys
import django
from pathlib import Path

# Add the project directory to Python path
project_dir = Path(__file__).resolve().parent
sys.path.append(str(project_dir))

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

def run_migration():
    """Run the architect documents migration"""
    try:
        print("🚀 Starting architect documents migration...")
        
        # Read and execute the SQL file
        sql_file = project_dir / 'add_architect_documents_table.sql'
        
        if not sql_file.exists():
            print(f"❌ SQL file not found: {sql_file}")
            return False
        
        with open(sql_file, 'r') as f:
            sql_content = f.read()
        
        # Split by semicolon and execute each statement
        statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
        
        for statement in statements:
            if statement:
                print(f"📝 Executing: {statement[:50]}...")
                execute_query(statement)
        
        print("✅ Architect documents migration completed successfully!")
        print("   - architect_documents table created")
        print("   - architect_complaints table created")
        print("   - Indexes created")
        
        return True
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        return False

if __name__ == '__main__':
    success = run_migration()
    sys.exit(0 if success else 1)
