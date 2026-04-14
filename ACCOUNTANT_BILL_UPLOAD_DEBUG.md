# Accountant Bill Upload - Debug Guide

## Issue Report
User reports that bills are not being uploaded in the accountant tab.

## System Status
✅ Backend server running on `http://192.168.1.2:8000`
✅ Database tables exist (material_bills, vendor_bills, site_agreements)
✅ API endpoints configured correctly
✅ Flutter service implementation looks correct

## API Endpoints

### Material Bill Upload
**Endpoint:** `POST /api/construction/upload-material-bill/`
**Method:** Multipart Form Data
**Authentication:** JWT Bearer Token

**Required Fields:**
- site_id (UUID)
- bill_number (string)
- bill_date (YYYY-MM-DD)
- vendor_name (string)
- vendor_type (string)
- material_type (string)
- quantity (decimal)
- unit (string)
- unit_price (decimal)
- total_amount (decimal)
- final_amount (decimal)
- file (PDF file)

**Optional Fields:**
- tax_amount (decimal, default: 0)
- discount_amount (decimal, default: 0)
- payment_status (string, default: 'PENDING')
- payment_mode (string)
- payment_date (YYYY-MM-DD)
- notes (text)
- description (text)

### Vendor Bill Upload
**Endpoint:** `POST /api/construction/upload-vendor-bill/`
**Method:** Multipart Form Data
**Authentication:** JWT Bearer Token

**Required Fields:**
- site_id (UUID)
- bill_number (string)
- bill_date (YYYY-MM-DD)
- vendor_name (string)
- vendor_type (string)
- service_type (string)
- amount (decimal)
- final_amount (decimal)
- file (PDF file)

## Testing Steps

### 1. Check Backend Logs
The backend server is running. When you try to upload a bill, check the terminal output for:
- POST request to `/api/construction/upload-material-bill/`
- Any error messages
- HTTP status code (should be 201 for success)

### 2. Test Upload from Flutter App
1. Open accountant dashboard
2. Navigate to Bills tab
3. Select a site
4. Click "Upload Material Bill" or "Upload Vendor Bill"
5. Fill in all required fields
6. Select a PDF file
7. Click "Upload"
8. Check for success/error message

### 3. Common Issues to Check

#### A. File Selection Issue
- Verify PDF file is selected
- Check file size (should be reasonable)
- Ensure file path is accessible

#### B. Network Issue
- Verify device can reach `http://192.168.1.2:8000`
- Check if JWT token is valid
- Verify Authorization header is sent

#### C. Validation Errors
- All required fields must be filled
- Dates must be in YYYY-MM-DD format
- Numbers must be valid decimals
- File must be PDF format

#### D. Database Issues
- Tables exist (verified ✅)
- Columns match expected schema
- Foreign key constraints (site_id, uploaded_by)

## Debug Commands

### Check if tables exist:
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_name IN ('material_bills', 'vendor_bills', 'site_agreements');
```

### Check table structure:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'material_bills'
ORDER BY ordinal_position;
```

### Check recent uploads:
```sql
SELECT id, bill_number, vendor_name, material_type, final_amount, upload_date
FROM material_bills
ORDER BY uploaded_at DESC
LIMIT 10;
```

## Expected Behavior

### Success Flow:
1. User fills form and selects PDF
2. Flutter app sends multipart POST request
3. Backend validates all fields
4. Backend saves PDF to `media/material_bills/` directory
5. Backend inserts record into database
6. Backend returns 201 with bill_id and file_url
7. Flutter shows success message
8. Bills list refreshes and shows new bill

### Error Flow:
1. User fills form (may miss required fields)
2. Flutter app sends request
3. Backend validates and finds error
4. Backend returns 400 with error message
5. Flutter shows error in SnackBar

## Files to Check

### Backend:
- `django-backend/api/views_accountant_documents.py` - Upload logic
- `django-backend/api/urls.py` - URL routing
- `django-backend/backend/settings.py` - MEDIA_ROOT, MEDIA_URL
- `django-backend/media/material_bills/` - Uploaded files directory

### Frontend:
- `otp_phone_auth/lib/services/accountant_bills_service.dart` - API calls
- `otp_phone_auth/lib/widgets/bill_upload_dialogs.dart` - Upload UI
- `otp_phone_auth/lib/screens/accountant_bills_screen.dart` - Bills list

## Next Steps

1. **Try uploading a bill** from the Flutter app
2. **Watch the backend terminal** for the POST request
3. **Check for error messages** in:
   - Backend terminal output
   - Flutter app SnackBar
   - Flutter debug console

4. **If upload fails**, note:
   - HTTP status code
   - Error message
   - Which field caused the error

5. **If upload succeeds but doesn't show**:
   - Check if GET request is made to fetch bills
   - Verify bills list is refreshing
   - Check if site_id filter is correct

## Media Directory Setup

The backend should automatically create these directories:
- `django-backend/media/material_bills/`
- `django-backend/media/vendor_bills/`
- `django-backend/media/site_agreements/`

If they don't exist, create them manually:
```bash
cd django-backend
mkdir -p media/material_bills
mkdir -p media/vendor_bills
mkdir -p media/site_agreements
```

## Permissions

Ensure the Django process has write permissions to the media directory:
```bash
chmod -R 755 django-backend/media/
```

---

**Status:** Ready for testing
**Backend:** Running ✅
**Database:** Tables exist ✅
**Next:** User needs to attempt upload and report specific error
