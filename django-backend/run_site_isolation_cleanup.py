#!/usr/bin/env python3
"""
Run Site Data Isolation Cleanup
Simple script to execute the site isolation cleanup
"""

import subprocess
import sys
import os

def run_cleanup():
    """Run the site isolation cleanup script"""
    try:
        print("🚀 Running Site Data Isolation Cleanup...")
        
        # Change to the django-backend directory
        script_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(script_dir)
        
        # Run the cleanup script
        result = subprocess.run([
            sys.executable, 
            'ensure_site_data_isolation.py'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Cleanup completed successfully!")
            print("\n📋 OUTPUT:")
            print(result.stdout)
        else:
            print("❌ Cleanup failed!")
            print("\n📋 ERROR:")
            print(result.stderr)
            print("\n📋 OUTPUT:")
            print(result.stdout)
            
        return result.returncode == 0
        
    except Exception as e:
        print(f"❌ Error running cleanup: {e}")
        return False

if __name__ == "__main__":
    success = run_cleanup()
    sys.exit(0 if success else 1)
