import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../providers/construction_provider.dart';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import '../services/cache_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'accountant_reports_screen.dart';
import 'accountant_entry_screen.dart';
import 'login_screen.dart';

class AccountantDashboard extends StatefulWidget {
  final UserModel user;

  const AccountantDashboard({super.key, required this.user});

  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  int _currentBottomIndex = 1; // Start with Dashboard (center icon)

  // Local profile state (updated on edit)
  late String _profileName;
  late String _profilePhone;
  
  // Background refresh timers
  Timer? _labourRefreshTimer;
  Timer? _materialRefreshTimer;
  Timer? _dashboardRefreshTimer;
  
  // Data variables
  List<Map<String, dynamic>> _labourEntries = [];
  List<Map<String, dynamic>> _materialEntries = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _error;
  
  // Role filter state
  String? _selectedLabourRole; // null = All
  static const _labourRoles = ['Supervisor', 'Site Engineer'];

  // Dropdown state
  final Set<String> _expandedDates = {};

  @override
  void initState() {
    super.initState();
    _profileName = widget.user.name ?? 'Accountant';
    _profilePhone = widget.user.phoneNumber;
    _loadAccountantDataWithCache();
    _startBackgroundRefresh();
  }
  
  @override
  void dispose() {
    _labourRefreshTimer?.cancel();
    _materialRefreshTimer?.cancel();
    _dashboardRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAccountantDataWithCache() async {
    print('🏗️ [ACCOUNTANT] Loading data with persistent cache...');
    
    // Load from persistent cache FIRST (instant - 0ms)
    final cachedLabour = await CacheService.loadAccountantLabour();
    final cachedMaterial = await CacheService.loadAccountantMaterial();
    final cachedDashboard = await CacheService.loadAccountantDashboard();
    
    if (cachedLabour != null || cachedMaterial != null) {
      print('🎯 [ACCOUNTANT] Using persistent cached data - instant load');
      setState(() {
        if (cachedLabour != null) _labourEntries = cachedLabour;
        if (cachedMaterial != null) _materialEntries = cachedMaterial;
        if (cachedDashboard != null) _dashboardData = cachedDashboard;
        _isLoading = false;
        _error = null;
      });
    }
    
    // Refresh from API in background (silent)
    _refreshAllDataInBackground();
  }
  
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
      await provider.loadAccountantData(forceRefresh: true);
      
      final newData = List<Map<String, dynamic>>.from(provider.accountantLabourEntries);
      await CacheService.saveAccountantLabour(newData);
      
      if (mounted) {
        setState(() {
          _labourEntries = newData;
        });
      }
      print('✅ [ACCOUNTANT] Labour data refreshed in background');
    } catch (e) {
      print('⚠️ [ACCOUNTANT] Background refresh failed for labour: $e');
      // Silent failure - keep showing cached data
    }
  }
  
  Future<void> _refreshMaterialInBackground() async {
    try {
      final provider = context.read<ConstructionProvider>();
      await provider.loadAccountantData(forceRefresh: true);
      
      final newData = List<Map<String, dynamic>>.from(provider.accountantMaterialEntries);
      await CacheService.saveAccountantMaterial(newData);
      
      if (mounted) {
        setState(() {
          _materialEntries = newData;
        });
      }
      print('✅ [ACCOUNTANT] Material data refreshed in background');
    } catch (e) {
      print('⚠️ [ACCOUNTANT] Background refresh failed for material: $e');
      // Silent failure - keep showing cached data
    }
  }
  
  Future<void> _refreshDashboardInBackground() async {
    try {
      // Create dashboard summary data
      final dashboardData = {
        'total_labour_entries': _labourEntries.length,
        'total_material_entries': _materialEntries.length,
        'total_workers': _labourEntries.fold<int>(0, (sum, entry) => sum + (entry['labour_count'] as int? ?? 0)),
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      await CacheService.saveAccountantDashboard(dashboardData);
      
      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
        });
      }
      print('✅ [ACCOUNTANT] Dashboard data refreshed in background');
    } catch (e) {
      print('⚠️ [ACCOUNTANT] Background refresh failed for dashboard: $e');
      // Silent failure - keep showing cached data
    }
  }

  Future<void> _loadAccountantData() async {
    print('🔄 [ACCOUNTANT] Loading fresh data...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<ConstructionProvider>();
      
      // Use provider's caching instead of clearing it
      await provider.loadAccountantData(forceRefresh: false);
      
      // Get the data directly from provider
      _labourEntries = List<Map<String, dynamic>>.from(provider.accountantLabourEntries);
      _materialEntries = List<Map<String, dynamic>>.from(provider.accountantMaterialEntries);
      
      // Save to persistent cache
      await CacheService.saveAccountantLabour(_labourEntries);
      await CacheService.saveAccountantMaterial(_materialEntries);
      
      // Create and save dashboard data
      final dashboardData = {
        'total_labour_entries': _labourEntries.length,
        'total_material_entries': _materialEntries.length,
        'total_workers': _labourEntries.fold<int>(0, (sum, entry) => sum + (entry['labour_count'] as int? ?? 0)),
        'last_updated': DateTime.now().toIso8601String(),
      };
      await CacheService.saveAccountantDashboard(dashboardData);
      
      print('💾 [ACCOUNTANT] Data cached successfully to persistent storage');
      
    } catch (e) {
      _error = e.toString();
      print('❌ [ACCOUNTANT] Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forceRefresh() {
    print('🔄 [ACCOUNTANT] Force refresh requested');
    // Load fresh data (will update cache automatically)
    _loadAccountantData();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentBottomIndex) {
      case 0: // Entries
        currentScreen = const AccountantEntryScreen();
        break;
      case 1: // Dashboard (Center - Default)
        currentScreen = _buildDashboardScreen();
        break;
      case 2: // Reports
        currentScreen = const AccountantReportsScreen();
        break;
      case 3: // Profile
        currentScreen = _buildProfileScreen();
        break;
      default:
        currentScreen = _buildDashboardScreen();
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonWidgets.buildAppBar(
        context,
        title: 'Dashboard - $_profileName',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: const Color(0xFF1A1A2E)),
            onPressed: _forceRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _forceRefresh(),
        color: const Color(0xFF1A1A2E),
        child: _isLoading
            ? CommonWidgets.buildLoadingIndicator(
                context,
                message: 'Loading accountant data...',
              )
            : _error != null
                ? CommonWidgets.buildErrorState(
                    context,
                    message: _error!,
                    actionText: 'Retry',
                    onAction: _forceRefresh,
                  )
                : _buildDashboardContent(),
      ),
      floatingActionButton: CommonWidgets.buildFloatingActionButton(
        context,
        onPressed: _forceRefresh,
        icon: Icons.refresh,
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildDashboardContent() {
    // Calculate totals
    final totalLabourEntries = _labourEntries.length;
    final totalMaterialEntries = _materialEntries.length;
    final totalWorkers = _labourEntries.fold<int>(0, (sum, entry) => sum + (entry['labour_count'] as int? ?? 0));
    
    // Get unique sites
    final uniqueSites = <String>{};
    for (var entry in _labourEntries + _materialEntries) {
      final customer = entry['customer_name']?.toString() ?? '';
      final site = entry['site_name']?.toString() ?? '';
      if (customer.isNotEmpty && site.isNotEmpty) {
        uniqueSites.add('$customer $site');
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Labour Entries',
                  value: totalLabourEntries.toString(),
                  icon: Icons.people,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Material Entries',
                  value: totalMaterialEntries.toString(),
                  icon: Icons.inventory_2,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Workers',
                  value: totalWorkers.toString(),
                  icon: Icons.engineering,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Active Sites',
                  value: uniqueSites.length.toString(),
                  icon: Icons.location_city,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Labour Entries with Role Filter
          const Text(
            'Labour Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),

          // Role filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoleChip('All', _selectedLabourRole == null,
                    () => setState(() => _selectedLabourRole = null)),
                const SizedBox(width: 8),
                ..._labourRoles.map((role) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildRoleChip(
                        role,
                        _selectedLabourRole == role,
                        () => setState(() => _selectedLabourRole =
                            _selectedLabourRole == role ? null : role),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (_labourEntries.isEmpty)
            CommonWidgets.buildEmptyState(
              context,
              message: 'No labour entries found',
              icon: Icons.people_outline,
            )
          else
            _buildFilteredLabourEntries(),

          const SizedBox(height: 24),

          // Recent Material Entries with Dropdown
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Material Entries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              if (_materialEntries.isNotEmpty)
                TextButton.icon(
                  onPressed: _expandedDates.contains('material') ? _collapseMaterial : _expandMaterial,
                  icon: Icon(
                    _expandedDates.contains('material') ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF1A1A2E),
                  ),
                  label: Text(
                    _expandedDates.contains('material') ? 'Collapse' : 'View All',
                    style: const TextStyle(color: const Color(0xFF1A1A2E)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_materialEntries.isEmpty)
            CommonWidgets.buildEmptyState(
              context,
              message: 'No material entries found',
              icon: Icons.inventory_2_outlined,
            )
          else
            _buildMaterialEntriesWithDropdown(),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.deepNavy : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.deepNavy : const Color(0xFF1A1A2E).withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredLabourEntries() {
    // Filter by role
    final filtered = _selectedLabourRole == null
        ? _labourEntries
        : _labourEntries.where((e) {
            final role = (e['user_role'] as String? ?? '')
                .toLowerCase()
                .replaceAll('_', ' ');
            return role == _selectedLabourRole!.toLowerCase();
          }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Text(
          'No ${_selectedLabourRole ?? ''} labour entries found',
          style: const TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
        ),
      );
    }

    // Group by date
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final entry in filtered) {
      final date = entry['entry_date'] ?? 'Unknown Date';
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedDates.map((date) {
        return _buildDateDropdown(date, grouped[date]!, true);
      }).toList(),
    );
  }

  void _expandMaterial() {
    setState(() {
      _expandedDates.add('material');
    });
  }

  void _collapseMaterial() {
    setState(() {
      _expandedDates.remove('material');
    });
  }

  Widget _buildMaterialEntriesWithDropdown() {
    // Group entries by date
    final Map<String, List<Map<String, dynamic>>> groupedEntries = {};
    for (var entry in _materialEntries) {
      final date = entry['entry_date'] ?? 'Unknown Date';
      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
      groupedEntries[date]!.add(entry);
    }

    // Sort dates (most recent first)
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final isExpanded = _expandedDates.contains('material');
    final displayDates = isExpanded ? sortedDates : sortedDates.take(3).toList();

    return Column(
      children: displayDates.map((date) {
        final dateEntries = groupedEntries[date]!;
        return _buildDateDropdown(date, dateEntries, false);
      }).toList(),
    );
  }

  Widget _buildDateDropdown(String date, List<Map<String, dynamic>> entries, bool isLabour) {
    final dateKey = '${isLabour ? 'labour' : 'material'}_$date';
    final isExpanded = _expandedDates.contains(dateKey);
    final formattedDate = _formatDateForDropdown(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dropdown Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedDates.remove(dateKey);
                  } else {
                    _expandedDates.add(dateKey);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLabour 
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLabour ? Icons.people : Icons.inventory_2,
                        color: isLabour ? const Color(0xFF4CAF50) : const Color(0xFF1A1A2E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entries.length} ${isLabour ? 'labour' : 'material'} ${entries.length == 1 ? 'entry' : 'entries'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expandable Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded ? Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: isLabour 
                        ? _buildCompactLabourCard(entry)
                        : _buildCompactMaterialCard(entry),
                  )),
                ],
              ),
            ) : null,
          ),
        ],
      ),
    );
  }

  String _formatDateForDropdown(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);
      
      if (entryDate == today) {
        return 'Today • ${_formatDateWithDay(date)}';
      } else if (entryDate == yesterday) {
        return 'Yesterday • ${_formatDateWithDay(date)}';
      } else {
        return _formatDateWithDay(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateWithDay(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[date.weekday % 7];
    return '$dayName, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildCompactLabourCard(Map<String, dynamic> entry) {
    final fullSiteName = '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['labour_type'] ?? 'Unknown Type',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fullSiteName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry['labour_count'] ?? 0} workers',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMaterialCard(Map<String, dynamic> entry) {
    final fullSiteName = '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['material_type'] ?? 'Unknown Type',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fullSiteName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry['quantity'] ?? 0} ${entry['unit'] ?? ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final nameCtrl = TextEditingController(text: _profileName);
    final phoneCtrl = TextEditingController(text: _profilePhone);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: const Color(0xFF1A1A2E), size: 22),
              SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, color: const Color(0xFF1A1A2E)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: const Color(0xFF1A1A2E), width: 2),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                // Phone field
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined, color: const Color(0xFF1A1A2E)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: const Color(0xFF1A1A2E), width: 2),
                    ),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    if (v.trim().length != 10) return 'Phone must be exactly 10 digits';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);
                      final newName = nameCtrl.text.trim();
                      final newPhone = phoneCtrl.text.trim();
                      final result = await ConstructionService().updateProfile(
                        fullName: newName,
                        phone: newPhone,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (result['success'] == true) {
                        setState(() {
                          _profileName = newName.isNotEmpty ? newName : _profileName;
                          _profilePhone = newPhone.isNotEmpty ? newPhone : _profilePhone;
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['success'] == true
                              ? 'Profile updated successfully!'
                              : result['error'] ?? 'Update failed'),
                          backgroundColor: result['success'] == true
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                        ),
                      );
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonWidgets.buildAppBar(
        context,
        title: 'Profile',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with first letter
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _profileName.isNotEmpty
                            ? _profileName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    _profileName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Role
                  Text(
                    widget.user.role.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info cards
                  _buildSimpleProfileInfo('Email', widget.user.email ?? 'N/A', Icons.email_outlined),
                  const SizedBox(height: 12),
                  _buildSimpleProfileInfo('Phone', _profilePhone.isNotEmpty ? _profilePhone : 'N/A', Icons.phone_outlined),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Options
            _buildProfileOption(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your name and phone number',
              onTap: _showEditProfileDialog,
            ),
            
            _buildProfileOption(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings coming soon!')),
                );
              },
            ),
            
            _buildProfileOption(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Change password and security settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security settings coming soon!')),
                );
              },
            ),
            
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),
            
            _buildProfileOption(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About'),
                    content: const Text('Construction Management App\nVersion 1.0.0\n\nBuilt for Essential Homes'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleProfileInfo(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A2E).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1A1A2E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CommonWidgets.buildBottomNavigationBar(
      context,
      currentIndex: _currentBottomIndex,
      onTap: (index) => setState(() => _currentBottomIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Entries',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment_outlined),
          activeIcon: Icon(Icons.assessment),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
