# State Management & Auto-Loading Implementation Guide

## Overview
This guide shows how to implement Provider-based state management with automatic data loading and refresh in all screens.

## Features Implemented
✅ **Auto-refresh every 30 seconds** - Data updates automatically without user action
✅ **Pull-to-refresh** - Users can manually refresh by pulling down
✅ **Loading states** - Shows loading indicators during data fetch
✅ **Error handling** - Displays errors with retry option
✅ **Caching** - Reduces unnecessary API calls
✅ **Real-time updates** - Changes reflect immediately across the app

## Providers Created

### 1. SupervisorProvider
**Location:** `lib/providers/supervisor_provider.dart`

**Features:**
- Auto-refresh every 30 seconds
- Manages areas, streets, sites, materials
- Handles labour and material submissions
- Loads today's entries and history
- Automatic data refresh after submissions

**Usage in Screen:**
```dart
// Initialize in initState
@override
void initState() {
  super.initState();
  final provider = context.read<SupervisorProvider>();
  provider.initialize(enableAutoRefresh: true);
}

// Use in build method
@override
Widget build(BuildContext context) {
  return Consumer<SupervisorProvider>(
    builder: (context, provider, child) {
      if (provider.isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      
      return RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: ListView(
          children: provider.sites.map((site) => 
            ListTile(title: Text(site['site_name']))
          ).toList(),
        ),
      );
    },
  );
}
```

### 2. AccountantProvider
**Location:** `lib/providers/accountant_provider.dart`

**Features:**
- Auto-refresh entries and photos
- Manages bills and agreements
- Filters by site, date range
- Upload bill functionality
- Automatic refresh after uploads

**Usage:**
```dart
Consumer<AccountantProvider>(
  builder: (context, provider, child) {
    final labourEntries = provider.entries['labour_entries'] ?? [];
    final materialEntries = provider.entries['material_entries'] ?? [];
    
    return Column(
      children: [
        Text('Labour: ${labourEntries.length}'),
        Text('Material: ${materialEntries.length}'),
        ElevatedButton(
          onPressed: () => provider.refreshData(),
          child: Text('Refresh'),
        ),
      ],
    );
  },
)
```

### 3. ArchitectProvider
**Location:** `lib/providers/architect_provider.dart`

**Features:**
- Auto-refresh documents and complaints
- Photo management
- Document upload with auto-refresh
- Complaint submission with auto-refresh

**Usage:**
```dart
Consumer<ArchitectProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.documents.length,
      itemBuilder: (context, index) {
        final doc = provider.documents[index];
        return ListTile(
          title: Text(doc['title']),
          subtitle: Text(doc['document_type']),
        );
      },
    );
  },
)
```

## Implementation Pattern for All Screens

### Step 1: Import Provider
```dart
import 'package:provider/provider.dart';
import '../providers/supervisor_provider.dart'; // or appropriate provider
```

### Step 2: Initialize in initState
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = context.read<SupervisorProvider>();
    provider.initialize(enableAutoRefresh: true);
  });
}
```

### Step 3: Use Consumer in build
```dart
@override
Widget build(BuildContext context) {
  return Consumer<SupervisorProvider>(
    builder: (context, provider, child) {
      // Access provider data
      final sites = provider.sites;
      final isLoading = provider.isLoading;
      final error = provider.error;
      
      // Build UI based on state
      if (error != null) {
        return ErrorWidget(error: error);
      }
      
      if (isLoading && sites.isEmpty) {
        return LoadingWidget();
      }
      
      return RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: YourContent(),
      );
    },
  );
}
```

### Step 4: Add Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await provider.refreshData();
  },
  child: ListView(...),
)
```

### Step 5: Handle Submissions
```dart
Future<void> _submitData() async {
  final provider = context.read<SupervisorProvider>();
  
  final success = await provider.submitLabour(
    siteId: siteId,
    labourCount: count,
  );
  
  if (success) {
    // Data automatically refreshed by provider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitted successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${provider.error}')),
    );
  }
}
```

## Screens to Update

### Priority 1 (Core Screens)
1. ✅ **supervisor_dashboard_feed.dart** - Example created
2. **accountant_dashboard.dart** - Use AccountantProvider
3. **architect_dashboard.dart** - Use ArchitectProvider
4. **site_engineer_dashboard.dart** - Use SiteEngineerProvider
5. **admin_dashboard.dart** - Use AdminProvider

### Priority 2 (Detail Screens)
6. **site_detail_screen.dart** - Use SupervisorProvider
7. **supervisor_history_screen.dart** - Use SupervisorProvider
8. **accountant_entry_screen.dart** - Use AccountantProvider
9. **admin_site_full_view.dart** - Use AdminProvider

### Priority 3 (Secondary Screens)
10. All other role-specific screens

## Auto-Refresh Configuration

### Default Settings
- **Interval:** 30 seconds
- **Enabled by default:** Yes
- **Stops when:** Screen disposed

### Customize Refresh Interval
```dart
provider.startAutoRefresh(
  interval: Duration(seconds: 15), // Refresh every 15 seconds
);
```

### Disable Auto-Refresh
```dart
provider.initialize(enableAutoRefresh: false);
```

### Manual Refresh
```dart
// Refresh button
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: () => provider.refreshData(),
)
```

## Error Handling Pattern

```dart
if (provider.error != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        SizedBox(height: 16),
        Text('Error: ${provider.error}'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            provider.clearError();
            provider.refreshData();
          },
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

## Loading State Pattern

```dart
if (provider.isLoading && provider.sites.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Loading data...'),
      ],
    ),
  );
}
```

## Benefits

1. **No Manual Refresh Needed** - Data updates automatically
2. **Consistent State** - All widgets using same provider see same data
3. **Reduced API Calls** - Smart caching and refresh logic
4. **Better UX** - Loading states and error handling
5. **Real-time Feel** - 30-second refresh makes app feel live
6. **Easy Maintenance** - Business logic in providers, not screens

## Testing Auto-Refresh

1. Open supervisor dashboard
2. Submit labour entry
3. Wait 30 seconds - data refreshes automatically
4. Pull down to manually refresh
5. Check console for refresh logs

## Next Steps

1. Update remaining screens to use providers
2. Test auto-refresh on all screens
3. Adjust refresh intervals based on user feedback
4. Add offline support if needed
5. Implement push notifications for critical updates

## Example: Complete Screen Implementation

See `supervisor_dashboard_with_provider.dart` for a complete working example with:
- Provider initialization
- Auto-refresh
- Pull-to-refresh
- Error handling
- Loading states
- Data submission with auto-refresh
