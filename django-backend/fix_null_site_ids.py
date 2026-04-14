import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import LabourEntry, MaterialBalance, Site, User

print("\n" + "="*60)
print("🔧 FIXING NULL SITE IDs")
print("="*60)

# Check labour entries with null site_id
null_labour = LabourEntry.objects.filter(site_id__isnull=True)
print(f"\n❌ Labour entries with null site_id: {null_labour.count()}")

# Check material entries with null site_id
null_material = MaterialBalance.objects.filter(site_id__isnull=True)
print(f"❌ Material entries with null site_id: {null_material.count()}")

if null_labour.count() == 0 and null_material.count() == 0:
    print("\n✅ No null site_ids found! Data is clean.")
    exit(0)

# Get first site as default
first_site = Site.objects.first()
if not first_site:
    print("\n❌ ERROR: No sites found in database!")
    print("   Please create a site first.")
    exit(1)

print(f"\n📍 Will assign entries to: {first_site.site_name} (ID: {first_site.id})")

# Fix labour entries
if null_labour.count() > 0:
    print(f"\n🔧 Fixing {null_labour.count()} labour entries...")
    for entry in null_labour:
        entry.site_id = first_site.id
        entry.save()
        print(f"   ✅ Fixed labour entry ID {entry.id}")

# Fix material entries
if null_material.count() > 0:
    print(f"\n🔧 Fixing {null_material.count()} material entries...")
    for entry in null_material:
        entry.site_id = first_site.id
        entry.save()
        print(f"   ✅ Fixed material entry ID {entry.id}")

print("\n" + "="*60)
print("✅ ALL NULL SITE IDs FIXED!")
print("="*60)

# Verify
print("\n📊 VERIFICATION:")
print(f"   Labour entries with null site_id: {LabourEntry.objects.filter(site_id__isnull=True).count()}")
print(f"   Material entries with null site_id: {MaterialBalance.objects.filter(site_id__isnull=True).count()}")
print(f"   Total labour entries: {LabourEntry.objects.count()}")
print(f"   Total material entries: {MaterialBalance.objects.count()}")

print("\n✅ Done! Now hot restart your Flutter app and try again.\n")
