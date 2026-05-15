import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../providers/construction_provider.dart';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import '../services/cache_service.dart';
import '../services/labor_mismatch_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'accountant_reports_screen.dart';
import 'accountant_entry_screen.dart';
import 'accountant_compare_screen.dart';
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
  int _workingSitesCount = 0; // Count of sites assigned by this accountant

  // Cash entries summary (source of truth for confirmed/approved salary)
  double _cashOverallTotal = 0.0;
  List<Map<String, dynamic>> _cashBySite =
      []; // [{site_id, site_name, customer_name, total_cost, ...}]

  // Mismatch detection
  final _mismatchService = LaborMismatchService();
  Map<String, dynamic> _mismatchData = {};
  int _totalMismatches = 0;

  // Role filter state
  String? _selectedLabourRole; // null = All
  static const _labourRoles = ['Supervisor', 'Site Engineer'];

  // Date filter state
  DateTime? _selectedDate; // null = All dates

  // Site filter state
  String? _selectedSiteId; // null = All sites
  List<Map<String, dynamic>> _sites = []; // Initialize as empty list

  // Dropdown state
  final Set<String> _expandedDates = {};

  @override
  void initState() {
    super.initState();
    _profileName = widget.user.name ?? 'Accountant';
    _profilePhone = widget.user.phoneNumber;
    _loadSites();
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

    // ALWAYS show UI immediately, even with empty cache
    setState(() {
      if (cachedLabour != null) _labourEntries = cachedLabour;
      if (cachedMaterial != null) _materialEntries = cachedMaterial;
      if (cachedDashboard != null) {
        _dashboardData = cachedDashboard;
        _workingSitesCount = cachedDashboard['working_sites_count'] ?? 0;
      }
      _isLoading = false; // Show UI immediately
      _error = null;
    });

    if (cachedLabour != null || cachedMaterial != null) {
      print('🎯 [ACCOUNTANT] Using persistent cached data - instant load');
    } else {
      print('📭 [ACCOUNTANT] No cache found - showing empty state');
    }

    // Refresh from API in background (truly non-blocking)
    _refreshAllDataInBackground()
        .then((_) {
          print('✅ [ACCOUNTANT] Background refresh completed');
        })
        .catchError((e) {
          print('⚠️ [ACCOUNTANT] Background refresh failed: $e');
        });
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
    try {
      final provider = context.read<ConstructionProvider>();

      // Call API only ONCE
      await provider.loadAccountantData(forceRefresh: true);

      // Get all data from provider
      final labourData = List<Map<String, dynamic>>.from(
        provider.accountantLabourEntries,
      );
      final materialData = List<Map<String, dynamic>>.from(
        provider.accountantMaterialEntries,
      );

      // Fetch working sites count
      await _fetchWorkingSitesCount();

      // Fetch confirmed cash salary summary
      await _fetchCashEntriesSummary();

      // Load mismatch data (non-blocking)
      _loadMismatchData().catchError((e) {
        print('⚠️ [ACCOUNTANT] Mismatch loading failed: $e');
      });

      // Save to cache
      await Future.wait([
        CacheService.saveAccountantLabour(labourData),
        CacheService.saveAccountantMaterial(materialData),
      ]);

      // Create and save dashboard data
      final dashboardData = {
        'total_labour_entries': labourData.length,
        'total_material_entries': materialData.length,
        'total_workers': labourData.fold<int>(
          0,
          (sum, entry) => sum + (entry['labour_count'] as int? ?? 0),
        ),
        'working_sites_count': _workingSitesCount,
        'last_updated': DateTime.now().toIso8601String(),
      };
      await CacheService.saveAccountantDashboard(dashboardData);

      // Update UI
      if (mounted) {
        setState(() {
          _labourEntries = labourData;
          _materialEntries = materialData;
          _dashboardData = dashboardData;
        });
      }

      print('✅ [ACCOUNTANT] All data refreshed in background');
    } catch (e) {
      print('⚠️ [ACCOUNTANT] Background refresh failed: $e');
    }
  }

  Future<void> _refreshLabourInBackground() async {
    // Deprecated - use _refreshAllDataInBackground instead
    await _refreshAllDataInBackground();
  }

  Future<void> _refreshMaterialInBackground() async {
    // Deprecated - use _refreshAllDataInBackground instead
    await _refreshAllDataInBackground();
  }

  Future<void> _refreshDashboardInBackground() async {
    // Deprecated - use _refreshAllDataInBackground instead
    await _refreshAllDataInBackground();
  }

  Future<void> _fetchWorkingSitesCount() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      final response = await http
          .get(
            Uri.parse(
              '${AuthService.baseUrl}/construction/accountant-working-sites-count/',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _workingSitesCount = data['working_sites_count'] ?? 0;
          });
        }
        print('📊 [WORKING SITES] Count fetched: $_workingSitesCount');
      } else {
        print(
          '⚠️ [WORKING SITES] Failed to fetch count: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('⚠️ [WORKING SITES] Error fetching count: $e');
      // Keep existing count on error
    }
  }

  Future<void> _fetchCashEntriesSummary() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      // Build query params — no role filter here; cash_entries already stores
      // only the accountant-confirmed (selected) entry per day per site.
      final queryParams = StringBuffer();
      if (_selectedDate != null) {
        final dateStr =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
        queryParams.write('?start_date=$dateStr&end_date=$dateStr');
      }

      print('🔍 [CASH SUMMARY] Fetching confirmed salary summary...');

      final response = await http
          .get(
            Uri.parse(
              '${AuthService.baseUrl}/construction/cash-entries/summary/$queryParams',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _cashOverallTotal =
                (data['overall_total'] as num?)?.toDouble() ?? 0.0;
            _cashBySite = List<Map<String, dynamic>>.from(
              data['by_site'] ?? [],
            );
          });
        }
        print(
          '✅ [CASH SUMMARY] Overall: ₹$_cashOverallTotal across ${_cashBySite.length} sites',
        );
      } else {
        print('⚠️ [CASH SUMMARY] Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ [CASH SUMMARY] Error: $e');
    }
  }

  Future<void> _loadSites() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/all-sites/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _sites = List<Map<String, dynamic>>.from(data['sites'] ?? []);
          });
        }
        print('✅ [SITES] Loaded ${_sites.length} sites');
      }
    } catch (e) {
      print('⚠️ [SITES] Error loading: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredLabourEntries {
    var filtered = _labourEntries;

    // Filter by role
    if (_selectedLabourRole != null) {
      filtered = filtered.where((entry) {
        final role = entry['submitted_by_role']?.toString() ?? '';
        return role == _selectedLabourRole;
      }).toList();
    }

    // Filter by date
    if (_selectedDate != null) {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      filtered = filtered.where((entry) {
        final entryDate = entry['entry_date']?.toString() ?? '';
        return entryDate == dateStr;
      }).toList();
    }

    // Filter by site
    if (_selectedSiteId != null) {
      filtered = filtered.where((entry) {
        final siteId = entry['site_id']?.toString() ?? '';
        return siteId == _selectedSiteId;
      }).toList();
    }

    return filtered;
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
      _labourEntries = List<Map<String, dynamic>>.from(
        provider.accountantLabourEntries,
      );
      _materialEntries = List<Map<String, dynamic>>.from(
        provider.accountantMaterialEntries,
      );

      // Fetch working sites count
      await _fetchWorkingSitesCount();

      // Fetch confirmed cash salary summary
      await _fetchCashEntriesSummary();

      // Load mismatch data
      await _loadMismatchData();

      // Save to persistent cache
      await CacheService.saveAccountantLabour(_labourEntries);
      await CacheService.saveAccountantMaterial(_materialEntries);

      // Create and save dashboard data
      final dashboardData = {
        'total_labour_entries': _labourEntries.length,
        'total_material_entries': _materialEntries.length,
        'total_workers': _labourEntries.fold<int>(
          0,
          (sum, entry) => sum + (entry['labour_count'] as int? ?? 0),
        ),
        'working_sites_count': _workingSitesCount,
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

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      // Crores (1 Cr = 10,000,000)
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      // Lakhs (1 L = 100,000)
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      // Thousands
      return '${(amount / 1000).toStringAsFixed(2)} K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  Future<void> _loadMismatchData() async {
    print('🔍 [DASHBOARD MISMATCH] Loading mismatch data for all sites');
    try {
      // Load mismatches for all sites (no site_id filter)
      final result = await _mismatchService.detectLaborMismatches(days: 7);

      print(
        '🔍 [DASHBOARD MISMATCH] API response: ${result['success']}, total: ${result['total_mismatches']}',
      );

      if (result['success'] == true) {
        setState(() {
          _mismatchData = result;
          _totalMismatches = result['total_mismatches'] ?? 0;
        });
        print(
          '✅ [DASHBOARD MISMATCH] Loaded $_totalMismatches mismatches across all sites',
        );
      } else {
        print(
          '⚠️ [DASHBOARD MISMATCH] API returned success=false: ${result['error']}',
        );
      }
    } catch (e) {
      print('❌ [DASHBOARD MISMATCH] Error loading mismatch data: $e');
    }
  }

  void _showMismatchDialog() {
    print('🔍 [DASHBOARD MISMATCH DIALOG] _showMismatchDialog called');
    print('🔍 [DASHBOARD MISMATCH DIALOG] _totalMismatches: $_totalMismatches');

    final mismatches =
        _mismatchData['mismatches'] as List<Map<String, dynamic>>? ?? [];
    final summary =
        _mismatchData['summary'] as List<Map<String, dynamic>>? ?? [];
    print(
      '🔍 [DASHBOARD MISMATCH DIALOG] mismatches count: ${mismatches.length}',
    );
    print('🔍 [DASHBOARD MISMATCH DIALOG] summary count: ${summary.length}');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.r),
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32.sp,
                  ),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text(
                      'Labor Entry Mismatches',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Found $_totalMismatches mismatches between Supervisor and Site Engineer entries across all sites',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              if (summary.isNotEmpty) ...[
                Text(
                  'Summary by Site:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: summary.length,
                    itemBuilder: (context, index) {
                      final site = summary[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                          ),
                          title: Text(
                            site['site_name'] ?? 'Unknown Site',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${site['total_mismatches']} mismatches on ${(site['dates_with_mismatches'] as List).length} days',
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${site['total_mismatches']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const Center(child: Text('No mismatches found')),
              ],
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Close', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
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
      case 2: // Compare
        currentScreen = const AccountantCompareScreen();
        break;
      case 3: // Reports
        currentScreen = const AccountantReportsScreen();
        break;
      case 4: // Profile
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
          // Mismatch Warning Icon
          if (_totalMismatches > 0)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 28.sp,
                    ),
                    tooltip: 'Labor Entry Mismatches',
                    onPressed: () {
                      print('🔍 [DASHBOARD BUTTON] Warning icon clicked!');
                      _showMismatchDialog();
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$_totalMismatches',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    // Use filtered labour entries (includes role, date, and site filters)
    final filteredLabourEntries = _filteredLabourEntries;

    // Calculate totals from FILTERED data (for labour entries display)
    final totalLabourEntries = filteredLabourEntries.length;

    // ── Confirmed salary from cash_entries (accountant-selected entries) ──
    // If a specific site is selected, show only that site's confirmed total.
    // Otherwise show the overall confirmed total.
    final double confirmedTotalSalary;
    if (_selectedSiteId != null) {
      final siteRow = _cashBySite.firstWhere(
        (s) => s['site_id'] == _selectedSiteId,
        orElse: () => {},
      );
      confirmedTotalSalary = (siteRow['total_cost'] as num?)?.toDouble() ?? 0.0;
    } else {
      confirmedTotalSalary = _cashOverallTotal;
    }

    // Working sites count comes from API (_workingSitesCount)
    final workingSitesCount = _workingSitesCount;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoleChip(
                  'All',
                  _selectedLabourRole == null,
                  () => setState(() => _selectedLabourRole = null),
                ),
                SizedBox(width: 8.w),
                ..._labourRoles.map(
                  (role) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildRoleChip(
                      role,
                      _selectedLabourRole == role,
                      () => setState(
                        () => _selectedLabourRole = _selectedLabourRole == role
                            ? null
                            : role,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Date and Site Filters
          Row(
            children: [
              // Date Filter Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _fetchCashEntriesSummary(); // refresh confirmed salary for new date
                    }
                  },
                  icon: Icon(
                    Icons.calendar_today,
                    size: 18.sp,
                    color: _selectedDate != null
                        ? AppColors.safetyOrange
                        : AppColors.textSecondary,
                  ),
                  label: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'All Dates',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _selectedDate != null
                          ? AppColors.safetyOrange
                          : AppColors.textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _selectedDate != null
                          ? AppColors.safetyOrange
                          : AppColors.lightSlate,
                    ),
                    backgroundColor: _selectedDate != null
                        ? AppColors.safetyOrange.withValues(alpha: 0.1)
                        : null,
                  ),
                ),
              ),
              if (_selectedDate != null) ...[
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: () {
                    setState(() => _selectedDate = null);
                    _fetchCashEntriesSummary(); // refresh confirmed salary (all dates)
                  },
                  icon: Icon(Icons.clear, size: 20.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
              SizedBox(width: 12.w),

              // Site Filter Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSiteId,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: _selectedSiteId != null
                            ? AppColors.safetyOrange
                            : AppColors.lightSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: _selectedSiteId != null
                            ? AppColors.safetyOrange
                            : AppColors.lightSlate,
                      ),
                    ),
                    filled: _selectedSiteId != null,
                    fillColor: _selectedSiteId != null
                        ? AppColors.safetyOrange.withValues(alpha: 0.1)
                        : null,
                  ),
                  hint: Text('All Sites', style: TextStyle(fontSize: 13.sp)),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'All Sites',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    ..._sites
                        .map(
                          (site) => DropdownMenuItem<String>(
                            value: site['id'].toString(),
                            child: Text(
                              '${site['customer_name']} - ${site['site_name']}',
                              style: TextStyle(fontSize: 13.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ],
                  onChanged: (value) => setState(() => _selectedSiteId = value),
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _selectedSiteId != null
                        ? AppColors.safetyOrange
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Summary Cards
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 16.h),

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
              SizedBox(width: 12.w),
              Expanded(
                child: SummaryCard(
                  title: 'Working Sites',
                  value: workingSitesCount.toString(),
                  icon: Icons.location_city,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Confirmed Total Salary Card (Full Width)
          // Shows only accountant-confirmed (cash entry) amounts
          SummaryCard(
            title: _selectedSiteId != null
                ? 'Confirmed Salary (This Site)'
                : 'Total Confirmed Salary',
            value: '₹${_formatCurrency(confirmedTotalSalary)}',
            icon: Icons.currency_rupee,
            color: const Color(0xFFFF9800),
          ),

          // Per-site salary breakdown (only when no specific site is selected)
          if (_selectedSiteId == null && _cashBySite.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              'Confirmed Salary By Site',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 10.h),
            ..._cashBySite.map((site) => _buildSiteSalaryRow(site)),
          ],

          SizedBox(height: 80.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSiteSalaryRow(Map<String, dynamic> site) {
    final siteName = '${site['customer_name']} - ${site['site_name']}';
    final total = (site['total_cost'] as num?)?.toDouble() ?? 0.0;
    final days = site['days_count'] as int? ?? 0;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18.sp,
            color: Color(0xFFFF9800),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siteName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$days day${days == 1 ? '' : 's'} confirmed',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '₹${_formatCurrency(total)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        // Refresh cash summary when role changes (role filter affects labour entries display only)
        _fetchCashEntriesSummary();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.deepNavy : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? AppColors.deepNavy
                : const Color(0xFF1A1A2E).withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
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
        padding: EdgeInsets.symmetric(vertical: 24.h),
        alignment: Alignment.center,
        child: Text(
          'No ${_selectedLabourRole ?? ''} labour entries found',
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
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
    final displayDates = isExpanded
        ? sortedDates
        : sortedDates.take(3).toList();

    return Column(
      children: displayDates.map((date) {
        final dateEntries = groupedEntries[date]!;
        return _buildDateDropdown(date, dateEntries, false);
      }).toList(),
    );
  }

  Widget _buildDateDropdown(
    String date,
    List<Map<String, dynamic>> entries,
    bool isLabour,
  ) {
    final dateKey = '${isLabour ? 'labour' : 'material'}_$date';
    final isExpanded = _expandedDates.contains(dateKey);
    final formattedDate = _formatDateForDropdown(date);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8.r,
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
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: isLabour
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        isLabour ? Icons.people : Icons.inventory_2,
                        color: isLabour
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF1A1A2E),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${entries.length} ${isLabour ? 'labour' : 'material'} ${entries.length == 1 ? 'entry' : 'entries'}',
                            style: TextStyle(
                              fontSize: 14.sp,
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
                        color: Color(0xFF1A1A2E),
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
            child: isExpanded
                ? Container(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        SizedBox(height: 12.h),
                        ...entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: isLabour
                                ? _buildCompactLabourCard(entry)
                                : _buildCompactMaterialCard(entry),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
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
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = days[date.weekday % 7];
    return '$dayName, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildCompactLabourCard(Map<String, dynamic> entry) {
    final fullSiteName =
        '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim();

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  fullSiteName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry['labour_count'] ?? 0} workers',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMaterialCard(Map<String, dynamic> entry) {
    final fullSiteName =
        '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim();

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  fullSiteName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry['quantity'] ?? 0} ${entry['unit'] ?? ''}',
            style: TextStyle(
              fontSize: 14.sp,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: const Color(0xFF1A1A2E),
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18.sp,
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
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF1A1A2E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A1A2E),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                SizedBox(height: 16.h),
                // Phone field
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF1A1A2E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A1A2E),
                        width: 2,
                      ),
                    ),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Phone is required';
                    if (v.trim().length != 10)
                      return 'Phone must be exactly 10 digits';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
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
                          _profileName = newName.isNotEmpty
                              ? newName
                              : _profileName;
                          _profilePhone = newPhone.isNotEmpty
                              ? newPhone
                              : _profilePhone;
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['success'] == true
                                ? 'Profile updated successfully!'
                                : result['error'] ?? 'Update failed',
                          ),
                          backgroundColor: result['success'] == true
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                        ),
                      );
                    },
              child: isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
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
      appBar: CommonWidgets.buildAppBar(context, title: 'Profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with first letter
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                          blurRadius: 10.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _profileName.isNotEmpty
                            ? _profileName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Name
                  Text(
                    _profileName,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Role
                  Text(
                    widget.user.role.displayName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Info cards
                  _buildSimpleProfileInfo(
                    'Email',
                    widget.user.email ?? 'N/A',
                    Icons.email_outlined,
                  ),
                  SizedBox(height: 12.h),
                  _buildSimpleProfileInfo(
                    'Phone',
                    _profilePhone.isNotEmpty ? _profilePhone : 'N/A',
                    Icons.phone_outlined,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

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
                  const SnackBar(
                    content: Text('Notification settings coming soon!'),
                  ),
                );
              },
            ),

            _buildProfileOption(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Change password and security settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Security settings coming soon!'),
                  ),
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
                    content: const Text(
                      'Construction Management App\nVersion 1.0.0\n\nBuilt for Essential Homes',
                    ),
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

            SizedBox(height: 24.h),

            // Logout Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 80.h), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleProfileInfo(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A1A2E), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1A1A2E),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
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
          icon: Icon(Icons.compare_arrows_outlined),
          activeIcon: Icon(Icons.compare_arrows),
          label: 'Compare',
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
