# Test Photo Viewing - All Roles

## Quick Test Flow

### Step 1: Site Engineer Uploads Photos

**Login:**
- Username: `siteengineer1`
- Password: `password123`

**Actions:**
1. View dashboard with site cards
2. Click on any site card
3. Click "Upload Photo" button
4. Select "Morning" mode (if before 1 PM)
5. Take or choose a photo
6. Add description: "Foundation work started"
7. Click "Upload Photo"
8. Verify success message
9. Return to dashboard
10. Verify morning indicator shows green ✅

**Repeat for Evening:**
1. Wait until after 1 PM (or change device time)
2. Upload evening photo
3. Description: "Foundation work completed"
4. Verify evening indicator shows green ✅

---

### Step 2: Accountant Views Photos

**Login:**
- Username: `accountant1`
- Password: `password123`

**Actions:**
1. View dashboard (Entries tab)
2. Click on the SAME site card that Site Engineer uploaded to
3. Navigate to "Photos" tab (4th tab)
4. Verify photos appear in grid view
5. Check morning photo shows 🌅
6. Check evening photo shows 🌆
7. Test filters:
   - Click "All Photos" - shows both
   - Click "🌅 Morning" - shows only morning
   - Click "🌆 Evening" - shows only evening
8. Tap any photo to open full screen
9. Verify photo details:
   - Upload type (Morning/Evening)
   - Date and time
   - Uploader: "Site Engineer Name"
   - Description
10. Swipe left/right to navigate
11. Pinch to zoom in/out
12. Back button to return to grid

---

### Step 3: Supervisor Views Photos

**Login:**
- Username: `supervisor1`
- Password: `password123`

**Actions:**
1. View dashboard (Home tab)
2. Click on the SAME site card
3. Click the + icon (bottom right)
4. Quick Actions menu appears
5. Click "View Photos"
6. Verify photo gallery opens
7. See both morning and evening photos
8. Test filters
9. Tap photo for full screen
10. Verify all details correct
11. Test swipe and zoom

---

### Step 4: Architect Views Photos

**Login:**
- Username: `architect1`
- Password: `password123`

**Actions:**
1. View dashboard with site cards
2. Find the SAME site card
3. Look at action buttons:
   - Estimation | Plans
   - Complaints | Photos
4. Click "Photos" button (green)
5. Photo gallery opens
6. Verify photos appear
7. Test filters
8. Open full screen
9. Verify details
10. Test navigation

---

## Expected Results

### All Roles Should See:
- ✅ Same photos uploaded by Site Engineer
- ✅ Morning photo with 🌅 indicator
- ✅ Evening photo with 🌆 indicator
- ✅ Correct upload date/time
- ✅ Uploader name: Site Engineer
- ✅ Description text
- ✅ Filters work correctly
- ✅ Full screen viewer functional
- ✅ Swipe navigation smooth
- ✅ Pinch zoom works

### Photo Details Should Show:
- **Update Type:** Morning - Work Started OR Evening - Work Completed
- **Date:** Today / Yesterday / DD/MM/YYYY
- **Time:** HH:MM AM/PM (IST format)
- **Uploaded By:** [Site Engineer Name] (Site Engineer)
- **Description:** [User entered text]

---

## Troubleshooting

### Photos Not Showing
1. Verify Site Engineer uploaded successfully
2. Check backend is running
3. Verify correct site card is opened
4. Pull down to refresh
5. Check backend logs for errors

### Wrong Photos Showing
1. Verify site_id matches
2. Check API response in backend logs
3. Ensure filtering by site_id works

### Full Screen Not Working
1. Check image URLs are valid
2. Test direct URL in browser
3. Verify media serving enabled
4. Check network connection

### Filters Not Working
1. Verify update_type in API response
2. Check filter logic in code
3. Test with console logs

---

## Test Matrix

| Role | Access Method | Expected Result |
|------|---------------|-----------------|
| Site Engineer | Dashboard → Upload Photo | Can upload & view |
| Accountant | Site Card → Photos Tab | Can view all photos |
| Supervisor | Site Card → + → View Photos | Can view all photos |
| Architect | Site Card → Photos Button | Can view all photos |
| Owner | Not implemented yet | N/A |

---

## Success Criteria

- ✅ Site Engineer can upload morning photo (before 1 PM)
- ✅ Site Engineer can upload evening photo (after 1 PM)
- ✅ Accountant can view photos in Photos tab
- ✅ Supervisor can view photos via Quick Actions
- ✅ Architect can view photos via Photos button
- ✅ All roles see the same photos for each site
- ✅ Filters work correctly for all roles
- ✅ Full screen viewer works for all roles
- ✅ Photo details are accurate
- ✅ Navigation and zoom work smoothly

---

## Test Credentials

| Role | Username | Password |
|------|----------|----------|
| Site Engineer | siteengineer1 | password123 |
| Accountant | accountant1 | password123 |
| Supervisor | supervisor1 | password123 |
| Architect | architect1 | password123 |

---

## Quick Commands

### Start Backend
```bash
cd django-backend
python manage.py runserver
```

### Run Flutter App
```bash
cd otp_phone_auth
flutter run
# OR press R for hot restart
```

### Check Backend Health
```
http://192.168.1.7:8000/api/health/
```

---

**Status:** Ready for testing ✅
**Last Updated:** December 29, 2025
