# Working Sites Count Fixed for Accountant Dashboard

## Issue
The "Working Sites" count on the Accountant Dashboard was showing 1 instead of 3. The issue was that it was counting only sites that had entries (labour or material data), not the total sites assigned to the accountant.

## Root Cause
The dashboard was calculating working sites by counting unique `site_id` values from labour and material entries:
```dart
// OLD - WRONG: Counts only sites with entries
final uniqueSiteIds = <String>{};
for (var entry in _labourEntries + _materialEntries) {
  final siteId = entry['site_id']?.toString() ?? '';
  if (siteId.isNotEmpty) {
    uniqueSiteIds.add(siteId);
  }
}
final workingSitesCount = uniqueSiteIds.length; // Shows 1 (only sites with data)
```

This meant if the accountant was assigned to 3 sites but only 1 site had entries, it would show 1.

## Solution
Created a new backend API endpoint that returns the count of unique sites assigned by the accountant from the `working_sites` table:

### Backend Changes

1. **New API Endpoint** (`views_construction.py`):
```python
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_accountant_working_sites_count(request):
    """
    Accountant: Get count of unique sites assigned by this accountant
    GET /api/construction/accountant-working-sites-count/
    """
    user_id = request.user['user_id']
    
    # Get count of unique sites assigned by this accountant
    result = fetch_one("""
        SELECT COUNT(DISTINCT site_id) as count
        FROM working_sites
        WHERE accountant_id = %s AND is_active = TRUE
    """, (user_id,))
    
    sites_count = result['count'] if result else 0
    
    return Response({
        'success': True,
        'working_sites_count': sites_count
    }, status=status.HTTP_200_OK)
```

2. **URL Route** (`urls.py`):
```python
path('construction/accountant-working-sites-count/', 
     views_construction.get_accountant_working_sites_count, 
     name='accountant-working-sites-count'),
```

### Frontend Changes

1. **Added State Variable** (`accountant_dashboard.dart`):
```dart
int _workingSitesCount = 0; // Count of sites assigned by this accountant
```

2. **Fetch Method**:
```dart
Future<void> _fetchWorkingSitesCount() async {
  final authService = AuthService();
  final token = await authService.getToken();
  
  final response = await http.get(
    Uri.parse('${AuthService.baseUrl}/construction/accountant-working-sites-count/'),
    headers: {'Authorization': 'Bearer $token'},
  ).timeout(const Duration(seconds: 5));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      _workingSitesCount = data['working_sites_count'] ?? 0;
    });
  }
}
```

3. **Updated Dashboard Content**:
```dart
Widget _buildDashboardContent() {
  // Working sites count comes from API (_workingSitesCount)
  final workingSitesCount = _workingSitesCount;
  
  // ... rest of the dashboard
}
```

4. **Integrated into Data Loading**:
- Called in `_loadAccountantDataWithCache()` - loads from cache
- Called in `_loadAccountantData()` - fetches fresh data
- Called in `_refreshDashboardInBackground()` - background refresh
- Cached in dashboard data for instant load on next app start

## How It Works Now

1. **On Dashboard Load**:
   - Loads cached working sites count instantly (0ms)
   - Fetches fresh count from API in background
   - Updates UI when fresh data arrives

2. **Data Source**:
   - Queries `working_sites` table where `accountant_id` matches current user
   - Counts DISTINCT `site_id` values where `is_active = TRUE`
   - Returns total assigned sites (3) not sites with entries (1)

3. **Caching**:
   - Working sites count is cached in dashboard data
   - Refreshed every 60 seconds in background
   - Persisted to local storage for instant load

## Result
- **Before**: Working Sites = 1 (only sites with entries)
- **After**: Working Sites = 3 (all assigned sites)

## Files Modified
- `essential/essential/construction_flutter/django-backend/api/views_construction.py` - Added endpoint
- `essential/essential/construction_flutter/django-backend/api/urls.py` - Added route
- `essential/essential/construction_flutter/otp_phone_auth/lib/screens/accountant_dashboard.dart` - Updated UI logic

## Testing
1. Login as accountant
2. Check "Working Sites" count on dashboard
3. Should show 3 (total assigned sites) not 1 (sites with entries)
4. Verify count updates when sites are assigned/unassigned

## Notes
- The `working_sites` table tracks which sites an accountant has assigned to supervisors
- Each accountant can assign multiple sites to multiple supervisors
- The count shows unique sites, not total assignments (same site to multiple supervisors = 1)
- Only active assignments (`is_active = TRUE`) are counted
