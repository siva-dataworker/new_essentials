# Photo API Fixed - Column Name Issue ✅

## Issue

Accountant couldn't see photos uploaded by Site Engineer.

## Root Cause

The `get_site_photos` API was using the wrong column name:
- **Used:** `created_at`
- **Actual:** `uploaded_at`

The `work_updates` table has `uploaded_at` column, not `created_at`.

## Fix Applied

**File:** `django-backend/api/views_construction.py`

### Before:
```python
SELECT 
    w.created_at,
    ...
FROM work_updates w
...
ORDER BY w.created_at DESC
```

### After:
```python
SELECT 
    w.uploaded_at,
    ...
FROM work_updates w
...
ORDER BY w.uploaded_at DESC
```

## Verification

Tested with existing photo in database:
```
Photo ID: 4ea5a365-feba-4121-92c5-a7362351bb61
Site ID: 3ae88295-427b-49f6-8e50-4c02d0250617
Type: FINISHED
Uploaded By: balu (Site Engineer)
Date: 2025-12-29
```

API now returns correct data format.

## IMPORTANT: Restart Backend

**You MUST restart the Django backend for changes to take effect:**

```bash
# Stop current backend (Ctrl+C)
cd django-backend
python manage.py runserver
```

## Test After Restart

### 1. Site Engineer Upload
- Login as Site Engineer
- Upload a photo
- Verify success message

### 2. Accountant View
- Login as Accountant
- Click on the SAME site card
- Navigate to "Photos" tab
- **Should now see the photo!**

### 3. Supervisor View
- Login as Supervisor
- Click site card → + icon → "View Photos"
- Should see photos

### 4. Architect View
- Login as Architect
- Click "Photos" button on site card
- Should see photos

## API Endpoint

**GET** `/api/construction/site-photos/<site_id>/`

Returns:
```json
{
  "photos": [
    {
      "id": "uuid",
      "update_type": "STARTED" or "FINISHED",
      "image_url": "/media/site_photos/...",
      "description": "text",
      "update_date": "2025-12-29",
      "created_at": "2025-12-29T10:25:35.179376",
      "uploaded_by": "Site Engineer Name",
      "uploaded_by_role": "Site Engineer"
    }
  ]
}
```

## Files Changed

| File | Change |
|------|--------|
| `django-backend/api/views_construction.py` | Fixed column name from `created_at` to `uploaded_at` |

## Status: FIXED ✅

Backend code updated. **Restart backend to apply changes.**

---

**Last Updated:** December 29, 2025
**Issue:** Photos not visible to Accountant
**Cause:** Wrong column name in SQL query
**Fix:** Changed `created_at` to `uploaded_at`
**Action Required:** Restart Django backend
