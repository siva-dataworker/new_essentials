import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    setState(() => _isLoadingAreas = true);
    try {
      final provider = context.read<ConstructionProvider>();
      final response = await provider.getAreas();
      if (response['success']) {
        setState(() {
          _areas = List<String>.from(response['areas']);
        });
      }
    } catch (e) {
      print('Error loading areas: $e');
    } finally {
      setState(() => _isLoadingAreas = false);
    }
  }

  Future<void> _loadWorkingSites() async {
    setState(() => _isLoadingWorkingSites = true);
    try {
      final result = await _constructionService.getWorkingSites();
      if (result['success']) {
        setState(() {
          _workingSites = List<Map<String, dynamic>>.from(result['sites'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading working sites: $e');
    } finally {
      setState(() => _isLoadingWorkingSites = false);
    }
  }

  Future<void> _loadTodaySitesWithData() async {
    setState(() => _isLoadingTodaySites = true);
    try {
      final result = await _constructionService.getTodaySitesWithEntries();
      if (result['success']) {
        setState(() {
          _todaySitesWithData = List<Map<String, dynamic>>.from(result['sites'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading today sites with data: $e');
    } finally {
      setState(() => _isLoadingTodaySites = false);
    }
  }

  Future<void> _loadTotalCounts() async {
    setState(() => _isLoadingTotals = true);
    try {
      final result = await _constructionService.getTotalCounts();
      if (result['success']) {
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
      final response = await provider.getStreets(area);
      if (response['success']) {
        setState(() {
          _streets = List<String>.from(response['streets']);
        });
      }
    } catch (e) {
      print('Error loading streets: $e');
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
      );
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: BWColors.bwGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BWColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (_currentUser?['full_name'] ?? 'S').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentUser?['full_name'] ?? 'Supervisor',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: BWColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: BWColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Active Now',
                          style: TextStyle(
                            fontSize: 12,
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
          actions: [
            IconButton(
              icon: const Icon(Icons.work_outline, color: BWColors.primary, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkingSitesScreen(),
                  ),
                );
              },
              tooltip: 'Working Sites',
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: BWColors.primary, size: 24),
              onPressed: _logout,
            ),
            const SizedBox(width: 8),
          ],
        ),
        
        // Dashboard Stats Section
        SliverToBoxAdapter(
          child: Container(
            color: BWColors.card,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supervisor Dashboard Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BWColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
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
                    const SizedBox(width: 12),
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
                const SizedBox(height: 16),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Site Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BWColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose area, street, and site to view details',
                  style: TextStyle(
                    fontSize: 14,
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
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BWColors.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: BWColors.primary.withOpacity(0.08),
                  blurRadius: 20,
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
                
                const SizedBox(height: 20),
                
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
                
                const SizedBox(height: 20),
                
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
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Sites',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BWColors.primary,
                        ),
                      ),
                      Text(
                        '${_sites.length} sites',
                        style: TextStyle(
                          fontSize: 12,
                          color: BWColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._sites.take(5).map((site) => _buildSimpleSiteCard(site)),
                  if (_sites.length > 5)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Text(
                        'And ${_sites.length - 5} more sites...',
                        style: TextStyle(
                          fontSize: 12,
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
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: BWColors.bwGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: BWColors.primary.withOpacity(0.3),
                    blurRadius: 20,
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
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BWColors.surface,
              borderRadius: BorderRadius.circular(16),
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
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select area first, then street, and finally the site to view details and manage construction activities.',
                    style: TextStyle(
                      fontSize: 13,
                      color: BWColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),
                SummaryCard(
                  title: 'Total Streets',
                  value: _totalStreets.toString(),
                  icon: Icons.route,
                  color: BWColors.muted,
                ),
                const SizedBox(height: 16),
                SummaryCard(
                  title: 'Total Sites',
                  value: _totalSites.toString(),
                  icon: Icons.business,
                  color: BWColors.primary,
                ),
                
                const SizedBox(height: 32),
                
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
                
                const SizedBox(height: 16),
                
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BWColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: BWColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BWColors.primary,
          ),
        ),
        subtitle: Text(
          '$count ${count == 1 ? 'site' : 'sites'}',
          style: TextStyle(
            fontSize: 13,
            color: BWColors.secondaryText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: onRefresh,
                tooltip: 'Refresh',
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: BWColors.muted),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        fontSize: 14,
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
        child: Icon(Icons.location_on, color: BWColors.primary, size: 20),
      ),
      title: Text(
        site['site_name'] ?? 'Unknown Site',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${site['area'] ?? 'N/A'} • ${site['street'] ?? 'N/A'}',
        style: TextStyle(
          fontSize: 12,
          color: BWColors.secondaryText,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: BWColors.muted),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteDetailScreen(site: site),
          ),
        );
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
        child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      ),
      title: Text(
        site['site_name'] ?? 'Unknown Site',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${site['area'] ?? 'N/A'} • ${site['street'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 12,
              color: BWColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: BWColors.muted),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteDetailScreen(site: site),
          ),
        );
      },
    );
  }

  Widget _buildDataChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
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
            Icon(icon, size: 18, color: BWColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: BWColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: enabled ? BWColors.surface : BWColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? BWColors.primary.withOpacity(0.3) : BWColors.secondaryText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BWColors.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
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
                        fontSize: 14,
                        color: BWColors.secondaryText,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: enabled ? BWColors.primary : BWColors.secondaryText,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
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
            const Icon(Icons.business, size: 18, color: BWColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Site',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: BWColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _selectedStreet != null ? BWColors.surface : BWColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedStreet != null ? BWColors.primary.withOpacity(0.3) : BWColors.secondaryText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: _isLoadingSites
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BWColors.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading sites...',
                        style: TextStyle(
                          fontSize: 14,
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
                        fontSize: 14,
                        color: BWColors.secondaryText,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: _selectedStreet != null ? BWColors.primary : BWColors.secondaryText,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
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
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Site Selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          site['display_name'] ?? site['site_name'] ?? 'Site',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_selectedArea • $_selectedStreet',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 16),
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
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: BWColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.history, size: 18),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                _showMaterialUsageDialog(site);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.inventory_2, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleSiteCard(Map<String, dynamic> site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BWColors.border),
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.06),
            blurRadius: 10,
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
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BWColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_city,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          site['display_name'] ?? site['site_name'] ?? 'Unnamed Site',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: BWColors.primary,
          ),
        ),
        subtitle: Text(
          '${site['area'] ?? ''} • ${site['street'] ?? ''}',
          style: TextStyle(
            fontSize: 12,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: BWColors.bwGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BWColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (_currentUser?['full_name'] ?? 'S').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser?['full_name'] ?? 'Supervisor',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?['role'] ?? 'Supervisor',
                    style: TextStyle(
                      fontSize: 14,
                      color: BWColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info Cards
                  _buildSimpleProfileInfo('Email', _currentUser?['email'] ?? 'N/A', Icons.email),
                  const SizedBox(height: 12),
                  _buildSimpleProfileInfo('Username', _currentUser?['username'] ?? 'N/A', Icons.person),
                  const SizedBox(height: 12),
                  _buildSimpleProfileInfo('Phone', _currentUser?['phone'] ?? 'N/A', Icons.phone),
                  const SizedBox(height: 24),
                  // Settings
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileSettingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your name and phone',
                    onTap: () => _showEditProfileDialog(),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () => _showComingSoonDialog('Notifications'),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileSettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () => _showComingSoonDialog('Language Settings'),
                  ),
                  const SizedBox(height: 32),
                  // App Information
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileSettingsTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help with the app',
                    onTap: () => _showComingSoonDialog('Help & Support'),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () => _showComingSoonDialog('Privacy Policy'),
                  ),
                  const SizedBox(height: 32),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BWColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BWColors.border),
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: BWColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: BWColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BWColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BWColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: BWColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BWColors.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BWColors.primary, width: 2),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined, color: BWColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
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
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? BWColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: BWColors.primary.withOpacity(0.3),
              blurRadius: 10,
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
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
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

  Widget _buildWorkingSitesDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _workingSitesExpanded = !_workingSitesExpanded);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BWColors.primary.withOpacity(0.1),
                borderRadius: _workingSitesExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BWColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.work, color: BWColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Working Sites',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BWColors.primary,
                      ),
                    ),
                  ),
                  if (_workingSites.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BWColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_workingSites.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
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
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_workingSites.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.work_off, size: 48, color: BWColors.secondaryText),
                    const SizedBox(height: 8),
                    Text(
                      'No working sites assigned yet',
                      style: TextStyle(color: BWColors.secondaryText, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workingSites.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final site = _workingSites[index];
                  // Ensure site has 'id' field for SiteDetailScreen
                  final siteForDetail = {
                    'id': site['site_id'] ?? site['id'],
                    'display_name': site['display_name'] ?? site['site_name'],
                    'area': site['area'],
                    'street': site['street'],
                    'customer_name': site['customer_name'],
                    'site_name': site['site_name'],
                  };
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BWColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.construction, color: BWColors.primary, size: 24),
                    ),
                    title: Text(
                      site['display_name'] ?? 'Unknown Site',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: BWColors.primary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: BWColors.muted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${site['area'] ?? ''} - ${site['street'] ?? ''}',
                                style: TextStyle(fontSize: 12, color: BWColors.secondaryText),
                              ),
                            ),
                          ],
                        ),
                        if (site['description'] != null && site['description'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              site['description'],
                              style: TextStyle(fontSize: 12, color: BWColors.secondaryText),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: BWColors.muted),
                    onTap: () {
                      // Navigate to site detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SiteDetailScreen(
                            site: siteForDetail,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
