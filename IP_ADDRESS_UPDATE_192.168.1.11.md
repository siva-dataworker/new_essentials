# IP Address Update - 192.168.1.11

## Date: April 8, 2026

## Change Summary
Updated all IP addresses from `192.168.1.9` to `192.168.1.11`

## Previous IP
`192.168.1.9:8000`

## New IP
`192.168.1.11:8000`

## Files Updated

### Flutter Service Files (12 files)
- ✅ `lib/services/auth_service.dart`
- ✅ `lib/services/backend_service.dart`
- ✅ `lib/services/construction_service.dart`
- ✅ `lib/services/budget_service.dart`
- ✅ `lib/services/budget_management_service.dart`
- ✅ `lib/services/accountant_bills_service.dart`
- ✅ `lib/services/document_service.dart`
- ✅ `lib/services/export_service.dart`
- ✅ `lib/services/labor_mismatch_service.dart`
- ✅ `lib/services/material_service.dart`
- ✅ `lib/services/notification_service.dart`
- ✅ `lib/services/site_engineer_service.dart`

### Flutter Screen Files (8 files)
- ✅ `lib/screens/admin_dashboard.dart`
- ✅ `lib/screens/admin_site_full_view.dart`
- ✅ `lib/screens/simple_budget_screen.dart`
- ✅ `lib/screens/site_engineer_document_screen.dart`
- ✅ `lib/screens/site_photo_gallery_screen.dart`
- ✅ `lib/screens/supervisor_photo_upload_screen.dart`
- ✅ `lib/screens/accountant_bills_screen.dart`
- ✅ `lib/screens/accountant_entry_screen.dart`

### Backend Files
- ✅ All Python test scripts in `django-backend/`
- ✅ `START_SERVER.bat` - Updated to run on 192.168.1.11:8000

## Backend Server
The Django backend is now configured to run on:
```
http://192.168.1.11:8000
```

Start the server using:
```bash
cd django-backend
START_SERVER.bat
```

Or manually:
```bash
python manage.py runserver 192.168.1.11:8000
```

## Flutter App Rebuild Required

### IMPORTANT: You MUST rebuild the Flutter app
The IP address change requires a full rebuild:

```bash
cd otp_phone_auth
flutter clean
flutter pub get
flutter run
```

### Why rebuild is required:
- IP addresses are hardcoded constants in Dart files
- Hot restart will NOT pick up these changes
- Full rebuild compiles the new IP addresses into the app

## Verification Steps

1. Start the Django backend:
   ```bash
   cd django-backend
   START_SERVER.bat
   ```

2. Verify backend is running:
   - Open browser: `http://192.168.1.11:8000/api/`
   - Should see Django REST API root

3. Rebuild Flutter app:
   ```bash
   cd otp_phone_auth
   flutter clean
   flutter pub get
   flutter run
   ```

4. Test login with any user account

## Network Requirements
- Ensure your computer's IP address is `192.168.1.11`
- Check with: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- If IP is different, update all files again to match your actual IP
- Both computer and mobile device must be on the same network

## Troubleshooting

### If you get "Failed to fetch" error:
1. Check computer IP: `ipconfig`
2. Verify backend is running: `http://192.168.1.11:8000/api/`
3. Ensure phone and computer are on same WiFi
4. Check Windows Firewall allows port 8000
5. Rebuild Flutter app (not just hot restart)

### If backend won't start on 192.168.1.11:
1. Check your actual IP with `ipconfig`
2. Update START_SERVER.bat with correct IP
3. Update all Dart files with correct IP
4. Restart backend server

## Previous IP Updates
- Initial: 192.168.31.228
- Update 1: 192.168.1.9
- Update 2: 192.168.1.11 (current)
