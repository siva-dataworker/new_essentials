import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import '../providers/construction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/black_white_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'site_detail_screen.dart';
import 'supervisor_history_screen.dart';
import '../widgets/supervisor_material_usage_dialog.dart';
import 'working_sites_screen.dart';
import 'supervisor_reports_screen.dart';
import '../services/cache_service.dart';

class SupervisorDashboardFeed extends StatefulWidget {
  const SupervisorDashboardFeed({super.key});

  @override
  State<SupervisorDashboardFeed> createState() => _SupervisorDashboardFeedState();
}

class _SupervisorDashboardFeedState extends State<SupervisorDashboardFeed> {
  final _authService = AuthService();
  final _constructionService = ConstructionService();

  Map<String, dynamic>? _currentUser;
  int _selectedIndex = 0;

  // Dropdown state
  String? _selectedArea;
  String? _selectedStreet;
  String? _selectedSite;

  // Data lists
  List<String> _areas = [];
  List<String> _streets = [];
  List<Map<String, dynamic>> _sites = [];

  // Working sites
  List<Map<String, dynamic>> _workingSites = [];
  bool _isLoadingWorkingSites = false;
  bool _workingSitesExpanded = false;

  // Today's sites with data
  List<Map<String, dynamic>> _todaySitesWithData = [];
  bool _isLoadingTodaySites = false;

  // Total counts
  int _totalAreas = 0;
  int _totalStreets = 0;
  int _totalSites = 0;
  bool _isLoadingTotals = false;

  // Loading states
  bool _isLoadingAreas = false;
  bool _isLoadingStreets = false;
  bool _isLoadingSites = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAreas();
    _loadWorkingSites();
    _loadTodaySitesWithData();
    _loadTotalCounts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _loadAreas() async {
    final cached = await CacheService.loadAreas();
    if (cached != null) {
      setState(() { _areas = cached; _isLoadingAreas = false; });
      return;
    }
    setState(() => _isLoadingAreas = true);
    try {
      final provider = context.read<ConstructionProvider>();
      final response = await provider.getAreas();
      if (response['success']) {
        final areas = List<String>.from(response['areas']);
        await CacheService.saveAreas(areas);
        setState(() { _areas = areas; });
      }
    } catch (e) {
      print('Error loading areas: $e');
    } finally {
      setState(() => _isLoadingAreas = false);
    }
  }

  Future<void> _loadWorkingSites() async {
    final cached = await CacheService.loadSupervisorWorkingSites();
    if (cached != null) {
      setState(() { _workingSites = cached; _isLoadingWorkingSites = false; });
      return;
    }
    setState(() => _isLoadingWorkingSites = true);
    try {
      final result = await _constructionService.getWorkingSites();
      if (result['success']) {
        final sites = List<Map<String, dynamic>>.from(result['sites'] ?? []);
        await CacheService.saveSupervisorWorkingSites(sites);
        setState(() { _workingSites = sites; });
      }
    } catch (e) {
      print('Error loading working sites: $e');
    } finally {
      setState(() => _isLoadingWorkingSites = false);
    }
  }

  Future<void> _loadTodaySitesWithData() async {
    final cached = await CacheService.loadTodaySitesWithData();
    if (cached != null) {
      setState(() { _todaySitesWithData = cached; _isLoadingTodaySites = false; });
      return;
    }
    setState(() => _isLoadingTodaySites = true);
    try {
      final result = await _constructionService.getTodaySitesWithEntries();
      if (result['success']) {
        final sites = List<Map<String, dynamic>>.from(result['sites'] ?? []);
        await CacheService.saveTodaySitesWithData(sites);
        setState(() { _todaySitesWithData = sites; });
      }
    } catch (e) {
      print('Error loading today sites with data: $e');
    } finally {
      setState(() => _isLoadingTodaySites = false);
    }
  }

  Future<void> _loadTotalCounts() async {
    final cached = await CacheService.loadTotalCounts();
    if (cached != null) {
      setState(() {
        _totalAreas = cached['total_areas'] ?? 0;
        _totalStreets = cached['total_streets'] ?? 0;
        _totalSites = cached['total_sites'] ?? 0;
        _isLoadingTotals = false;
      });
      return;
    }
    setState(() => _isLoadingTotals = true);
    try {
      final result = await _constructionService.getTotalCounts();
      if (result['success']) {
        await CacheService.saveTotalCounts({
          'total_areas': result['total_areas'] ?? 0,
          'total_streets': result['total_streets'] ?? 0,
          'total_sites': result['total_sites'] ?? 0,
        });
        setState(() {
          _totalAreas = result['total_areas'] ?? 0;
          _totalStreets = result['total_streets'] ?? 0;
          _totalSites = result['total_sites'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading total counts: $e');
    } finally {
      setState(() => _isLoadingTotals = false);
    }
  }

  Future<void> _loadStreets(String area) async {
    setState(() {
      _isLoadingStreets = true;
      _selectedStreet = null;
      _selectedSite = null;
      _streets = [];
      _sites = [];
    });

    try {
      final provider = context.read<ConstructionProvider>();

      // Use provider's cached method
      await provider.loadStreetsForArea(area);
      final streets = provider.getStreetsForArea(area);

      setState(() {
        _streets = streets;
      });
    } catch (e) {
      print('Error loading streets: $e');
      // Fallback to direct API call
      try {
        final provider = context.read<ConstructionProvider>();
        final response = await provider.getStreets(area);
        if (response['success']) {
          setState(() {
            _streets = List<String>.from(response['streets']);
          });
        }
      } catch (e2) {
        print('Fallback also failed: $e2');
      }
    } finally {
      setState(() => _isLoadingStreets = false);
    }
  }

  Future<void> _loadSites(String area, String street) async {
    setState(() {
      _isLoadingSites = true;
      _selectedSite = null;
      _sites = [];
    });

    try {
      final provider = context.read<ConstructionProvider>();
      final response = await provider.getSitesByAreaStreet(area, street);
      if (response['success']) {
        setState(() {
          _sites = List<Map<String, dynamic>>.from(response['sites']);
        });
      }
    } catch (e) {
      print('Error loading sites: $e');
    } finally {
      setState(() => _isLoadingSites = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onAreaChanged(String? area) {
    setState(() {
      _selectedArea = area;
      _selectedStreet = null;
      _selectedSite = null;
      _streets = [];
      _sites = [];
    });

    if (area != null) {
      _loadStreets(area);
    }
  }

  void _onStreetChanged(String? street) {
    setState(() {
      _selectedStreet = street;
      _selectedSite = null;
      _sites = [];
    });

    if (street != null && _selectedArea != null) {
      _loadSites(_selectedArea!, street);
    }
  }

  /// Refresh dashboard data after returning from SiteDetailScreen so the
  /// site cards immediately reflect submitted labour / photos.
  Future<void> _refreshAfterSiteDetail() async {
    await CacheService.clearTodaySitesWithData();
    await CacheService.clearSupervisorWorkingSites();
    if (!mounted) return;
    _loadTodaySitesWithData();
    _loadWorkingSites();
  }

  void _onSiteChanged(String? siteId) {
    setState(() => _selectedSite = siteId);

    if (siteId != null) {
      // Find the selected site and navigate to detail screen
      final site = _sites.firstWhere((s) => s['id'] == siteId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SiteDetailScreen(site: site),
        ),
      ).then((_) => _refreshAfterSiteDetail());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    if (_selectedIndex == 0) {
      currentScreen = _buildDashboard();
    } else if (_selectedIndex == 1) {
      currentScreen = const SupervisorReportsScreen();
    } else {
      currentScreen = _buildProfileScreen();
    }

    return Scaffold(
      backgroundColor: BWColors.background,
      body: currentScreen,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: BWColors.card,
          elevation: 0,
          toolbarHeight: 70,
          title: Row(
            children: [
              Container(
                width: 45.w,
                height: 45.h,
                decoration: BoxDecoration(
                  gradient: BWColors.bwGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BWColors.primary.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (_currentUser?['full_name'] ?? 'S').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentUser?['full_name'] ?? 'Supervisor',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: BWColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(
                            color: BWColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Active Now',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: BWColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Dashboard Stats Section
        SliverToBoxAdapter(
          child: Container(
            color: BWColors.card,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supervisor Dashboard Overview',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: BWColors.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Areas',
                        value: _areas.length.toString(),
                        icon: Icons.location_city,
                        color: BWColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SummaryCard(
                        title: 'Available Sites',
                        value: _sites.length.toString(),
                        icon: Icons.construction,
                        color: BWColors.muted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Working Sites Dropdown
                _buildWorkingSitesDropdown(),
              ],
            ),
          ),
        ),

        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            color: BWColors.card,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Site Location',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: BWColors.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Choose area, street, and site to view details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BWColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dropdown Selection Section
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: BWColors.card,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: BWColors.primary.withOpacity(0.08),
                  blurRadius: 20.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area Dropdown
                _buildDropdownSection(
                  title: 'Area',
                  icon: Icons.location_city,
                  value: _selectedArea,
                  items: _areas,
                  onChanged: _onAreaChanged,
                  isLoading: _isLoadingAreas,
                  hint: 'Select an area',
                ),

                SizedBox(height: 20.h),

                // Street Dropdown
                _buildDropdownSection(
                  title: 'Street',
                  icon: Icons.route,
                  value: _selectedStreet,
                  items: _streets,
                  onChanged: _onStreetChanged,
                  isLoading: _isLoadingStreets,
                  hint: 'Select a street',
                  enabled: _selectedArea != null,
                ),

                SizedBox(height: 20.h),

                // Site Dropdown
                _buildSiteDropdownSection(),
              ],
            ),
          ),
        ),

        // Sites List Section (Enhanced)
        if (_sites.isNotEmpty && _selectedStreet != null)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Sites',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: BWColors.primary,
                        ),
                      ),
                      Text(
                        '${_sites.length} sites',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: BWColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ..._sites.take(5).map((site) => _buildSimpleSiteCard(site)),
                  if (_sites.length > 5)
                    Container(
                      margin: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'And ${_sites.length - 5} more sites...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: BWColors.secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Selected Site Info
        if (_selectedSite != null)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: BWColors.bwGradient,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: BWColors.primary.withOpacity(0.3),
                    blurRadius: 20.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildSelectedSiteInfo(),
            ),
          ),

        // Instructions
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: BWColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: BWColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: BWColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Select area first, then street, and finally the site to view details and manage construction activities.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: BWColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  Widget _buildStatsScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: BWColors.card,
          elevation: 0,
          title: const Text(
            'Statistics',
            style: TextStyle(color: BWColors.primary),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Cards
                SummaryCard(
                  title: 'Total Areas',
                  value: _totalAreas.toString(),
                  icon: Icons.location_city,
                  color: BWColors.primary,
                ),
                SizedBox(height: 16.h),
                SummaryCard(
                  title: 'Total Streets',
                  value: _totalStreets.toString(),
                  icon: Icons.route,
                  color: BWColors.muted,
                ),
                SizedBox(height: 16.h),
                SummaryCard(
                  title: 'Total Sites',
                  value: _totalSites.toString(),
                  icon: Icons.business,
                  color: BWColors.primary,
                ),

                SizedBox(height: 32.h),

                // Today's Working Sites Dropdown
                _buildExpandableSection(
                  title: "Today's Working Sites",
                  icon: Icons.work_outline,
                  count: _workingSites.length,
                  isLoading: _isLoadingWorkingSites,
                  isEmpty: _workingSites.isEmpty,
                  emptyMessage: 'No working sites for today',
                  children: _workingSites.map((site) => _buildSiteListItem(site)).toList(),
                  onRefresh: _loadWorkingSites,
                ),

                SizedBox(height: 16.h),

                // Today's Sites with Entered Data Dropdown
                _buildExpandableSection(
                  title: "Today's Entered Data",
                  icon: Icons.edit_note,
                  count: _todaySitesWithData.length,
                  isLoading: _isLoadingTodaySites,
                  isEmpty: _todaySitesWithData.isEmpty,
                  emptyMessage: 'No data entered today',
                  children: _todaySitesWithData.map((site) => _buildSiteDataListItem(site)).toList(),
                  onRefresh: _loadTodaySitesWithData,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required int count,
    required bool isLoading,
    required bool isEmpty,
    required String emptyMessage,
    required List<Widget> children,
    required VoidCallback onRefresh,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: BWColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: BWColors.primary, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: BWColors.primary,
          ),
        ),
        subtitle: Text(
          '$count ${count == 1 ? 'site' : 'sites'}',
          style: TextStyle(
            fontSize: 13.sp,
            color: BWColors.secondaryText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: Icon(Icons.refresh, size: 20.sp),
                onPressed: onRefresh,
                tooltip: 'Refresh',
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(24.r),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (isEmpty)
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48.sp, color: BWColors.muted),
                    SizedBox(height: 12.h),
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: BWColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(children: children),
        ],
      ),
    );
  }

  Widget _buildSiteListItem(Map<String, dynamic> site) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: BWColors.primary.withOpacity(0.1),
        child: Icon(Icons.location_on, color: BWColors.primary, size: 20.sp),
      ),
      title: Text(
        site['site_name'] ?? 'Unknown Site',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          // Area Badge
          if (site['area'] != null && site['area'].toString().isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: BWColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: BWColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city, size: 10.sp, color: BWColors.primary),
                  SizedBox(width: 3.w),
                  Text(
                    site['area'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: BWColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 4.h),
          // Street
          Row(
            children: [
              Icon(Icons.route, size: 12.sp, color: BWColors.muted),
              SizedBox(width: 4.w),
              Text(
                site['street'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: BWColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: BWColors.muted),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteDetailScreen(site: site),
          ),
        ).then((_) => _refreshAfterSiteDetail());
      },
    );
  }

  Widget _buildSiteDataListItem(Map<String, dynamic> site) {
    final hasLabour = site['has_labour'] == true;
    final hasMaterial = site['has_material'] == true;
    final hasPhotos = site['has_photos'] == true;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.withOpacity(0.1),
        child: Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
      ),
      title: Text(
        site['site_name'] ?? 'Unknown Site',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          // Area Badge
          if (site['area'] != null && site['area'].toString().isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: BWColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: BWColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city, size: 10.sp, color: BWColors.primary),
                  SizedBox(width: 3.w),
                  Text(
                    site['area'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: BWColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 4.h),
          // Street
          Row(
            children: [
              Icon(Icons.route, size: 12.sp, color: BWColors.muted),
              SizedBox(width: 4.w),
              Text(
                site['street'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: BWColors.secondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 8,
            children: [
              if (hasLabour)
                _buildDataChip('Labour', Icons.people, Colors.blue),
              if (hasMaterial)
                _buildDataChip('Material', Icons.inventory_2, Colors.brown),
              if (hasPhotos)
                _buildDataChip('Photos', Icons.photo_camera, Colors.purple),
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: BWColors.muted),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteDetailScreen(site: site),
          ),
        ).then((_) => _refreshAfterSiteDetail());
      },
    );
  }

  Widget _buildDataChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isLoading,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: BWColors.primary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: BWColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: enabled ? BWColors.surface : BWColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: enabled ? BWColors.primary.withOpacity(0.3) : BWColors.secondaryText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BWColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: BWColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      enabled ? hint : 'Select ${title.toLowerCase()} first',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: BWColors.secondaryText,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: enabled ? BWColors.primary : BWColors.secondaryText,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BWColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: enabled
                        ? items.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList()
                        : null,
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSiteDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            children: [
            Icon(Icons.business, size: 18.sp, color: BWColors.primary),
            SizedBox(width: 8.w),
            Text(
              'Site',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: BWColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _selectedStreet != null ? BWColors.surface : BWColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _selectedStreet != null ? BWColors.primary.withOpacity(0.3) : BWColors.secondaryText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: _isLoadingSites
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BWColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading sites...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: BWColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSite,
                    hint: Text(
                      _selectedStreet != null ? 'Select a site' : 'Select street first',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: BWColors.secondaryText,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: _selectedStreet != null ? BWColors.primary : BWColors.secondaryText,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BWColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _selectedStreet != null
                        ? _sites.map((site) {
                            return DropdownMenuItem<String>(
                              value: site['id'],
                              child: Text(site['display_name'] ?? site['site_name'] ?? 'Site'),
                            );
                          }).toList()
                        : null,
                    onChanged: _selectedStreet != null ? _onSiteChanged : null,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedSiteInfo() {
    final site = _sites.firstWhere((s) => s['id'] == _selectedSite);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Site Selected',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          site['display_name'] ?? site['site_name'] ?? 'Site',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$_selectedArea • $_selectedStreet',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SiteDetailScreen(site: site),
                    ),
                  ).then((_) => _refreshAfterSiteDetail());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: BWColors.primary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_outlined, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupervisorHistoryScreen(
                      siteId: site['id'],
                      siteName: site['display_name'] ?? site['site_name'] ?? 'Site',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Icon(Icons.history, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: () {
                _showMaterialUsageDialog(site);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Icon(Icons.inventory_2, size: 18.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleSiteCard(Map<String, dynamic> site) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: BWColors.border),
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiteDetailScreen(site: site),
            ),
          ).then((_) => _refreshAfterSiteDetail());
        },
        contentPadding: EdgeInsets.all(12.r),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: BWColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.location_city,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(
          site['display_name'] ?? site['site_name'] ?? 'Unnamed Site',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: BWColors.primary,
          ),
        ),
        subtitle: Text(
          '${site['area'] ?? ''} • ${site['street'] ?? ''}',
          style: TextStyle(
            fontSize: 12.sp,
            color: BWColors.secondaryText,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: BWColors.secondaryText),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Container(
      color: BWColors.background,
      child: CustomScrollView(
        slivers: [
          // Simple Profile Header
          SliverAppBar(
            floating: true,
            backgroundColor: BWColors.card,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(color: BWColors.primary),
            ),
          ),
          // Profile Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      gradient: BWColors.bwGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BWColors.primary.withOpacity(0.3),
                          blurRadius: 10.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (_currentUser?['full_name'] ?? 'S').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _currentUser?['full_name'] ?? 'Supervisor',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _currentUser?['role'] ?? 'Supervisor',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BWColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Info Cards
                  _buildSimpleProfileInfo('Email', _currentUser?['email'] ?? 'N/A', Icons.email),
                  SizedBox(height: 12.h),
                  _buildSimpleProfileInfo('Username', _currentUser?['username'] ?? 'N/A', Icons.person),
                  SizedBox(height: 12.h),
                  _buildSimpleProfileInfo('Phone', _currentUser?['phone'] ?? 'N/A', Icons.phone),
                  SizedBox(height: 24.h),
                  // Settings
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildProfileSettingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your name and phone',
                    onTap: () => _showEditProfileDialog(),
                  ),
                  SizedBox(height: 12.h),
                  _buildProfileSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  SizedBox(height: 12.h),
                  _buildProfileSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () => _showComingSoonDialog('Notifications'),
                  ),
                  SizedBox(height: 12.h),
                  _buildProfileSettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () => _showComingSoonDialog('Language Settings'),
                  ),
                  SizedBox(height: 32.h),
                  // App Information
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildProfileSettingsTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  SizedBox(height: 12.h),
                  _buildProfileSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help with the app',
                    onTap: () => _showComingSoonDialog('Help & Support'),
                  ),
                  SizedBox(height: 12.h),
                  _buildProfileSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () => _showComingSoonDialog('Privacy Policy'),
                  ),
                  SizedBox(height: 32.h),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BWColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleProfileInfo(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: BWColors.border),
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: BWColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BWColors.secondaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: BWColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: BWColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: BWColors.primary, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: BWColors.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: BWColors.secondaryText,
          ),
        ),
        trailing: onTap != null
            ? const Icon(
                Icons.chevron_right,
                color: BWColors.secondaryText,
              )
            : null,
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final nameCtrl = TextEditingController(text: _currentUser?['full_name'] ?? '');
    final phoneCtrl = TextEditingController(text: _currentUser?['phone'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: BWColors.primary, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, color: BWColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: BWColors.primary, width: 2),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined, color: BWColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: BWColors.primary, width: 2),
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
              child: const Text('Cancel', style: TextStyle(color: BWColors.secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BWColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
                          _currentUser = {
                            ..._currentUser ?? {},
                            'full_name': newName.isNotEmpty ? newName : (_currentUser?['full_name'] ?? ''),
                            'phone': newPhone.isNotEmpty ? newPhone : (_currentUser?['phone'] ?? ''),
                          };
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['success'] == true
                              ? 'Profile updated successfully!'
                              : result['error'] ?? 'Update failed'),
                          backgroundColor: result['success'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    },
              child: isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change feature coming soon!'),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.1),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
              _buildNavItem(Icons.description, 'Reports', 1),
              _buildNavItem(Icons.person_rounded, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? BWColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: BWColors.primary.withOpacity(0.3),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : BWColors.secondaryText,
              size: 22.sp,
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMaterialUsageDialog(Map<String, dynamic> site) {
    showDialog(
      context: context,
      builder: (context) => SupervisorMaterialUsageDialog(
        siteId: site['id'].toString(),
        onSuccess: () {
          // Refresh data if needed
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Material usage recorded successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> _groupBySitesByAreaAndStreet() {
    final grouped = <String, Map<String, List<Map<String, dynamic>>>>{};
    for (final site in _workingSites) {
      final area = site['area']?.toString().trim().isNotEmpty == true
          ? site['area'].toString()
          : 'Unknown Area';
      final street = site['street']?.toString().trim().isNotEmpty == true
          ? site['street'].toString()
          : 'Unknown Street';
      grouped.putIfAbsent(area, () => {});
      grouped[area]!.putIfAbsent(street, () => []);
      grouped[area]![street]!.add(site);
    }
    return grouped;
  }

  Widget _buildGroupedWorkingSites() {
    final grouped = _groupBySitesByAreaAndStreet();
    return Column(
      children: grouped.entries.map((areaEntry) {
        final area = areaEntry.key;
        final streets = areaEntry.value;
        final totalSitesInArea = streets.values.fold(0, (sum, s) => sum + s.length);

        return ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: BWColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.location_city, color: BWColors.primary, size: 20.sp),
          ),
          title: Text(
            area,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: BWColors.primary,
            ),
          ),
          subtitle: Text(
            '$totalSitesInArea ${totalSitesInArea == 1 ? 'site' : 'sites'} · ${streets.length} ${streets.length == 1 ? 'street' : 'streets'}',
            style: TextStyle(fontSize: 12.sp, color: BWColors.secondaryText),
          ),
          children: streets.entries.map((streetEntry) {
            final street = streetEntry.key;
            final sites = streetEntry.value;

            return ExpansionTile(
              tilePadding: EdgeInsets.only(left: 32.w, right: 16.w),
              leading: Icon(Icons.route, color: BWColors.muted, size: 18.sp),
              title: Text(
                street,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: BWColors.primary,
                ),
              ),
              subtitle: Text(
                '${sites.length} ${sites.length == 1 ? 'site' : 'sites'}',
                style: TextStyle(fontSize: 12.sp, color: BWColors.secondaryText),
              ),
              children: sites.map((site) {
                final siteForDetail = {
                  'id': site['site_id'] ?? site['id'],
                  'display_name': site['display_name'] ?? site['site_name'],
                  'area': site['area'],
                  'street': site['street'],
                  'customer_name': site['customer_name'],
                  'site_name': site['site_name'],
                };
                return ListTile(
                  contentPadding: EdgeInsets.only(left: 56.w, right: 16.w),
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: BWColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.construction, color: BWColors.primary, size: 18.sp),
                  ),
                  title: Text(
                    site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: BWColors.primary,
                    ),
                  ),
                  subtitle: site['description'] != null && site['description'].toString().trim().isNotEmpty
                      ? Text(
                          site['description'],
                          style: TextStyle(fontSize: 12.sp, color: BWColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: BWColors.muted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SiteDetailScreen(site: siteForDetail),
                      ),
                    ).then((_) => _refreshAfterSiteDetail());
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildWorkingSitesDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _workingSitesExpanded = !_workingSitesExpanded);
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: BWColors.primary.withOpacity(0.1),
                borderRadius: _workingSitesExpanded
                    ? BorderRadius.vertical(top: Radius.circular(12.r))
                    : BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: BWColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.work, color: BWColors.primary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Working Sites',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: BWColors.primary,
                      ),
                    ),
                  ),
                  if (_workingSites.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: BWColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${_workingSites.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Icon(
                    _workingSitesExpanded ? Icons.expand_less : Icons.expand_more,
                    color: BWColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_workingSitesExpanded) ...[
            if (_isLoadingWorkingSites)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: const CircularProgressIndicator(),
              )
            else if (_workingSites.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Icon(Icons.work_off, size: 48.sp, color: BWColors.secondaryText),
                    SizedBox(height: 8.h),
                    Text(
                      'No working sites assigned yet',
                      style: TextStyle(color: BWColors.secondaryText, fontSize: 14.sp),
                    ),
                  ],
                ),
              )
            else
              _buildGroupedWorkingSites(),
          ],
        ],
      ),
    );
  }
}
