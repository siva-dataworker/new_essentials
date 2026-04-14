# Installation Guide - Admin Budget Management System

## Quick Start

### Backend Setup (Django)

1. **Navigate to backend directory**:
```bash
cd django-backend
```

2. **Install Python dependencies**:
```bash
pip install -r requirements.txt
```

3. **Verify openpyxl installation**:
```bash
python -c "import openpyxl; print('✓ openpyxl installed successfully')"
```

4. **Start Django server**:
```bash
python manage.py runserver 0.0.0.0:8000
```

### Frontend Setup (Flutter)

1. **Navigate to Flutter directory**:
```bash
cd otp_phone_auth
```

2. **Install Flutter packages**:
```bash
flutter pub get
```

3. **Verify packages installed**:
```bash
flutter pub deps | grep -E "permission_handler|path_provider"
```

4. **Run the app**:
```bash
# For development
flutter run

# For release build
flutter run --release
```

## Android Permissions Setup

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

## Testing the Installation

### 1. Test Backend Export API

```bash
# Test labour export (replace {site_id} with actual UUID)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8000/api/export/labour-entries/{site_id}/ \
     --output test_labour.xlsx

# Check if file was created
ls -lh test_labour.xlsx
```

### 2. Test Flutter App

1. Open the app
2. Login as Admin
3. Select a site
4. Click download icon (⬇️) in top-right
5. Select "Export Labour Entries"
6. Check Downloads folder for Excel file

## Verification Checklist

- [ ] Backend server running on port 8000
- [ ] openpyxl package installed
- [ ] Flutter packages installed
- [ ] Android permissions added
- [ ] Export API responding
- [ ] Excel files downloading
- [ ] Files opening in Excel/Sheets

## Common Issues

### Issue: "openpyxl not found"
**Solution**:
```bash
pip install openpyxl==3.1.2
```

### Issue: "Permission denied" on Android
**Solution**:
1. Go to App Settings
2. Enable Storage permissions
3. Restart app

### Issue: "Export failed: 500"
**Solution**:
1. Check Django logs
2. Verify database connection
3. Ensure site_id exists

### Issue: "File not found after export"
**Solution**:
1. Check Downloads folder: `/storage/emulated/0/Download/`
2. Use file manager app
3. Check app has storage permission

## File Locations

### Backend Files
- Export views: `django-backend/api/views_export.py`
- URL routes: `django-backend/api/urls.py`
- Requirements: `django-backend/requirements.txt`

### Frontend Files
- Export service: `otp_phone_auth/lib/services/export_service.dart`
- Admin UI: `otp_phone_auth/lib/screens/admin_site_full_view.dart`
- Dependencies: `otp_phone_auth/pubspec.yaml`

## Next Steps

1. Test all export functions
2. Verify Excel file formatting
3. Check data accuracy
4. Test on multiple devices
5. Deploy to production

## Support

For issues or questions:
1. Check `ADMIN_BUDGET_COMPLETE_IMPLEMENTATION.md` for detailed documentation
2. Review `ADMIN_BUDGET_FEATURES_STATUS.md` for feature status
3. Check Django logs: `django-backend/logs/`
4. Check Flutter logs: `flutter logs`

## Production Deployment

### Backend
```bash
# Install production dependencies
pip install gunicorn

# Run with gunicorn
gunicorn backend.wsgi:application --bind 0.0.0.0:8000
```

### Frontend
```bash
# Build release APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## Success Indicators

✅ Backend server starts without errors
✅ Export endpoints return 200 status
✅ Excel files download successfully
✅ Files open in Excel/Google Sheets
✅ Data matches database records
✅ All permissions granted
✅ No crashes or errors

---

**Installation Complete!** 🎉

Your admin budget management system with Excel export is now ready to use.
