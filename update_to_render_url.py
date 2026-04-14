"""
Update all Flutter service files to use Render URL
"""
import os
import re

# Old and new URLs
OLD_URL = "http://192.168.1.9:8000"
NEW_URL = "https://essentials-construction-project.onrender.com"

# Directories to search
SERVICE_DIR = "otp_phone_auth/lib/services"
SCREEN_DIR = "otp_phone_auth/lib/screens"

def update_file(filepath):
    """Update URL in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if file contains old URL
        if OLD_URL in content:
            # Replace URL
            new_content = content.replace(OLD_URL, NEW_URL)
            
            # Write back
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            return True
        return False
    except Exception as e:
        print(f"   Error updating {filepath}: {e}")
        return False

def update_directory(directory):
    """Update all Dart files in directory"""
    updated_files = []
    
    if not os.path.exists(directory):
        print(f"   Directory not found: {directory}")
        return updated_files
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                if update_file(filepath):
                    updated_files.append(filepath)
    
    return updated_files

print("=" * 70)
print("UPDATING FLUTTER APP TO USE RENDER URL")
print("=" * 70)

print(f"\nOld URL: {OLD_URL}")
print(f"New URL: {NEW_URL}")

# Update service files
print(f"\n1. Updating service files in {SERVICE_DIR}...")
service_files = update_directory(SERVICE_DIR)
print(f"   ✅ Updated {len(service_files)} service files")
for f in service_files:
    print(f"      - {os.path.basename(f)}")

# Update screen files
print(f"\n2. Updating screen files in {SCREEN_DIR}...")
screen_files = update_directory(SCREEN_DIR)
print(f"   ✅ Updated {len(screen_files)} screen files")
for f in screen_files:
    print(f"      - {os.path.basename(f)}")

total_updated = len(service_files) + len(screen_files)

print("\n" + "=" * 70)
print(f"✅ TOTAL FILES UPDATED: {total_updated}")
print("=" * 70)

print("\nNext steps:")
print("1. cd otp_phone_auth")
print("2. flutter clean")
print("3. flutter pub get")
print("4. flutter run")
print("\nYour app will now work from anywhere in the world! 🌍")
