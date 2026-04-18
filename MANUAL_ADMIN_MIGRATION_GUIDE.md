# Manual Admin Screens Migration Guide

**Date:** April 15, 2026  
**Purpose:** Step-by-step guide to migrate admin screens to use AdminProvider

---

## ✅ Already Migrated

1. **admin_sites_test_screen.dart** - Completed and tested

---

## 📋 Screens to Migrate (13 remaining)

1. admin_bills_view_screen.dart (329 lines)
2. admin_budget_management_screen.dart (688 lines)
3. admin_client_complaints_screen.dart (599 lines)
4. admin_dashboard.dart (2815 lines) - Complex, do last
5. admin_labour_count_screen.dart (261 lines)
6. admin_labour_count_screen_improved.dart (210 lines)
7. admin_labour_rates_screen.dart (412 lines)
8. admin_material_purchases_screen.dart (304 lines)
9. admin_profit_loss_improved.dart (472 lines)
10. admin_profit_loss_screen.dart (479 lines)
11. admin_site_comparison_screen.dart (371 lines)
12. admin_site_documents_screen.dart (354 lines)
13. admin_site_full_view.dart (2082 lines) - Complex, do last

**Skip:** admin_specialized_login_screen.dart (login screen doesn't need provider)

---

## 🎯 Migration Pattern

### Step 1: Create Backup

```bash
cp lib/screens/admin_bills_view_screen.dart lib/screens/admin_bills_view_screen.dart.backup_manual
```

### Step 2: Add Imports (if not present)

```dart
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
```

### Step 3: Update initState

**Before:**
```dart
@override
void initState() {
  super.initState();
  _loadSites();
}
```

**After:**
```dart
@override
void initState() {
  super.initState();
  // Load sites using provider
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AdminProvider>().loadSites();
  });
}
```

### Step 4: Wrap build Method with Consumer

**Before:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Admin Screen')),
    body: _buildBody(),
  );
}
```

**After:**
```dart
@override
Widget build(BuildContext context) {
  return Consumer<AdminProvider>(
    builder: (context, adminProvider, child) {
      return Scaffold(
        appBar: AppBar(title: Text('Admin Screen')),
        body: _buildBody(adminProvider),
      );
    },
  );
}
```

### Step 5: Update Method Signatures

Add `AdminProvider` parameter to methods that need provider data:

**Before:**
```dart
Widget _buildBody() {
  if (_isLoading) {
    return CircularProgressIndicator();
  }
  return ListView.builder(
    itemCount: _sites.length,
    itemBuilder: (context, index) {
      final site = _sites[index];
      return ListTile(title: Text(site['name']));
    },
  );
}
```

**After:**
```dart
Widget _buildBody(AdminProvider adminProvider) {
  if (adminProvider.isLoadingSites) {
    return CircularProgressIndicator();
  }
  return ListView.builder(
    itemCount: adminProvider.sites.length,
    itemBuilder: (context, index) {
      final site = adminProvider.sites[index];
      return ListTile(title: Text(site['name']));
    },
  );
}
```

### Step 6: Replace State Variables

| Old Variable | New Provider Property |
|--------------|----------------------|
| `_sites` | `adminProvider.sites` |
| `_isLoading` | `adminProvider.isLoadingSites` |
| `_sitesLoading` | `adminProvider.isLoadingSites` |
| `_loadSites()` | `adminProvider.loadSites(forceRefresh: true)` |

### Step 7: Remove Old Code

Comment out or remove:
- Local state variables (`List<Map<String, dynamic>> _sites = [];`)
- Manual API calls in `initState()`
- `setState()` calls for loading states
- Manual `_loadSites()` methods

### Step 8: Update Refresh Actions

**Before:**
```dart
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: _loadSites,
)
```

**After:**
```dart
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: () => adminProvider.loadSites(forceRefresh: true),
)
```

### Step 9: Add Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () => adminProvider.loadSites(forceRefresh: true),
  child: ListView.builder(...),
)
```

### Step 10: Test

1. Run the app
2. Navigate to the migrated screen
3. Verify data loads
4. Test refresh button
5. Test pull-to-refresh
6. Check for errors in console

---

## 📚 AdminProvider Methods Available

### Sites
```dart
// Load all sites
await adminProvider.loadSites(forceRefresh: true);

// Access sites
adminProvider.sites  // List<Map<String, dynamic>>
adminProvider.isLoadingSites  // bool
adminProvider.sitesLoaded  // bool
```

### Labour Data
```dart
// Load labour data for a site
final labourData = await adminProvider.getLabourData(siteId, forceRefresh: true);

// Check loading state
adminProvider.isLoading('labour_$siteId')
```

### Bills Data
```dart
// Load bills for a site
final bills = await adminProvider.getBillsData(siteId, forceRefresh: true);

// Check loading state
adminProvider.isLoading('bills_$siteId')
```

### Profit/Loss Data
```dart
// Load P/L data for a site
final plData = await adminProvider.getProfitLossData(siteId, forceRefresh: true);

// Check loading state
adminProvider.isLoading('pl_$siteId')
```

### Material Purchases
```dart
// Load material purchases for a site
final materials = await adminProvider.getMaterialPurchases(siteId, forceRefresh: true);

// Check loading state
adminProvider.isLoading('materials_$siteId')
```

### Documents
```dart
// Load documents for a site
final docs = await adminProvider.getDocuments(siteId, forceRefresh: true);
// Returns: { 'PLAN': [], 'ELEVATION': [], 'STRUCTURE': [], 'FINAL_OUTPUT': [] }

// Check loading state
adminProvider.isLoading('docs_$siteId')
```

### Site Comparison
```dart
// Compare two sites
final comparison = await adminProvider.compareSites(site1Id, site2Id);

// Check loading state
adminProvider.isLoading('comparison')
```

### Cache Management
```dart
// Clear cache for a specific site
adminProvider.clearSiteCache(siteId);

// Clear all cache
adminProvider.clearAllCache();
```

---

## 🔍 Example: Complete Migration

### Before (admin_bills_view_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class AdminBillsViewScreen extends StatefulWidget {
  const AdminBillsViewScreen({Key? key}) : super(key: key);

  @override
  State<AdminBillsViewScreen> createState() => _AdminBillsViewScreenState();
}

class _AdminBillsViewScreenState extends State<AdminBillsViewScreen> {
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = false;
  String? _selectedSiteId;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/'),
        headers: {'Authorization': 'Bearer ${await AuthService().getToken()}'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sites = List<Map<String, dynamic>>.from(data['sites']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBills(String siteId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/bills/'),
        headers: {'Authorization': 'Bearer ${await AuthService().getToken()}'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bills = List<Map<String, dynamic>>.from(data['bills']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bills View'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _selectedSiteId != null ? () => _loadBills(_selectedSiteId!) : null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        _buildSiteSelector(),
        Expanded(child: _buildBillsList()),
      ],
    );
  }

  Widget _buildSiteSelector() {
    return DropdownButton<String>(
      value: _selectedSiteId,
      hint: Text('Select Site'),
      items: _sites.map((site) {
        return DropdownMenuItem(
          value: site['id'].toString(),
          child: Text(site['site_name']),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedSiteId = value);
          _loadBills(value);
        }
      },
    );
  }

  Widget _buildBillsList() {
    if (_bills.isEmpty) {
      return Center(child: Text('No bills found'));
    }
    
    return ListView.builder(
      itemCount: _bills.length,
      itemBuilder: (context, index) {
        final bill = _bills[index];
        return ListTile(
          title: Text(bill['description']),
          subtitle: Text('Amount: \$${bill['amount']}'),
        );
      },
    );
  }
}
```

### After (admin_bills_view_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminBillsViewScreen extends StatefulWidget {
  const AdminBillsViewScreen({Key? key}) : super(key: key);

  @override
  State<AdminBillsViewScreen> createState() => _AdminBillsViewScreenState();
}

class _AdminBillsViewScreenState extends State<AdminBillsViewScreen> {
  String? _selectedSiteId;
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    // Load sites using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  Future<void> _loadBills(AdminProvider adminProvider, String siteId) async {
    final bills = await adminProvider.getBillsData(siteId, forceRefresh: true);
    setState(() => _bills = bills);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Bills View'),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _selectedSiteId != null 
                  ? () => _loadBills(adminProvider, _selectedSiteId!) 
                  : null,
              ),
            ],
          ),
          body: _buildBody(adminProvider),
        );
      },
    );
  }

  Widget _buildBody(AdminProvider adminProvider) {
    if (adminProvider.isLoadingSites) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        _buildSiteSelector(adminProvider),
        Expanded(child: _buildBillsList(adminProvider)),
      ],
    );
  }

  Widget _buildSiteSelector(AdminProvider adminProvider) {
    return DropdownButton<String>(
      value: _selectedSiteId,
      hint: Text('Select Site'),
      items: adminProvider.sites.map((site) {
        return DropdownMenuItem(
          value: site['id'].toString(),
          child: Text(site['site_name']),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedSiteId = value);
          _loadBills(adminProvider, value);
        }
      },
    );
  }

  Widget _buildBillsList(AdminProvider adminProvider) {
    if (_selectedSiteId == null) {
      return Center(child: Text('Select a site'));
    }
    
    if (adminProvider.isLoading('bills_$_selectedSiteId')) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_bills.isEmpty) {
      return Center(child: Text('No bills found'));
    }
    
    return RefreshIndicator(
      onRefresh: () => _loadBills(adminProvider, _selectedSiteId!),
      child: ListView.builder(
        itemCount: _bills.length,
        itemBuilder: (context, index) {
          final bill = _bills[index];
          return ListTile(
            title: Text(bill['description']),
            subtitle: Text('Amount: \$${bill['amount']}'),
          );
        },
      ),
    );
  }
}
```

---

## ⚠️ Common Pitfalls

### 1. Forgetting to Update Method Signatures
```dart
// ❌ Wrong - method doesn't have provider parameter
Widget _buildBody() {
  return ListView.builder(
    itemCount: adminProvider.sites.length,  // Error: adminProvider not defined
    ...
  );
}

// ✅ Correct - method has provider parameter
Widget _buildBody(AdminProvider adminProvider) {
  return ListView.builder(
    itemCount: adminProvider.sites.length,  // Works!
    ...
  );
}
```

### 2. Not Closing Consumer Properly
```dart
// ❌ Wrong - missing closing braces
@override
Widget build(BuildContext context) {
  return Consumer<AdminProvider>(
    builder: (context, adminProvider, child) {
      return Scaffold(...);
    // Missing closing brace for Consumer
  );
}

// ✅ Correct - properly closed
@override
Widget build(BuildContext context) {
  return Consumer<AdminProvider>(
    builder: (context, adminProvider, child) {
      return Scaffold(...);
    },  // Closes builder
  );  // Closes Consumer
}
```

### 3. Using setState for Provider Data
```dart
// ❌ Wrong - don't use setState for provider data
setState(() {
  adminProvider.sites = newSites;  // Don't do this!
});

// ✅ Correct - provider handles its own state
await adminProvider.loadSites(forceRefresh: true);
// Provider will call notifyListeners() internally
```

### 4. Accessing Provider Before It's Ready
```dart
// ❌ Wrong - accessing provider in initState
@override
void initState() {
  super.initState();
  context.read<AdminProvider>().loadSites();  // Error: context not ready
}

// ✅ Correct - use addPostFrameCallback
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AdminProvider>().loadSites();  // Works!
  });
}
```

---

## 🧪 Testing Checklist

After migrating each screen:

- [ ] Screen opens without errors
- [ ] Data loads automatically on first open
- [ ] Refresh button works
- [ ] Pull-to-refresh works (if implemented)
- [ ] Loading indicators show correctly
- [ ] Empty states show correctly
- [ ] Error states show correctly (test by turning off backend)
- [ ] Navigation to/from screen works
- [ ] No console errors
- [ ] No memory leaks (check with Flutter DevTools)

---

## 📊 Migration Progress Tracker

| Screen | Lines | Status | Notes |
|--------|-------|--------|-------|
| admin_sites_test_screen.dart | 129 | ✅ Done | Template for others |
| admin_labour_count_screen_improved.dart | 210 | ⬜ Todo | Start here |
| admin_labour_count_screen.dart | 261 | ⬜ Todo | |
| admin_material_purchases_screen.dart | 304 | ⬜ Todo | |
| admin_bills_view_screen.dart | 329 | ⬜ Todo | |
| admin_site_documents_screen.dart | 354 | ⬜ Todo | |
| admin_site_comparison_screen.dart | 371 | ⬜ Todo | |
| admin_labour_rates_screen.dart | 412 | ⬜ Todo | |
| admin_profit_loss_improved.dart | 472 | ⬜ Todo | |
| admin_profit_loss_screen.dart | 479 | ⬜ Todo | |
| admin_client_complaints_screen.dart | 599 | ⬜ Todo | |
| admin_budget_management_screen.dart | 688 | ⬜ Todo | |
| admin_site_full_view.dart | 2082 | ⬜ Todo | Complex - do last |
| admin_dashboard.dart | 2815 | ⬜ Todo | Complex - do last |

---

## 🎯 Recommended Order

1. ✅ admin_sites_test_screen.dart (Done - use as reference)
2. admin_labour_count_screen_improved.dart (Simple, good practice)
3. admin_material_purchases_screen.dart (Similar pattern)
4. admin_bills_view_screen.dart (Similar pattern)
5. admin_labour_count_screen.dart (Similar to improved version)
6. admin_site_documents_screen.dart (Medium complexity)
7. admin_site_comparison_screen.dart (Medium complexity)
8. admin_labour_rates_screen.dart (Medium complexity)
9. admin_profit_loss_improved.dart (Medium complexity)
10. admin_profit_loss_screen.dart (Similar to improved version)
11. admin_client_complaints_screen.dart (More complex)
12. admin_budget_management_screen.dart (More complex)
13. admin_site_full_view.dart (Very complex - do last)
14. admin_dashboard.dart (Most complex - do last)

---

## 💡 Tips

1. **Start small** - Migrate one screen at a time
2. **Test immediately** - Don't migrate multiple screens before testing
3. **Keep backups** - Always create a backup before modifying
4. **Use the template** - Refer to admin_sites_test_screen.dart as a working example
5. **Check diagnostics** - Run `flutter analyze` after each migration
6. **Commit often** - If using git, commit after each successful migration
7. **Take breaks** - Don't try to migrate all screens in one session
8. **Ask for help** - If stuck, refer to this guide or the working example

---

**Last Updated:** April 15, 2026  
**Status:** Guide Complete  
**Next Action:** Start migrating screens one by one using this guide
