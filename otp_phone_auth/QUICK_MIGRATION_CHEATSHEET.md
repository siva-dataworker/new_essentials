# ⚡ Quick Migration Cheatsheet

**Use this as your quick reference while migrating screens!**

---

## 🎯 The 4-Step Pattern (10 minutes per screen)

### Step 1: Wrap Build with Consumer (2 min)

**BEFORE:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(...);
}
```

**AFTER:**
```dart
@override
Widget build(BuildContext context) {
  return Consumer<SupervisorProvider>(  // ← Change provider name
    builder: (context, provider, child) {
      return Scaffold(...);
    },
  );
}
```

---

### Step 2: Replace Variables (5 min)

| Find This | Replace With |
|-----------|--------------|
| `_sites` | `provider.sites` |
| `_isLoading` | `provider.isLoading` |
| `_error` | `provider.error` |
| `_areas` | `provider.areas` |
| `_streets` | `provider.streets` |
| `_materials` | `provider.materials` |
| `_entries` | `provider.entries` |
| `_documents` | `provider.documents` |
| `_complaints` | `provider.complaints` |

---

### Step 3: Add Pull-to-Refresh (1 min)

**Wrap your main content:**
```dart
RefreshIndicator(
  onRefresh: () => provider.refreshData(),
  child: YourListView(),
)
```

---

### Step 4: Remove Old Code (2 min)

**Delete or comment out:**
```dart
// DELETE THESE:
List<Map<String, dynamic>> _sites = [];
bool _isLoading = false;
String? _error;

@override
void initState() {
  super.initState();
  _loadSites();
}

Future<void> _loadSites() async {
  setState(() => _isLoading = true);
  // ...
}

setState(() {
  _isLoading = false;
});
```

---

## 📋 Provider Mapping

| Screen Type | Use This Provider |
|-------------|-------------------|
| supervisor_*.dart | `SupervisorProvider` |
| accountant_*.dart | `AccountantProvider` |
| architect_*.dart | `ArchitectProvider` |
| site_engineer_*.dart | `SiteEngineerProvider` |
| admin_*.dart | `AdminProvider` |
| client_*.dart | `ClientProvider` |
| owner_*.dart | `AdminProvider` |
| Common screens | `ConstructionProvider` |

---

## 🔍 Common Patterns

### Pattern 1: Simple List Screen

```dart
@override
Widget build(BuildContext context) {
  return Consumer<SupervisorProvider>(
    builder: (context, provider, child) {
      if (provider.isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (provider.error != null) {
        return Center(child: Text('Error: ${provider.error}'));
      }
      
      return RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: ListView.builder(
          itemCount: provider.sites.length,
          itemBuilder: (context, index) {
            final site = provider.sites[index];
            return ListTile(title: Text(site['name']));
          },
        ),
      );
    },
  );
}
```

### Pattern 2: Screen with Filters

```dart
@override
Widget build(BuildContext context) {
  return Consumer<SupervisorProvider>(
    builder: (context, provider, child) {
      return Scaffold(
        body: Column(
          children: [
            // Dropdown for area selection
            DropdownButton<String>(
              value: provider.selectedArea,
              items: provider.areas.map((area) {
                return DropdownMenuItem(value: area, child: Text(area));
              }).toList(),
              onChanged: (area) {
                if (area != null) provider.loadStreets(area);
              },
            ),
            
            // List of filtered data
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refreshData(),
                child: ListView.builder(
                  itemCount: provider.sites.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(provider.sites[index]['name']));
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

### Pattern 3: Screen with Submit Action

```dart
@override
Widget build(BuildContext context) {
  return Consumer<SupervisorProvider>(
    builder: (context, provider, child) {
      return Scaffold(
        body: Column(
          children: [
            // Your form fields
            TextField(...),
            
            // Submit button
            ElevatedButton(
              onPressed: provider.isLoading ? null : () async {
                final success = await provider.submitLabour(
                  siteId: siteId,
                  labourCount: count,
                );
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Submitted successfully!')),
                  );
                  // Data auto-refreshes after submit
                }
              },
              child: provider.isLoading
                ? CircularProgressIndicator()
                : Text('Submit'),
            ),
          ],
        ),
      );
    },
  );
}
```

---

## 🧪 Testing Checklist

After each screen:

```
[ ] Screen opens
[ ] Data loads automatically
[ ] Loading indicator shows
[ ] Pull-to-refresh works
[ ] Wait 30 seconds - auto-refresh works
[ ] Submit works (if any)
[ ] No errors in console
```

---

## 🚨 Common Mistakes

### ❌ Mistake 1: Forgetting to close Consumer
```dart
// WRONG:
return Consumer<Provider>(
  builder: (context, provider, child) {
    return Scaffold(...);
  }  // ← Missing closing parenthesis
```

```dart
// CORRECT:
return Consumer<Provider>(
  builder: (context, provider, child) {
    return Scaffold(...);
  },  // ← Comma here
);  // ← Closing parenthesis
```

### ❌ Mistake 2: Using wrong provider
```dart
// WRONG: Using SupervisorProvider in accountant screen
Consumer<SupervisorProvider>(...)

// CORRECT:
Consumer<AccountantProvider>(...)
```

### ❌ Mistake 3: Forgetting to replace all variables
```dart
// WRONG: Mixed old and new
return Text('${provider.sites.length} sites, loading: $_isLoading');

// CORRECT: All from provider
return Text('${provider.sites.length} sites, loading: ${provider.isLoading}');
```

### ❌ Mistake 4: Keeping old initState
```dart
// WRONG: Still loading data manually
@override
void initState() {
  super.initState();
  _loadSites();  // ← Remove this!
}

// CORRECT: No manual loading
// (Provider handles it automatically)
```

---

## 💡 Pro Tips

### Tip 1: Use Find & Replace
1. Press `Ctrl+H` (or `Cmd+H` on Mac)
2. Find: `_sites`
3. Replace: `provider.sites`
4. Review each match before replacing

### Tip 2: Keep Backups
All original files are backed up with `.backup` extension. If something goes wrong:
```bash
# Restore from backup
cp supervisor_dashboard_feed.dart.backup supervisor_dashboard_feed.dart
```

### Tip 3: Test Incrementally
Don't migrate 10 screens then test. Migrate 1, test, then move to next.

### Tip 4: Copy the Pattern
After your first screen works, copy the Consumer pattern from it to other screens.

### Tip 5: Use the TODO Comments
The script added TODO comments in each file - follow them!

---

## 📊 Provider Data Reference

### SupervisorProvider
```dart
provider.areas          // List<String>
provider.streets        // List<String>
provider.sites          // List<Map<String, dynamic>>
provider.materials      // List<Map<String, dynamic>>
provider.todayEntries   // Map<String, dynamic>?
provider.historyData    // Map<String, dynamic>
provider.isLoading      // bool
provider.error          // String?

// Methods:
provider.loadAreas()
provider.loadStreets(area)
provider.loadSites(area: area, street: street)
provider.loadMaterials()
provider.submitLabour(...)
provider.submitMaterialBalance(...)
provider.refreshData()
```

### AccountantProvider
```dart
provider.entries        // Map<String, List<Map<String, dynamic>>>
provider.bills          // List<Map<String, dynamic>>
provider.agreements     // List<Map<String, dynamic>>
provider.reports        // Map<String, dynamic>
provider.isLoading      // bool
provider.error          // String?

// Methods:
provider.loadEntries()
provider.loadBills()
provider.loadAgreements()
provider.submitEntry(...)
provider.uploadBill(...)
provider.refreshData()
```

### ArchitectProvider
```dart
provider.documents      // List<Map<String, dynamic>>
provider.complaints     // List<Map<String, dynamic>>
provider.estimations    // List<Map<String, dynamic>>
provider.isLoading      // bool
provider.error          // String?

// Methods:
provider.loadDocuments()
provider.loadComplaints()
provider.loadEstimations()
provider.submitDocument(...)
provider.refreshData()
```

### SiteEngineerProvider
```dart
provider.sites          // List<Map<String, dynamic>>
provider.workUpdates    // List<Map<String, dynamic>>
provider.photos         // List<Map<String, dynamic>>
provider.isLoading      // bool
provider.error          // String?

// Methods:
provider.loadSites()
provider.loadWorkUpdates()
provider.submitWorkUpdate(...)
provider.uploadPhoto(...)
provider.refreshData()
```

### AdminProvider
```dart
provider.sites          // List<Map<String, dynamic>>
provider.budget         // Map<String, dynamic>
provider.profitLoss     // Map<String, dynamic>
provider.isLoading      // bool
provider.error          // String?

// Methods:
provider.loadSites()
provider.loadBudget()
provider.loadProfitLoss()
provider.updateBudget(...)
provider.refreshData()
```

### ClientProvider
```dart
provider.sites          // List<Map<String, dynamic>>
provider.progress       // Map<String, dynamic>
provider.documents      // List<Map<String, dynamic>>
provider.isLoading      // bool
provider.error          // String?

// Methods:
provider.loadSites()
provider.loadProgress()
provider.loadDocuments()
provider.refreshData()
```

---

## 🎯 Quick Start

1. **Open a screen file**
2. **Find the TODO comment** (added by script)
3. **Follow the 4-step pattern above**
4. **Test the screen**
5. **Mark it complete in MIGRATION_PROGRESS.md**
6. **Move to next screen**

---

## 📚 Full Documentation

- **CURRENT_STATUS_AND_NEXT_STEPS.md** - Complete status and detailed guide
- **MIGRATION_PROGRESS.md** - Track your progress
- **QUICK_START_GUIDE.md** - Detailed templates
- **HOW_TO_USE_AUTO_REFRESH.md** - Auto-refresh examples

---

## 🆘 Need Help?

1. Check the TODO comment in the screen file
2. Look at this cheatsheet
3. Review QUICK_START_GUIDE.md
4. Compare with a working example screen
5. Check the provider file to see available data

---

**Print this out or keep it open while migrating screens!** 📄

**Last Updated:** April 15, 2026
