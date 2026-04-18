# Photos Tab Debug Status

## Current Status

Added comprehensive debug logging to the photos loading function to diagnose why photos are not appearing.

## Debug Logging Added

The `_loadSupervisorPhotos()` method now logs:
- When the method is called
- Selected site ID
- Token retrieval status
- Full API URL being called
- Response status code
- Response body content
- Number of photos loaded
- Any errors that occur

## How to Debug

1. Run the app: `flutter run -d chrome`
2. Navigate to Entry Screen → Select a site
3. Click on "Photos" tab
4. Check the console/terminal for debug output

Look for these log messages:
```
🔍 [PHOTOS] _loadSupervisorPhotos called
🔍 [PHOTOS] _selectedSite = <site_id>
🔍 [PHOTOS] Token obtained
🔍 [PHOTOS] Calling API: <url>
🔍 [PHOTOS] Response status: <code>
🔍 [PHOTOS] Response body: <json>
✅ [PHOTOS] Loaded X photos
```

## Common Issues to Check

### 1. API Endpoint Issue
- Check if the URL is correct: `https://new-essentials.onrender.com/api/construction/supervisor-photos-for-accountant/`
- Verify the `site_id` parameter is being passed correctly

### 2. Authentication Issue
- Check if token is valid
- Verify Authorization header is correct

### 3. Backend Issue
- Check if the endpoint exists on the backend
- Verify the backend is returning data in the correct format:
```json
{
  "success": true,
  "photos": [
    {
      "id": 1,
      "image_url": "/media/photos/...",
      "upload_date": "2026-04-04",
      "time_of_day": "Morning",
      "supervisor_name": "John Doe",
      "description": "..."
    }
  ]
}
```

### 4. Data Format Issue
- Check if `time_of_day` field matches "Morning" or "Evening" (case-insensitive)
- Verify `upload_date` is in correct format
- Check if `image_url` is a valid path

## Next Steps

Based on the debug output, we can:

1. **If API returns 404**: Backend endpoint doesn't exist or URL is wrong
2. **If API returns 401**: Authentication issue
3. **If API returns 200 but no photos**: Backend has no data or filtering issue
4. **If API returns 200 with photos but they don't display**: Frontend rendering issue

## State Management Implementation (Pending)

Once we confirm the API is working, we'll implement:

1. **Provider Integration**:
   - Use `ConstructionProvider.loadSupervisorPhotos()` instead of FutureBuilder
   - Add caching with `SimpleCache`
   - Implement background refresh

2. **Cache Strategy**:
   - Cache photos for 5 minutes
   - Auto-refresh on tab switch
   - Pull-to-refresh support

3. **Performance**:
   - Load photos once per site
   - Reuse cached data when switching between tabs
   - Background refresh without blocking UI

## Files Modified

- `otp_phone_auth/lib/screens/accountant_entry_screen.dart` - Added debug logging
- `otp_phone_auth/lib/providers/construction_provider.dart` - Already has `loadSupervisorPhotos` method ready

## Testing

Run the app and check console output to see what's happening with the API call.
