#!/usr/bin/env python
"""
Script to create the working_sites table
"""

import os
import sys
import django

# Setup Django environment
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

def create_table():
    """Create working_sites table"""
    
    print("=" * 60)
    print("Creating working_sites Table")
    print("=" * 60)
    print()
    
    sql_file_path = os.path.join(os.path.dirname(__file__), 'create_working_sites_table.sql')
    
    try:
        with open(sql_file_path, 'r') as f:
            sql_content = f.read()
        
        print(f"✓ Loaded SQL file: {sql_file_path}")
        print()
        
        statements = []
        for statement in sql_content.split(';'):
            cleaned = '\n'.join([
                line for line in statement.split('\n') 
                if not line.strip().startswith('--')
            ]).strip()
            
            if cleaned:
                statements.append(cleaned)
        
        print(f"Found {len(statements)} SQL statements to execute")
        print()
        
        with connection.cursor() as cursor:
            for i, statement in enumerate(statements, 1):
                try:
                    print(f"[{i}/{len(statements)}] Executing statement...")
                    cursor.execute(statement)
                    
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
                    continue
        
        print("=" * 60)
        print("Table creation completed!")
        print("=" * 60)
        
    except FileNotFoundError:
        print(f"✗ Error: SQL file not found at {sql_file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    create_table()
