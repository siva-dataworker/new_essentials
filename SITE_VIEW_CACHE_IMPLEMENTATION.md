# Site View Cache + Background Refresh Implementation Guide

## Overview
Implement persistent cache with background refresh for site-specific views in Accountant Entry Screen:
- **Roles**: Supervisor, Site Engineer, Architect
- **Tabs**: Labour, Materials, Requests, Photos
- **Total combinations**: 3 roles × 4 tabs = 12 data views

## Cache Service Methods Added ✅

### Added to `cache_service.dart`:

```dart
// Labour Data (per site + role)
- saveSiteLabourData(siteId, role, data)
- loadSiteLabourData(siteId, role) → List<Map<String, dynamic>>?
- clearSiteLabourData(siteId, role)

// Materials Data (per site + role)
- saveSiteMaterialsData(siteId, role, data)
- loadSiteMaterialsData(siteId, role) → List<Map<String, dynamic>>?
- clearSiteMaterialsData(siteId, role)

// Requests Data (per site + role)
- saveSiteRequestsData(siteId, role, data)
- loadSiteRequestsData(siteId, role) → List<Map<String, dynamic>>?
- clearSiteRequestsData(siteId, role)

// Photos Data (per site + role)
- saveSitePhotosData(siteId, role, data)
- loadSitePhotosData(siteId, role) → List<Map<String, dynamic>>?
- clearSitePhotosData(siteId, role)
```

## Cache Keys Structure

```
site_labour_{siteId}_{role}
site_materials_{siteId}_{role}
site_requests_{siteId}_{role}
site_photos_{siteId}_{role}

Example:
site_labour_123_supervisor
site_materials_123_site engineer
site_requests_123_architect
site_photos_123_supervisor
```

## Implementation Steps

### 1. Update Accountant Entry Screen

The screen shown in your image is the site-specific view. Let me find and update it:

#### Add Background Refresh Timers

```dart
class _AccountantEntryScreenState extends State<AccountantEntryScreen> {
  // Background refresh timers
  Timer? _labourRefreshTimer;
  Timer? _materialsRefreshTimer;
  Timer? _requestsRefreshTimer;
  Timer? _photosRefreshTimer;
  
  // Current selections
  String? _selectedSiteId;
  String _selectedRole = 'Supervisor'; // Supervisor | Site Engineer | Architect
  String _selectedTab = 'Labour'; // Labour | Materials | Requests | Photos
  
  // Data storage
  Map<String, List<Map<String, dynamic>>> _labourData = {};
  Map<String, List<Map<String, dynamic>>> _materialsData = {};
  Map<String, List<Map<String, dynamic>>> _requestsData = {};
  Map<String, List<Map<String, dynamic>>> _photosData = {};
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAreas();
  }
  
  @override
  void dispose() {
    _labourRefreshTimer?.cancel();
    _materialsRefreshTimer?.cancel();
    _requestsRefreshTimer?.cancel();
    _photosRefreshTimer?.cancel();
    super.dispose();
  }
}
```

#### Implement Cache-First Loading

```dart
Future<void> _loadSiteData(String siteId, String role) async {
  // Load all tabs data from cache first
  await Future.wait([
    _loadLabourDataWithCache(siteId, role),
    _loadMaterialsDataWithCache(siteId, role),
    _loadRequestsDataWithCache(siteId, role),
    _loadPhotosDataWithCache(siteId, role),
  ]);
  
  // Start background refresh
  _startBackgroundRefresh(siteId, role);
}

Future<void> _loadLabourDataWithCache(String siteId, String role) async {
  // 1. Load from cache FIRST (instant - 0ms)
  final cacheKey = '${siteId}_${role.toLowerCase()}';
  final cachedData = await CacheService.loadSiteLabourData(siteId, role);
  
  if (cachedData != null && cachedData.isNotEmpty) {
    setState(() {
      _labourData[cacheKey] = cachedData;
    });
  }
  
  // 2. Refresh from API in background (silent)
  _refreshLabourDataInBackground(siteId, role);
}

Future<void> _loadMaterialsDataWithCache(String siteId, String role) async {
  final cacheKey = '${siteId}_${role.toLowerCase()}';
  final cachedData = await CacheService.loadSiteMaterialsData(siteId, role);
  
  if (cachedData != null && cachedData.isNotEmpty) {
    setState(() {
      _materialsData[cacheKey] = cachedData;
    });
  }
  
  _refreshMaterialsDataInBackground(siteId, role);
}

Future<void> _loadRequestsDataWithCache(String siteId, String role) async {
  final cacheKey = '${siteId}_${role.toLowerCase()}';
  final cachedData = await CacheService.loadSiteRequestsData(siteId, role);
  
  if (cachedData != null && cachedData.isNotEmpty) {
    setState(() {
      _requestsData[cacheKey] = cachedData;
    });
  }
  
  _refreshRequestsDataInBackground(siteId, role);
}

Future<void> _loadPhotosDataWithCache(String siteId, String role) async {
  final cacheKey = '${siteId}_${role.toLowerCase()}';
  final cachedData = await CacheService.loadSitePhotosData(siteId, role);
  
  if (cachedData != null && cachedData.isNotEmpty) {
    setState(() {
      _photosData[cacheKey] = cachedData;
    });
  }
  
  _refreshPhotosDataInBackground(siteId, role);
}
```

#### Implement Background Refresh

```dart
void _startBackgroundRefresh(String siteId, String role) {
  // Cancel existing timers
  _labourRefreshTimer?.cancel();
  _materialsRefreshTimer?.cancel();
  _requestsRefreshTimer?.cancel();
  _photosRefreshTimer?.cancel();
  
  // Refresh labour data every 60 seconds
  _labourRefreshTimer = Timer.periodic(
    const Duration(seconds: 60),
    (_) => _refreshLabourDataInBackground(siteId, role),
  );
  
  // Refresh materials data every 60 seconds
  _materialsRefreshTimer = Timer.periodic(
    const Duration(seconds: 60),
    (_) => _refreshMaterialsDataInBackground(siteId, role),
  );
  
  // Refresh requests data every 90 seconds
  _requestsRefreshTimer = Timer.periodic(
    const Duration(seconds: 90),
    (_) => _refreshRequestsDataInBackground(siteId, role),
  );
  
  // Refresh photos data every 120 seconds
  _photosRefreshTimer = Timer.periodic(
    const Duration(seconds: 120),
    (_) => _refreshPhotosDataInBackground(siteId, role),
  );
}

Future<void> _refreshLabourDataInBackground(String siteId, String role) async {
  try {
    final provider = context.read<ConstructionProvider>();
    // Call your API method to get labour data
    final response = await provider.getSiteLabourData(siteId, role);
    
    if (response['success']) {
      final newData = List<Map<String, dynamic>>.from(response['data']);
      await CacheService.saveSiteLabourData(siteId, role, newData);
      
      if (mounted) {
        final cacheKey = '${siteId}_${role.toLowerCase()}';
        setState(() {
          _labourData[cacheKey] = newData;
        });
      }
    }
  } catch (e) {
    // Silent failure - keep showing cached data
    print('Background refresh failed for labour: $e');
  }
}

Future<void> _refreshMaterialsDataInBackground(String siteId, String role) async {
  try {
    final provider = context.read<ConstructionProvider>();
    final response = await provider.getSiteMaterialsData(siteId, role);
    
    if (response['success']) {
      final newData = List<Map<String, dynamic>>.from(response['data']);
      await CacheService.saveSiteMaterialsData(siteId, role, newData);
      
      if (mounted) {
        final cacheKey = '${siteId}_${role.toLowerCase()}';
        setState(() {
          _materialsData[cacheKey] = newData;
        });
      }
    }
  } catch (e) {
    print('Background refresh failed for materials: $e');
  }
}

Future<void> _refreshRequestsDataInBackground(String siteId, String role) async {
  try {
    final provider = context.read<ConstructionProvider>();
    final response = await provider.getSiteRequestsData(siteId, role);
    
    if (response['success']) {
      final newData = List<Map<String, dynamic>>.from(response['data']);
      await CacheService.saveSiteRequestsData(siteId, role, newData);
      
      if (mounted) {
        final cacheKey = '${siteId}_${role.toLowerCase()}';
        setState(() {
          _requestsData[cacheKey] = newData;
        });
      }
    }
  } catch (e) {
    print('Background refresh failed for requests: $e');
  }
}

Future<void> _refreshPhotosDataInBackground(String siteId, String role) async {
  try {
    final provider = context.read<ConstructionProvider>();
    final response = await provider.getSitePhotosData(siteId, role);
    
    if (response['success']) {
      final newData = List<Map<String, dynamic>>.from(response['data']);
      await CacheService.saveSitePhotosData(siteId, role, newData);
      
      if (mounted) {
        final cacheKey = '${siteId}_${role.toLowerCase()}';
        setState(() {
          _photosData[cacheKey] = newData;
        });
      }
    }
  } catch (e) {
    print('Background refresh failed for photos: $e');
  }
}
```

#### Handle Role/Tab Switching

```dart
void _onRoleChanged(String newRole) {
  setState(() {
    _selectedRole = newRole;
  });
  
  // Data already cached, instant switch
  // Background refresh will update if needed
}

void _onTabChanged(String newTab) {
  setState(() {
    _selectedTab = newTab;
  });
  
  // Data already cached, instant switch
}
```

## Background Refresh Intervals

| Data Type | Interval | Reason |
|-----------|----------|--------|
| Labour | 60s | Frequent updates (daily entries) |
| Materials | 60s | Frequent updates (daily entries) |
| Requests | 90s | Less frequent (change requests) |
| Photos | 120s | Least frequent (photos don't change often) |

## User Experience Flow

### First Time (Site Selection)
1. User selects site from dropdown
2. Load all 12 combinations from API (3-5 seconds)
3. Cache all data automatically
4. Display current role/tab data
5. Start background refresh timers

### Switching Roles (Supervisor → Site Engineer)
1. User taps "Site Engineer" chip
2. **Instant switch** (0ms) - Load from cache
3. Background refresh updates data silently

### Switching Tabs (Labour → Materials)
1. User taps "Materials" chip
2. **Instant switch** (0ms) - Load from cache
3. Background refresh updates data silently

### App Restart
1. Close app completely
2. Reopen app
3. Navigate to same site
4. **All data loads instantly** (0ms) from persistent cache
5. Background refresh updates silently

### Switching Sites
1. User selects different site
2. Check cache for new site
3. If cached: **Instant load** (0ms)
4. If not cached: Load from API (3-5s) + cache
5. Start background refresh for new site

## Cache Strategy

### Cache Hierarchy
```
Site ID
  ├── Supervisor
  │   ├── Labour
  │   ├── Materials
  │   ├── Requests
  │   └── Photos
  ├── Site Engineer
  │   ├── Labour
  │   ├── Materials
  │   ├── Requests
  │   └── Photos
  └── Architect
      ├── Labour
      ├── Materials
      ├── Requests
      └── Photos
```

### Cache Expiry
- **Duration**: 24 hours
- **Auto-clear**: Expired cache cleared automatically
- **Manual clear**: On logout or site change

### Memory Management
- Only cache data for currently selected site
- Clear cache for previous site when switching
- Maximum 12 data sets in memory at once

## Performance Optimization

### Preload Strategy
```dart
// When site is selected, preload all combinations
Future<void> _preloadAllSiteData(String siteId) async {
  final roles = ['Supervisor', 'Site Engineer', 'Architect'];
  
  for (final role in roles) {
    await Future.wait([
      _loadLabourDataWithCache(siteId, role),
      _loadMaterialsDataWithCache(siteId, role),
      _loadRequestsDataWithCache(siteId, role),
      _loadPhotosDataWithCache(siteId, role),
    ]);
  }
}
```

### Smart Refresh
```dart
// Only refresh visible tab more frequently
void _startSmartRefresh(String siteId, String role, String tab) {
  // Refresh current tab every 30 seconds
  // Refresh other tabs every 120 seconds
}
```

## Testing

### Test Instant Role Switch
```bash
1. Open app → Accountant → Entries
2. Select a site
3. Wait for data to load
4. Tap "Site Engineer" chip
5. ✅ Should switch INSTANTLY (0ms)
6. Tap "Architect" chip
7. ✅ Should switch INSTANTLY (0ms)
```

### Test Instant Tab Switch
```bash
1. On site view
2. Tap "Materials" tab
3. ✅ Should switch INSTANTLY (0ms)
4. Tap "Requests" tab
5. ✅ Should switch INSTANTLY (0ms)
6. Tap "Photos" tab
7. ✅ Should switch INSTANTLY (0ms)
```

### Test App Restart
```bash
1. Select a site and view data
2. Switch between roles and tabs
3. Close app completely
4. Reopen app
5. Navigate to same site
6. ✅ All data should load INSTANTLY (0ms)
7. ✅ Background refresh should update silently
```

### Test Background Refresh
```bash
1. Open site view
2. Wait 60 seconds
3. ✅ Labour data should update (silent)
4. Wait 60 seconds
5. ✅ Materials data should update (silent)
6. No loading spinners should appear
```

## Implementation Checklist

### Phase 1: Cache Service ✅
- [x] Add labour cache methods
- [x] Add materials cache methods
- [x] Add requests cache methods
- [x] Add photos cache methods

### Phase 2: Accountant Entry Screen
- [ ] Add cache import
- [ ] Add background refresh timers
- [ ] Implement cache-first loading for labour
- [ ] Implement cache-first loading for materials
- [ ] Implement cache-first loading for requests
- [ ] Implement cache-first loading for photos
- [ ] Implement background refresh for all tabs
- [ ] Handle role switching
- [ ] Handle tab switching
- [ ] Handle site switching

### Phase 3: Testing
- [ ] Test instant role switching
- [ ] Test instant tab switching
- [ ] Test app restart persistence
- [ ] Test background refresh
- [ ] Test site switching
- [ ] Test cache expiry
- [ ] Test offline mode

## Code Example: Complete Pattern

```dart
// When site is selected
void _onSiteSelected(String siteId, String siteName) {
  setState(() {
    _selectedSite = siteId;
    _selectedSiteName = siteName;
  });
  
  // Load all data with cache
  _loadAllSiteDataWithCache(siteId);
}

Future<void> _loadAllSiteDataWithCache(String siteId) async {
  final roles = ['Supervisor', 'Site Engineer', 'Architect'];
  
  // Load all combinations from cache (instant)
  for (final role in roles) {
    await Future.wait([
      _loadLabourDataWithCache(siteId, role),
      _loadMaterialsDataWithCache(siteId, role),
      _loadRequestsDataWithCache(siteId, role),
      _loadPhotosDataWithCache(siteId, role),
    ]);
  }
  
  // Start background refresh
  _startBackgroundRefresh(siteId, _selectedRole);
}

// Get current data for display
List<Map<String, dynamic>> _getCurrentData() {
  if (_selectedSite == null) return [];
  
  final cacheKey = '${_selectedSite}_${_selectedRole.toLowerCase()}';
  
  switch (_selectedTab) {
    case 'Labour':
      return _labourData[cacheKey] ?? [];
    case 'Materials':
      return _materialsData[cacheKey] ?? [];
    case 'Requests':
      return _requestsData[cacheKey] ?? [];
    case 'Photos':
      return _photosData[cacheKey] ?? [];
    default:
      return [];
  }
}
```

## Benefits

1. **Instant Role Switching** - 0ms between Supervisor/Site Engineer/Architect
2. **Instant Tab Switching** - 0ms between Labour/Materials/Requests/Photos
3. **Always Fresh Data** - Background refresh every 60-120 seconds
4. **Offline Support** - Show cached data when offline
5. **Better UX** - No loading spinners after first load
6. **Reduced Server Load** - Fewer API calls
7. **Battery Efficient** - Smart refresh intervals

## Summary

✅ Cache service methods added for all combinations
⏳ Accountant entry screen needs implementation
⏳ Background refresh needs implementation
⏳ Role/tab switching needs optimization

Follow the implementation steps above to complete the feature!

## Expected Results

After implementation:
- **Role switching**: Instant (0ms)
- **Tab switching**: Instant (0ms)
- **App restart**: Instant load (0ms)
- **Background refresh**: Silent updates every 60-120s
- **User experience**: Smooth, fast, no waiting
