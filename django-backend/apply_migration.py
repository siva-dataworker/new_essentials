#!/usr/bin/env python
"""
Script to apply the material data migration
Migrates data from material_balances to material_usage table
"""

import os
import sys
import django

# Setup Django environment
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def run_migration():
    """Execute the migration SQL script"""
    
    print("=" * 60)
    print("Material Data Migration Script")
    print("=" * 60)
    print()
    
    # Read the SQL file
    sql_file_path = os.path.join(os.path.dirname(__file__), 'migrate_material_data.sql')
    
    try:
        with open(sql_file_path, 'r') as f:
            sql_content = f.read()
        
        print(f"✓ Loaded SQL file: {sql_file_path}")
        print()
        
        # Split SQL into individual statements (simple split by semicolon)
        # Filter out comments and empty statements
        statements = []
        for statement in sql_content.split(';'):
            # Remove comments and whitespace
            cleaned = '\n'.join([
                line for line in statement.split('\n') 
                if not line.strip().startswith('--')
            ]).strip()
            
            if cleaned:
                statements.append(cleaned)
        
        print(f"Found {len(statements)} SQL statements to execute")
        print()
        
        # Execute each statement
        with connection.cursor() as cursor:
            for i, statement in enumerate(statements, 1):
                try:
                    print(f"[{i}/{len(statements)}] Executing statement...")
                    cursor.execute(statement)
                    
                    # If it's a SELECT statement, fetch and display results
                    if statement.strip().upper().startswith('SELECT'):
                        columns = [col[0] for col in cursor.description]
                        results = cursor.fetchall()
                        
                        if results:
                            print(f"  Results:")
                            print(f"  {' | '.join(columns)}")
                            print(f"  {'-' * 60}")
                            for row in results:
                                print(f"  {' | '.join(str(val) for val in row)}")
                        else:
                            print(f"  No results returned")
                    else:
                        print(f"  ✓ Statement executed successfully")
                    
                    print()
                    
                except Exception as e:
                    print(f"  ✗ Error executing statement: {e}")
                    print(f"  Statement: {statement[:100]}...")
                    print()
                    # Continue with next statement instead of failing completely
                    continue
        
        print("=" * 60)
        print("Migration completed!")
        print("=" * 60)
        print()
        print("Next steps:")
        print("1. Hot restart your Flutter app")
        print("2. Check the Available tab in Material Balance")
        print("3. The 'Total Used' values should now be correct")
        print()
        
    except FileNotFoundError:
        print(f"✗ Error: SQL file not found at {sql_file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    run_migration()
