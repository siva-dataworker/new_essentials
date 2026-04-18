# 🎯 How to Use Auto-Refresh - ONE Simple Step!

## ✨ The ONLY Thing You Need to Do

### Wrap your widget with Consumer - Done! ✅

```dart
Consumer<SupervisorProvider>(
  builder: (context, provider, child) {
    return YourWidget(data: provider.sites);
  },
)
```

That's literally it! Everything else happens automatically! 🎉

---

## 📱 Copy-Paste Examples for Each Role

### 🔨 Supervisor Screens

```dart
import 'package:provider/provider.dart';
import '../providers/supervisor_provider.dart';

// In your build method:
Consumer<SupervisorProvider>(
  builder: (context, provider, child) {
    // Auto-refreshes every 30 seconds!
    return ListView.builder(
      itemCount: provider.sites.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(provider.sites[index]['site_name']),
        );
      },
    );
  },
)
```

### 💰 Accountant Screens

```dart
import 'package:provider/provider.dart';
import '../providers/accountant_provider.dart';

// In your build method:
Consumer<AccountantProvider>(
  builder: (context, provider, child) {
    // Auto-refreshes every 30 seconds!
    final labourEntries = provider.entries['labour_entries'] ?? [];
    
    return ListView.builder(
      itemCount: labourEntries.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(labourEntries[index]['labour_type']),
        );
      },
    );
  },
)
```

### 🏗️ Architect Screens

```dart
import 'package:provider/provider.dart';
import '../providers/architect_provider.dart';

// In your build method:
Consumer<ArchitectProvider>(
  builder: (context, provider, child) {
    // Auto-refreshes every 30 seconds!
    return ListView.builder(
      itemCount: provider.documents.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(provider.documents[index]['title']),
        );
      },
    );
  },
)
```

### 👷 Site Engineer Screens

```dart
import 'package:provider/provider.dart';
import '../providers/site_engineer_provider.dart';

// In your build method:
Consumer<SiteEngineerProvider>(
  builder: (context, provider, child) {
    // Auto-refreshes every 30 seconds!
    return YourWidget(data: provider.yourData);
  },
)
```

### 👔 Admin Screens

```dart
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

// In your build method:
Consumer<AdminProvider>(
  builder: (context, provider, child) {
    // Auto-refreshes every 30 seconds!
    return YourWidget(data: provider.yourData);
  },
)
```

---

## 🎨 Complete Screen Template

Copy this entire template and customize:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supervisor_provider.dart'; // Change to your provider

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
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
          // 1. Error handling
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
          
          // 2. Loading state (first load only)
          if (provider.isLoading && provider.sites.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // 3. Your actual UI with pull-to-refresh
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
                      // Handle tap
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

---

## 📝 Submit Data Template

Copy this for submit buttons:

```dart
ElevatedButton(
  onPressed: () async {
    // Get provider
    final provider = context.read<SupervisorProvider>();
    
    // Submit data
    final success = await provider.submitLabour(
      siteId: siteId,
      labourCount: count,
      labourType: type,
      notes: notes,
    );
    
    // Show result
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Data automatically refreshed!
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: Text('Submit'),
)
```

---

## 🔄 What You Get Automatically

When you use `Consumer`:

| Feature | Status | Description |
|---------|--------|-------------|
| **Auto-Load** | ✅ | Data loads when screen opens |
| **Auto-Refresh** | ✅ | Updates every 30 seconds |
| **Loading State** | ✅ | `provider.isLoading` |
| **Error Handling** | ✅ | `provider.error` |
| **Pull-to-Refresh** | ✅ | Just add `RefreshIndicator` |
| **After Submit** | ✅ | Auto-refreshes after actions |
| **Memory Safe** | ✅ | No leaks, auto cleanup |
| **Consistent Data** | ✅ | Same data across screens |

---

## ❌ What You DON'T Need

You don't need any of this anymore:

```dart
// ❌ NO initState needed
@override
void initState() {
  super.initState();
  _loadData(); // NOT NEEDED!
}

// ❌ NO Timer needed
Timer? _timer;
_timer = Timer.periodic(...); // NOT NEEDED!

// ❌ NO setState needed
setState(() {
  _data = newData; // NOT NEEDED!
});

// ❌ NO dispose needed
@override
void dispose() {
  _timer?.cancel(); // NOT NEEDED!
  super.dispose();
}

// ❌ NO manual API calls needed
final data = await _service.getData(); // NOT NEEDED!
```

---

## 🎯 Quick Checklist

To update any screen:

- [ ] Import provider: `import '../providers/your_provider.dart';`
- [ ] Wrap with Consumer: `Consumer<YourProvider>`
- [ ] Use provider data: `provider.sites`, `provider.isLoading`, etc.
- [ ] Remove old code: `initState`, `Timer`, `setState`, API calls
- [ ] Test: Open screen, wait 30 seconds, see auto-refresh!

---

## 🚀 That's It!

You now have:
- ✅ Automatic data loading
- ✅ Auto-refresh every 30 seconds
- ✅ Pull-to-refresh
- ✅ Loading states
- ✅ Error handling
- ✅ Real-time updates

**All with just ONE line: `Consumer<YourProvider>`!** 🎉

---

## 📚 More Help

- See `SIMPLE_PROVIDER_USAGE.md` for more examples
- See `AUTO_REFRESH_READY.md` for detailed guide
- See `supervisor_dashboard_with_provider.dart` for complete example

**Questions? Just use Consumer and you're done!** ✨
