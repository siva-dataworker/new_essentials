# Simple Provider Usage - No Complex Setup Needed!

## ✅ Providers Auto-Initialize on App Start

All providers are configured to initialize automatically when the app starts. You don't need to call `initialize()` in every screen!

## 🎯 Simple Usage Pattern

### For ANY Screen - Just Use Consumer!

```dart
import 'package:provider/provider.dart';
import '../providers/supervisor_provider.dart'; // or any provider

class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SupervisorProvider>(
      builder: (context, provider, child) {
        // That's it! Data is already loading and auto-refreshing!
        
        if (provider.isLoading && provider.sites.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          itemCount: provider.sites.length,
          itemBuilder: (context, index) {
            final site = provider.sites[index];
            return ListTile(
              title: Text(site['site_name']),
            );
          },
        );
      },
    );
  }
}
```

## 📋 That's All You Need!

### No Need For:
- ❌ `initState()` setup
- ❌ Manual `initialize()` calls
- ❌ Timer management
- ❌ Manual refresh logic
- ❌ setState() calls

### You Get Automatically:
- ✅ Data loads on first access
- ✅ Auto-refresh every 30 seconds
- ✅ Loading states
- ✅ Error handling
- ✅ Pull-to-refresh support

## 🔄 Add Pull-to-Refresh (Optional)

```dart
Consumer<SupervisorProvider>(
  builder: (context, provider, child) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: ListView(...),
    );
  },
)
```

## 📝 Submit Data Example

```dart
// In your button onPressed
ElevatedButton(
  onPressed: () async {
    final provider = context.read<SupervisorProvider>();
    
    final success = await provider.submitLabour(
      siteId: siteId,
      labourCount: count,
    );
    
    if (success) {
      // Data automatically refreshed!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted!')),
      );
    }
  },
  child: Text('Submit'),
)
```

## 🎨 Different Providers for Different Roles

### Supervisor Screens
```dart
Consumer<SupervisorProvider>(
  builder: (context, provider, child) {
    return YourUI(
      sites: provider.sites,
      materials: provider.materials,
      todayEntries: provider.todayEntries,
    );
  },
)
```

### Accountant Screens
```dart
Consumer<AccountantProvider>(
  builder: (context, provider, child) {
    final labourEntries = provider.entries['labour_entries'] ?? [];
    final materialEntries = provider.entries['material_entries'] ?? [];
    
    return YourUI(
      labourEntries: labourEntries,
      materialEntries: materialEntries,
    );
  },
)
```

### Architect Screens
```dart
Consumer<ArchitectProvider>(
  builder: (context, provider, child) {
    return YourUI(
      documents: provider.documents,
      complaints: provider.complaints,
      photos: provider.photos,
    );
  },
)
```

### Site Engineer Screens
```dart
Consumer<SiteEngineerProvider>(
  builder: (context, provider, child) {
    return YourUI(data: provider.yourData);
  },
)
```

### Admin Screens
```dart
Consumer<AdminProvider>(
  builder: (context, provider, child) {
    return YourUI(data: provider.yourData);
  },
)
```

## 🚀 Quick Screen Update Checklist

To update any existing screen:

1. ✅ Import provider: `import '../providers/supervisor_provider.dart';`
2. ✅ Wrap your widget with `Consumer<SupervisorProvider>`
3. ✅ Remove manual API calls
4. ✅ Use `provider.data` instead of local state
5. ✅ Done! Auto-refresh is working!

## 💡 Real Example: Before & After

### ❌ Before (Manual, Complex)
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<Map<String, dynamic>> _sites = [];
  bool _isLoading = false;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _loadSites();
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      _loadSites();
    });
  }
  
  Future<void> _loadSites() async {
    setState(() => _isLoading = true);
    final sites = await _service.getSites();
    setState(() {
      _sites = sites;
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: _sites.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_sites[index]['site_name']));
      },
    );
  }
}
```

### ✅ After (Simple, Clean)
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SupervisorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.sites.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          itemCount: provider.sites.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(provider.sites[index]['site_name']),
            );
          },
        );
      },
    );
  }
}
```

## 🎯 Key Benefits

1. **Less Code** - No boilerplate, just Consumer
2. **Auto-Refresh** - Works automatically
3. **No Memory Leaks** - Providers handle cleanup
4. **Consistent Data** - Same data across all screens
5. **Easy Testing** - Simple to mock providers

## 🔧 Advanced: Stop Auto-Refresh for Specific Screen

If you need to stop auto-refresh for a specific screen:

```dart
@override
void initState() {
  super.initState();
  context.read<SupervisorProvider>().stopAutoRefresh();
}

@override
void dispose() {
  context.read<SupervisorProvider>().startAutoRefresh();
  super.dispose();
}
```

## 📱 Complete Screen Example

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supervisor_provider.dart';

class MySupervisorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sites'),
        actions: [
          // Optional: Manual refresh button
          Consumer<SupervisorProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.refresh),
                onPressed: () => provider.refreshData(),
              );
            },
          ),
        ],
      ),
      body: Consumer<SupervisorProvider>(
        builder: (context, provider, child) {
          // Error handling
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(provider.error!),
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
          
          // Loading state
          if (provider.isLoading && provider.sites.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          
          // Data display with pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: ListView.builder(
              itemCount: provider.sites.length,
              itemBuilder: (context, index) {
                final site = provider.sites[index];
                return Card(
                  child: ListTile(
                    title: Text(site['site_name'] ?? 'Unknown'),
                    subtitle: Text('${site['area']} - ${site['street']}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to detail screen
                    },
                  ),
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

## 🎉 Summary

**You only need ONE line to get auto-refreshing data:**

```dart
Consumer<SupervisorProvider>(
  builder: (context, provider, child) => YourUI(data: provider.sites),
)
```

That's it! Everything else is handled automatically! 🚀
