# Provider Quick Reference Guide

## 🚀 Quick Start

### Import Provider
```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/construction_provider.dart';
import '../providers/change_request_provider.dart';
```

## 📖 Common Patterns

### 1. Read Data (Auto-Rebuild)
```dart
// Option A: Consumer (recommended for complex widgets)
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text('User: ${authProvider.username}');
  },
)

// Option B: context.watch (recommended for simple values)
final username = context.watch<AuthProvider>().username;
```

### 2. Call Methods (No Rebuild)
```dart
// Option A: context.read (recommended)
await context.read<AuthProvider>().login(username, password);

// Option B: Provider.of with listen: false
final provider = Provider.of<AuthProvider>(context, listen: false);
await provider.login(username, password);
```

### 3. Load Data on Screen Open
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ConstructionProvider>().loadSupervisorHistory();
  });
}
```

### 4. Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () => context.read<ConstructionProvider>().loadSupervisorHistory(),
  child: ListView(...),
)
```

### 5. Show Loading Indicator
```dart
Consumer<ConstructionProvider>(
  builder: (context, provider, child) {
    if (provider.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    return YourWidget();
  },
)
```

### 6. Handle Errors
```dart
Consumer<AuthProvider>(
  builder: (context, provider, child) {
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    return YourWidget();
  },
)
```

## 🎯 Provider Cheat Sheet

### AuthProvider
```dart
// Login
final success = await context.read<AuthProvider>().login(username, password);

// Logout
await context.read<AuthProvider>().logout();

// Get current user
final user = context.watch<AuthProvider>().currentUser;

// Check if authenticated
final isAuth = context.watch<AuthProvider>().isAuthenticated;

// Get user details
final username = context.watch<AuthProvider>().username;
final role = context.watch<AuthProvider>().role;
final email = context.watch<AuthProvider>().email;

// Check loading
final isLoading = context.watch<AuthProvider>().isLoading;

// Get error
final error = context.watch<AuthProvider>().error;
```

### ConstructionProvider
```dart
// Load supervisor history
await context.read<ConstructionProvider>().loadSupervisorHistory();

// Load accountant data
await context.read<ConstructionProvider>().loadAccountantData();

// Submit labour count
final result = await context.read<ConstructionProvider>().submitLabourCount(
  siteId: siteId,
  labourCount: count,
  labourType: type,
  notes: notes,
);

// Submit material balance
final result = await context.read<ConstructionProvider>().submitMaterialBalance(
  siteId: siteId,
  materials: materials,
);

// Load areas
await context.read<ConstructionProvider>().loadAreas();

// Load streets
await context.read<ConstructionProvider>().loadStreetsForArea(area);

// Load sites
await context.read<ConstructionProvider>().loadSites(area: area, street: street);

// Get data
final labourEntries = context.watch<ConstructionProvider>().labourEntries;
final materialEntries = context.watch<ConstructionProvider>().materialEntries;
final sites = context.watch<ConstructionProvider>().sites;
final areas = context.watch<ConstructionProvider>().areas;

// Get loading states
final isLoadingHistory = context.watch<ConstructionProvider>().isLoadingHistory;
final isSubmitting = context.watch<ConstructionProvider>().isSubmitting;
```

### ChangeRequestProvider
```dart
// Load my change requests (supervisor)
await context.read<ChangeRequestProvider>().loadMyChangeRequests();

// Load pending requests (accountant)
await context.read<ChangeRequestProvider>().loadPendingChangeRequests();

// Load modified entries (supervisor)
await context.read<ChangeRequestProvider>().loadModifiedEntries();

// Request change (supervisor)
final result = await context.read<ChangeRequestProvider>().requestChange(
  entryId: entryId,
  entryType: 'labour',
  requestMessage: message,
);

// Handle change request (accountant)
final result = await context.read<ChangeRequestProvider>().handleChangeRequest(
  requestId: requestId,
  newValue: newValue,
  responseMessage: message,
);

// Get data
final myRequests = context.watch<ChangeRequestProvider>().myChangeRequests;
final pendingRequests = context.watch<ChangeRequestProvider>().pendingChangeRequests;
final modifiedLabour = context.watch<ChangeRequestProvider>().modifiedLabourEntries;
final modifiedMaterial = context.watch<ChangeRequestProvider>().modifiedMaterialEntries;

// Get pending count
final pendingCount = context.watch<ChangeRequestProvider>().pendingCount;

// Get loading states
final isLoading = context.watch<ChangeRequestProvider>().isLoadingRequests;
final isSubmitting = context.watch<ChangeRequestProvider>().isSubmitting;
```

## ⚡ Performance Tips

### DO ✅
```dart
// Use context.read for actions (no rebuild)
onPressed: () => context.read<AuthProvider>().logout()

// Use Consumer for specific widgets
Consumer<AuthProvider>(
  builder: (context, provider, child) => Text(provider.username),
)

// Use child parameter for static widgets
Consumer<AuthProvider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        Text(provider.username),
        child!, // This doesn't rebuild
      ],
    );
  },
  child: const StaticWidget(),
)
```

### DON'T ❌
```dart
// Don't use context.watch in callbacks
onPressed: () {
  final provider = context.watch<AuthProvider>(); // ❌ Wrong!
  provider.logout();
}

// Don't wrap entire screen in Consumer if only small part needs it
Consumer<AuthProvider>( // ❌ Too broad!
  builder: (context, provider, child) {
    return Scaffold(
      appBar: AppBar(title: Text(provider.username)), // Only this needs it
      body: LargeComplexWidget(), // This doesn't need it
    );
  },
)
```

## 🔧 Common Issues & Solutions

### Issue: "Bad state: Cannot use context.read after dispose"
**Solution:** Check if widget is mounted before using context
```dart
if (!mounted) return;
await context.read<AuthProvider>().login(...);
```

### Issue: Widget not rebuilding when data changes
**Solution:** Use `context.watch` or `Consumer` instead of `context.read`
```dart
// Wrong
final username = context.read<AuthProvider>().username; // ❌

// Right
final username = context.watch<AuthProvider>().username; // ✅
```

### Issue: Too many rebuilds / performance issues
**Solution:** Use `context.read` for actions, narrow Consumer scope
```dart
// Wrong - rebuilds on every provider change
final provider = context.watch<AuthProvider>();
ElevatedButton(
  onPressed: () => provider.logout(),
  child: Text(provider.username),
)

// Right - only rebuilds when username changes
ElevatedButton(
  onPressed: () => context.read<AuthProvider>().logout(),
  child: Consumer<AuthProvider>(
    builder: (context, provider, child) => Text(provider.username),
  ),
)
```

### Issue: "Provider not found"
**Solution:** Make sure MultiProvider is above the widget in tree
```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    // ... other providers
  ],
  child: MaterialApp(...),
)
```

## 📝 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/construction_provider.dart';

class SupervisorHistoryScreen extends StatefulWidget {
  const SupervisorHistoryScreen({super.key});

  @override
  State<SupervisorHistoryScreen> createState() => _SupervisorHistoryScreenState();
}

class _SupervisorHistoryScreenState extends State<SupervisorHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConstructionProvider>().loadSupervisorHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<ConstructionProvider>(
        builder: (context, provider, child) {
          // Show loading
          if (provider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          // Show empty state
          if (provider.labourEntries.isEmpty) {
            return const Center(child: Text('No entries yet'));
          }

          // Show data with pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => provider.loadSupervisorHistory(),
            child: ListView.builder(
              itemCount: provider.labourEntries.length,
              itemBuilder: (context, index) {
                final entry = provider.labourEntries[index];
                return ListTile(
                  title: Text(entry['labour_type']),
                  subtitle: Text('Count: ${entry['labour_count']}'),
                  trailing: Text(entry['entry_date']),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

## 🎓 Learning Resources

- **Provider Package**: https://pub.dev/packages/provider
- **Flutter State Management**: https://docs.flutter.dev/data-and-backend/state-mgmt
- **Provider Documentation**: https://pub.dev/documentation/provider/latest/

## 💡 Pro Tips

1. **Use `context.read` for actions** - No unnecessary rebuilds
2. **Use `context.watch` or `Consumer` for data** - Automatic rebuilds
3. **Keep Consumer scope narrow** - Better performance
4. **Load data in initState** - Use `addPostFrameCallback`
5. **Check mounted before using context** - Avoid errors after async
6. **Use child parameter in Consumer** - Optimize static widgets
7. **Clear data on logout** - Call `provider.clearData()`

---

**Quick Reference Version 1.0** - State Management with Provider
