# Testing Guide: Admin All Working Sites Feature

## Prerequisites
- Django backend running on `http://localhost:8000`
- Flutter app running (web or mobile)
- Admin user account

## Test Steps

### 1. Login as Admin
1. Open the Flutter app
2. Login with admin credentials
3. You should see the Admin Dashboard

### 2. Navigate to All Working Sites
1. On the Admin Dashboard, find the "Quick Actions" section
2. Click on "All Working Sites" button (dark blue with construction icon)
3. You should be redirected to the "All Working Sites" screen

### 3. Verify Initial Load
**Expected Results**:
- Screen title: "All Working Sites"
- Search bar at the top (always visible)
- Filter icon in app bar (outline icon)
- Refresh icon in app bar
- Results count showing "3 sites found" (based on current database)
- 3 site cards displayed:
  1. Anwar 6 22 Ibrahim
  2. Arjun 12 22 Prakash
  3. Basha 10 25 Karim

**Check Console Logs**:
```
🔍 [ADMIN] Loading working sites...
🔍 [SERVICE] getWorkingSites called
🔍 [SERVICE] User role: Admin
✅ [SERVICE] Using ADMIN endpoint: http://localhost:8000/api/construction/admin/all-working-sites/
📊 [SERVICE] Response status: 200
✅ [SERVICE] Success! Returning 3 sites
✅ [ADMIN] Loaded 3 working sites
```

### 4. Test Search Filter
1. Click on the search bar
2. Type "Anwar" (or any part of a site name)
3. **Expected**: Only sites matching "Anwar" should appear
4. **Expected**: Results count updates to "1 site found"
5. Clear the search (X button)
6. **Expected**: All 3 sites appear again

### 5. Test Area Filter
1. Click the filter icon in the app bar
2. **Expected**: Filter section expands below search bar
3. Click on "Filter by Area" dropdown
4. **Expected**: See options: "All Areas", "Karaikal", "Thiruvettakudy"
5. Select "Karaikal"
6. **Expected**: 
   - Only sites in Karaikal area appear (2 sites)
   - Results count shows "2 sites found"
   - "Filtered" badge appears
   - Street filter dropdown appears

### 6. Test Street Filter
1. With "Karaikal" area selected
2. Click on "Filter by Street" dropdown
3. **Expected**: See streets only from Karaikal: "Main Road", "Temple Street"
4. Select "Main Road"
5. **Expected**: 
   - Only "Basha 10 25 Karim" appears (1 site)
   - Results count shows "1 site found"

### 7. Test Clear Filters
1. With filters active
2. Click "Clear All Filters" button
3. **Expected**:
   - All filters reset
   - Search bar cleared
   - All 3 sites appear
   - "Filtered" badge disappears
   - Street filter dropdown disappears

### 8. Test Empty State (No Results)
1. Type "xyz123" in search bar
2. **Expected**:
   - Empty state icon (search_off)
   - "No Sites Found" message
   - "Try adjusting your filters" message
   - "Clear Filters" button appears

### 9. Test Site Card Display
For each site card, verify:
- ✅ Display name (e.g., "Basha 10 25 Karim")
- ✅ Area badge with location icon (e.g., "Karaikal")
- ✅ Street with route icon (e.g., "Main Road")
- ✅ Update count badges (if any):
  - Blue badge with people icon (labour count)
  - Green badge with inventory icon (material count)
  - Orange badge with camera icon (photo count)
- ✅ Last update timestamp (if any)
- ✅ Arrow icon on the right

### 10. Test Pull to Refresh
1. Scroll down on the site list
2. Pull down to trigger refresh
3. **Expected**: 
   - Loading indicator appears
   - Sites reload
   - Console shows reload logs

### 11. Test Filter Toggle
1. Click filter icon to show filters
2. Click filter icon again
3. **Expected**: Filter section collapses/expands

## Database Verification

Run this query to verify the data:
```sql
SELECT 
    s.id,
    s.site_name,
    s.customer_name,
    s.area,
    s.street,
    COUNT(ws.id) as assignment_count
FROM working_sites ws
JOIN sites s ON ws.site_id = s.id
WHERE ws.is_active = TRUE
GROUP BY s.id, s.site_name, s.customer_name, s.area, s.street
ORDER BY s.customer_name, s.site_name;
```

**Expected Result**: 3 unique sites

## Common Issues and Solutions

### Issue 1: Duplicate Sites Appearing
**Symptom**: Same site appears multiple times
**Solution**: Backend should use `GROUP BY s.id` (already implemented)
**Verify**: Check console logs for site count

### Issue 2: Timezone Error
**Symptom**: Error comparing datetime objects
**Solution**: Backend removes timezone info before comparison (already implemented)
**Verify**: No errors in Django console

### Issue 3: Empty Screen
**Symptom**: No sites appear even though database has data
**Solution**: 
- Check if user is logged in as Admin
- Check console logs for API errors
- Verify backend endpoint is accessible
- Check if `is_active = TRUE` in working_sites table

### Issue 4: Filters Not Working
**Symptom**: Selecting filters doesn't change results
**Solution**: 
- Check console logs for filter application
- Verify `_applyFilters()` method is called
- Check if area/street values match database exactly

## Success Criteria
- ✅ Admin can view all working sites (3 unique sites, not 12 duplicates)
- ✅ Search filter works correctly
- ✅ Area filter shows correct areas
- ✅ Street filter updates based on area
- ✅ Clear filters resets everything
- ✅ Results count is accurate
- ✅ Site cards display all information
- ✅ Empty states work correctly
- ✅ No timezone errors in console
- ✅ Pull to refresh works

## Performance Notes
- Initial load should be fast (< 1 second)
- Filter application should be instant (client-side)
- Search should be real-time (no delay)
- Refresh should complete in < 2 seconds

## Next Steps After Testing
If all tests pass:
1. Test with more sites (50+) to verify filter performance
2. Add site detail screen navigation
3. Consider adding sorting options
4. Consider adding export functionality

If tests fail:
1. Check console logs for errors
2. Verify database has correct data
3. Check backend endpoint response
4. Verify Flutter service method
5. Check UI state management
