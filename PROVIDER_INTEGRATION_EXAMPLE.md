# Provider Integration Example

## Example: Updating Login Screen to Use AuthProvider

Here's how to update the login screen to use the new AuthProvider instead of calling AuthService directly.

### Before (Current Code)
```dart
class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final result = await _authService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Navigate to dashboard
    } else {
      // Show error
    }
  }
}
```

### After (With Provider)
```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class _LoginScreenState extends State<LoginScreen> {
  // No need for AuthService or _isLoading state
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser!;
      final role = user['role'];
      
      // Navigate to appropriate dashboard based on role
      Widget dashboard;
      switch (role) {
        case 'Admin':
          dashboard = const AdminDashboard();
          break;
        case 'Supervisor':
          dashboard = const SupervisorDashboardFeed();
          break;
        // ... other cases
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to loading state
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          // ... other widgets
          
          // Login Button
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _login,
            child: authProvider.isLoading
                ? const CircularProgressIndicator()
                : const Text('Login'),
          ),
        );
      },
    );
  }
}
```

## Example: Updating Supervisor History Screen

### Before (Current Code)
```dart
class _SupervisorHistoryScreenState extends State<SupervisorHistoryScreen> {
  final _constructionService = ConstructionService();
  List<Map<String, dynamic>> _labourEntries = [];
  List<Map<String, dynamic>> _materialEntries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final result = await _constructionService.getSupervisorHistory();
    
    setState(() {
      _labourEntries = result['labour_entries'] ?? [];
      _materialEntries = result['material_entries'] ?? [];
      _isLoading = false;
    });
  }
}
```

### After (With Provider)
```dart
import 'package:provider/provider.dart';
import '../providers/construction_provider.dart';

class _SupervisorHistoryScreenState extends State<SupervisorHistoryScreen> {
  // No need for service, data lists, or loading state
  
  @override
  void initState() {
    super.initState();
    // Load data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConstructionProvider>().loadSupervisorHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadSupervisorHistory(),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Labour Entries'),
                    Tab(text: 'Material Entries'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Labour Tab
                      _buildLabourList(provider.labourEntries),
                      // Material Tab
                      _buildMaterialList(provider.materialEntries),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## Example: Submitting Labour Count

### Before (Current Code)
```dart
Future<void> _submitLabour() async {
  setState(() => _isSubmitting = true);
  
  final result = await _constructionService.submitLabourCount(
    siteId: _selectedSite,
    labourCount: _count,
    labourType: _type,
    notes: _notes,
  );
  
  setState(() => _isSubmitting = false);
  
  if (result['success']) {
    // Show success
    // Manually reload history
    _loadHistory();
  } else {
    // Show error
  }
}
```

### After (With Provider)
```dart
Future<void> _submitLabour() async {
  final provider = context.read<ConstructionProvider>();
  
  final result = await provider.submitLabourCount(
    siteId: _selectedSite,
    labourCount: _count,
    labourType: _type,
    notes: _notes,
  );
  
  if (!mounted) return;
  
  if (result['success']) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Labour count submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );
    // History is automatically reloaded by provider!
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['error'] ?? 'Failed to submit'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// In build method, use Consumer for loading state
Consumer<ConstructionProvider>(
  builder: (context, provider, child) {
    return ElevatedButton(
      onPressed: provider.isSubmitting ? null : _submitLabour,
      child: provider.isSubmitting
          ? const CircularProgressIndicator()
          : const Text('Submit'),
    );
  },
)
```

## Example: Accountant Change Requests

### Before (Current Code)
```dart
class _AccountantChangeRequestsScreenState extends State<AccountantChangeRequestsScreen> {
  final _constructionService = ConstructionService();
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    
    final result = await _constructionService.getPendingChangeRequests();
    
    setState(() {
      _pendingRequests = result['change_requests'] ?? [];
      _isLoading = false;
    });
  }

  Future<void> _handleRequest(String requestId, dynamic newValue) async {
    final result = await _constructionService.handleChangeRequest(
      requestId: requestId,
      newValue: newValue,
      responseMessage: _responseController.text,
    );
    
    if (result['success']) {
      _loadRequests(); // Reload
    }
  }
}
```

### After (With Provider)
```dart
import 'package:provider/provider.dart';
import '../providers/change_request_provider.dart';

class _AccountantChangeRequestsScreenState extends State<AccountantChangeRequestsScreen> {
  // No need for service, data, or loading state
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeRequestProvider>().loadPendingChangeRequests();
    });
  }

  Future<void> _handleRequest(String requestId, dynamic newValue) async {
    final provider = context.read<ChangeRequestProvider>();
    
    final result = await provider.handleChangeRequest(
      requestId: requestId,
      newValue: newValue,
      responseMessage: _responseController.text,
    );
    
    if (!mounted) return;
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request handled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      // Requests are automatically reloaded by provider!
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to handle request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeRequestProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingRequests) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.pendingChangeRequests.isEmpty) {
          return const Center(
            child: Text('No pending change requests'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPendingChangeRequests(),
          child: ListView.builder(
            itemCount: provider.pendingChangeRequests.length,
            itemBuilder: (context, index) {
              final request = provider.pendingChangeRequests[index];
              return _buildRequestCard(request);
            },
          ),
        );
      },
    );
  }
}
```

## Key Benefits Demonstrated

1. **Less Boilerplate**: No need to manage loading states, data lists manually
2. **Automatic UI Updates**: Consumer rebuilds when data changes
3. **Automatic Refresh**: Data reloads after mutations without manual calls
4. **Cleaner Code**: Separation of business logic (provider) and UI (widget)
5. **Better Performance**: Only widgets wrapped in Consumer rebuild
6. **Shared State**: Multiple screens can access same data without passing it around

## Migration Checklist

For each screen that needs updating:

- [ ] Remove direct service instantiation
- [ ] Remove manual state variables (loading, data lists)
- [ ] Replace `setState` with provider calls
- [ ] Wrap widgets with `Consumer` for automatic rebuilds
- [ ] Use `context.read<Provider>()` for actions (no rebuild)
- [ ] Use `context.watch<Provider>()` or `Consumer` for data (with rebuild)
- [ ] Add `if (!mounted) return;` after async operations
- [ ] Remove manual data reload calls (providers handle it)

## Testing After Migration

1. Login/logout flow works
2. Data loads on screen open
3. Data refreshes after submissions
4. Loading indicators show correctly
5. Error messages display properly
6. Pull-to-refresh works
7. Navigation doesn't break
8. No duplicate API calls
