# Accountant Cache + Background Refresh Implementation Guide

## Overview
Implement persistent cache with background refresh for Accountant role across all tabs:
1. **Entries** - Labour & Material entries
2. **Dashboard** - Summary statistics
3. **Reports** - Financial reports
4. **Profile** - User profile data

## Cache Service Methods Added ✅

### Added to `cache_service.dart`:

```dart
// Labour Entries
- saveAccountantLabour(List<Map<String, dynamic>> entries)
- loadAccountantLabour() → List<Map<String, dynamic>>?
- clearAccountantLabour()

// Material Entries  
- saveAccountantMaterial(List<Map<String, dynamic>> entries)
- loadAccountantMaterial() → List<Map<String, dynamic>>?
- clearAccountantMaterial()

// Dashboard Data
- saveAccountantDashboard(Map<String, dynamic> data)
- loadAccountantDashboard() → Map<String, dynamic>?
- clearAccountantDashboard()
```

## Implementation Steps

### 1. Update Accountant Dashboard

#### Add Cache Import
```dart
import '../services/cache_service.dart';
import 'dart:async';
```

#### Add Background Refresh Timers
```dart
class _AccountantDashboardState extends State<AccountantDashboard> {
  // Background refresh timers
  Timer? _labourRefreshTimer;
  Timer? _materialRefreshTimer;
  Timer? _dashboardRefreshTimer;
  
  @override
  void initState() {
    super.initState();
    _loadDataWithCache();
    _startBackgroundRefresh();
  }
  
  @override
  void dispose() {
    _labourRefreshTimer?.cancel();
    _materialRefreshTimer?.cancel();
    _dashboardRefreshTimer?.cancel();
    super.dispose();
  }
}
```

#### Implement Cache-First Loading
```dart
Future<void> _loadDataWithCache() async {
  // 1. Load from cache FIRST (instant - 0ms)
  final cachedLabour = await CacheService.loadAccountantLabour();
  final cachedMaterial = await CacheService.loadAccountantMaterial();
  final cachedDashboard = await CacheService.loadAccountantDashboard();
  
  if (cachedLabour != null && cachedMaterial != null) {
    setState(() {
      _labourEntries = cachedLabour;
      _materialEntries = cachedMaterial;
      _dashboardData = cachedDashboard;
      _isLoading = false;
    });
  }
  
  // 2. Refresh from API in background (silent)
  _refreshDataInBackground();
}
```

#### Implement Background Refresh
```dart
void _startBackgroundRefresh() {
  // Refresh labour entries every 60 seconds
  _labourRefreshTimer = Timer.periodic(
    const Duration(seconds: 60),
    (_) => _refreshLabourInBackground(),
  );
  
  // Refresh material entries every 60 seconds
  _materialRefreshTimer = Timer.periodic(
    const Duration(seconds: 60),
    (_) => _refreshMaterialInBackground(),
  );
  
  // Refresh dashboard every 90 seconds
  _dashboardRefreshTimer = Timer.periodic(
    const Duration(seconds: 90),
    (_) => _refreshDashboardInBackground(),
  );
}

Future<void> _refreshLabourInBackground() async {
  try {
    final provider = context.read<ConstructionProvider>();
    await provider.loadAccountantLabourEntries(forceRefresh: true);
    
    final newData = provider.accountantLabourEntries;
    await CacheService.saveAccountantLabour(newData);
    
    if (mounted) {
      setState(() {
        _labourEntries = newData;
      });
    }
  } catch (e) {
    // Silent failure - keep showing cached data
  }
}

Future<void> _refreshMaterialInBackground() async {
  try {
    final provider = context.read<ConstructionProvider>();
    await provider.loadAccountantMaterialEntries(forceRefresh: true);
    
    final newData = provider.accountantMaterialEntries;
    await CacheService.saveAccountantMaterial(newData);
    
    if (mounted) {
      setState(() {
        _materialEntries = newData;
      });
    }
  } catch (e) {
    // Silent failure - keep showing cached data
  }
}

Future<void> _refreshDashboardInBackground() async {
  try {
    // Load dashboard stats
    final stats = await _loadDashboardStats();
    await CacheService.saveAccountantDashboard(stats);
    
    if (mounted) {
      setState(() {
        _dashboardData = stats;
      });
    }
  } catch (e) {
    // Silent failure - keep showing cached data
  }
}
```

### 2. Update Accountant Entry Screen

```dart
class _AccountantEntryScreenState extends State<AccountantEntryScreen> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _loadEntriesWithCache();
    _startBackgroundRefresh();
  }
  
  Future<void> _loadEntriesWithCache() async {
    // Load from cache first
    final cachedLabour = await CacheService.loadAccountantLabour();
    final cachedMaterial = await CacheService.loadAccountantMaterial();
    
    if (cachedLabour != null) {
      setState(() {
        _labourEntries = cachedLabour;
        _isLoading = false;
      });
    }
    
    if (cachedMaterial != null) {
      setState(() {
        _materialEntries = cachedMaterial;
      });
    }
    
    // Refresh in background
    _refreshInBackground();
  }
  
  void _startBackgroundRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _refreshInBackground(),
    );
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

### 3. Update Accountant Reports Screen

```dart
class _AccountantReportsScreenState extends State<AccountantReportsScreen> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _loadReportsWithCache();
    _startBackgroundRefresh();
  }
  
  Future<void> _loadReportsWithCache() async {
    // Load from cache first
    final cachedDashboard = await CacheService.loadAccountantDashboard();
    
    if (cachedDashboard != null) {
      setState(() {
        _reportData = cachedDashboard;
        _isLoading = false;
      });
    }
    
    // Refresh in background
    _refreshInBackground();
  }
  
  void _startBackgroundRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) => _refreshInBackground(),
    );
  }
}
```

### 4. Profile Screen (Already Fast)
Profile data is loaded from AuthService which already caches user data in SharedPreferences.

## Background Refresh Intervals

| Screen | Interval | Reason |
|--------|----------|--------|
| Entries (Labour) | 60s | Frequent updates |
| Entries (Material) | 60s | Frequent updates |
| Dashboard | 90s | Summary data, less frequent |
| Reports | 90s | Financial data, less frequent |
| Profile | On-demand | Rarely changes |

## User Experience Flow

### App Open (First Time)
1. Show loading spinner (1-3 seconds)
2. Load data from API
3. Save to cache
4. Display data

### App Open (Subsequent)
1. **Instant display** (0ms) - Load from cache
2. Background refresh (silent)
3. Update UI quietly when new data arrives

### App in Background
- Timers paused automatically
- No unnecessary API calls

### App Returns to Foreground
- Timers resume
- Immediate background refresh
- User sees cached data instantly

## Cache Expiry

- **Duration**: 24 hours
- **Auto-clear**: Expired cache cleared automatically
- **Manual clear**: On logout or data corruption

## Implementation Checklist

### Phase 1: Cache Service ✅
- [x] Add accountant labour cache methods
- [x] Add accountant material cache methods
- [x] Add accountant dashboard cache methods

### Phase 2: Accountant Dashboard
- [ ] Add cache import
- [ ] Add background refresh timers
- [ ] Implement cache-first loading
- [ ] Implement background refresh
- [ ] Test instant load on app restart

### Phase 3: Accountant Entry Screen
- [ ] Add cache import
- [ ] Implement cache-first loading
- [ ] Add background refresh
- [ ] Test with labour entries
- [ ] Test with material entries

### Phase 4: Accountant Reports Screen
- [ ] Add cache import
- [ ] Implement cache-first loading
- [ ] Add background refresh
- [ ] Test report generation

### Phase 5: Testing
- [ ] Test app restart (should be instant)
- [ ] Test background refresh (should be silent)
- [ ] Test cache expiry (24 hours)
- [ ] Test offline mode (show cached data)
- [ ] Test data updates (should update quietly)

## Code Example: Complete Implementation

```dart
// accountant_dashboard.dart
import 'dart:async';
import '../services/cache_service.dart';

class _AccountantDashboardState extends State<AccountantDashboard> {
  // Timers
  Timer? _labourRefreshTimer;
  Timer? _materialRefreshTimer;
  Timer? _dashboardRefreshTimer;
  
  // Data
  List<Map<String, dynamic>> _labourEntries = [];
  List<Map<String, dynamic>> _materialEntries = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAllDataWithCache();
    _startBackgroundRefresh();
  }
  
  @override
  void dispose() {
    _labourRefreshTimer?.cancel();
    _materialRefreshTimer?.cancel();
    _dashboardRefreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadAllDataWithCache() async {
    // Load from cache FIRST (instant)
    final cachedLabour = await CacheService.loadAccountantLabour();
    final cachedMaterial = await CacheService.loadAccountantMaterial();
    final cachedDashboard = await CacheService.loadAccountantDashboard();
    
    if (cachedLabour != null || cachedMaterial != null) {
      setState(() {
        if (cachedLabour != null) _labourEntries = cachedLabour;
        if (cachedMaterial != null) _materialEntries = cachedMaterial;
        if (cachedDashboard != null) _dashboardData = cachedDashboard;
        _isLoading = false;
      });
    }
    
    // Refresh in background (silent)
    _refreshAllDataInBackground();
  }
  
  void _startBackgroundRefresh() {
    _labourRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _refreshLabourInBackground(),
    );
    
    _materialRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _refreshMaterialInBackground(),
    );
    
    _dashboardRefreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) => _refreshDashboardInBackground(),
    );
  }
  
  Future<void> _refreshAllDataInBackground() async {
    await Future.wait([
      _refreshLabourInBackground(),
      _refreshMaterialInBackground(),
      _refreshDashboardInBackground(),
    ]);
  }
  
  Future<void> _refreshLabourInBackground() async {
    try {
      final provider = context.read<ConstructionProvider>();
      await provider.loadAccountantLabourEntries(forceRefresh: true);
      
      final newData = provider.accountantLabourEntries;
      await CacheService.saveAccountantLabour(newData);
      
      if (mounted) {
        setState(() => _labourEntries = newData);
      }
    } catch (e) {
      // Silent failure
    }
  }
  
  Future<void> _refreshMaterialInBackground() async {
    try {
      final provider = context.read<ConstructionProvider>();
      await provider.loadAccountantMaterialEntries(forceRefresh: true);
      
      final newData = provider.accountantMaterialEntries;
      await CacheService.saveAccountantMaterial(newData);
      
      if (mounted) {
        setState(() => _materialEntries = newData);
      }
    } catch (e) {
      // Silent failure
    }
  }
  
  Future<void> _refreshDashboardInBackground() async {
    try {
      // Load dashboard stats from API
      final stats = await _loadDashboardStatsFromAPI();
      await CacheService.saveAccountantDashboard(stats);
      
      if (mounted) {
        setState(() => _dashboardData = stats);
      }
    } catch (e) {
      // Silent failure
    }
  }
}
```

## Testing

### Test Instant Load
```bash
1. Open app
2. Navigate to Accountant dashboard
3. Close app completely
4. Reopen app
5. Navigate to Accountant dashboard
6. ✅ Should load INSTANTLY (0ms) with cached data
7. ✅ Should update quietly in background
```

### Test Background Refresh
```bash
1. Open app to Accountant dashboard
2. Wait 60 seconds
3. ✅ Data should update automatically (silent)
4. No loading spinners should appear
```

### Test Cache Expiry
```bash
1. Open app
2. Wait 24+ hours
3. Reopen app
4. ✅ Should load fresh data (cache expired)
```

## Benefits

1. **Instant App Opens** - 0ms load time from cache
2. **Always Fresh Data** - Background refresh every 60-90s
3. **Offline Support** - Show cached data when offline
4. **Better UX** - No loading spinners after first load
5. **Reduced Server Load** - Fewer API calls
6. **Battery Efficient** - Smart refresh intervals

## Summary

✅ Cache service methods added
⏳ Accountant dashboard needs implementation
⏳ Accountant entry screen needs implementation
⏳ Accountant reports screen needs implementation

Follow the implementation steps above to complete the feature!
