import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/construction_provider.dart';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import '../services/budget_management_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'site_engineer_site_detail_screen.dart';
import 'site_engineer_material_screen.dart';
import 'site_engineer_document_screen.dart';
import 'site_engineer_labour_screen.dart';

class SiteEngineerDashboard extends StatefulWidget {
  final UserModel user;

  const SiteEngineerDashboard({super.key, required this.user});

  @override
  State<SiteEngineerDashboard> createState() => _SiteEngineerDashboardState();
}

class _SiteEngineerDashboardState extends State<SiteEngineerDashboard> {
  final _authService = AuthService();
  int _currentBottomIndex = 0; // 0=Dashboard, 1=Sites, 2=Notifications, 3=Profile
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, Map<String, bool>> _uploadStatus = {}; // site_id -> {morning: bool, evening: bool}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<ConstructionProvider>().loadSites();
    await _loadUploadStatuses();
  }

  Future<void> _loadUploadStatuses() async {
    final sites = context.read<ConstructionProvider>().sites;
    for (var site in sites) {
      await _loadSiteUploadStatus(site['id']);
    }
  }

  Future<void> _loadSiteUploadStatus(String siteId) async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/today-upload-status/$siteId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _uploadStatus[siteId] = {
            'morning': data['morning_uploaded'] ?? false,
            'evening': data['evening_uploaded'] ?? false,
          };
        });
      }
    } catch (e) {
      // Silently fail - status will show as not uploaded
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusOverdue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        Widget currentScreen;
        switch (_currentBottomIndex) {
          case 0: // Dashboard
            currentScreen = _buildDashboardTab(provider);
            break;
          case 1: // Sites
            currentScreen = _buildSitesTab(provider);
            break;
          case 2: // Notifications
            currentScreen = _buildNotificationsTab();
            break;
          case 3: // Profile
            currentScreen = _buildProfileTab();
            break;
          default:
            currentScreen = _buildDashboardTab(provider);
        }

        return Scaffold(
          backgroundColor: AppColors.lightSlate,
          appBar: CommonWidgets.buildAppBar(
            context,
            title: _getAppBarTitle(),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.deepNavy),
                onPressed: _logout,
                tooltip: 'Sign Out',
              ),
            ],
          ),
          body: currentScreen,
          bottomNavigationBar: CommonWidgets.buildBottomNavigationBar(
            context,
            currentIndex: _currentBottomIndex,
            onTap: (index) => setState(() => _currentBottomIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                activeIcon: Icon(Icons.dashboard, size: 28),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_city),
                activeIcon: Icon(Icons.location_city, size: 28),
                label: 'Sites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                activeIcon: Icon(Icons.notifications, size: 28),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                activeIcon: Icon(Icons.person, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentBottomIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Sites';
      case 2:
        return 'Notifications';
      case 3:
        return 'Profile';
      default:
        return 'Site Engineer';
    }
  }

  // Dashboard Tab - Overview
  Widget _buildDashboardTab(ConstructionProvider provider) {
    final sites = provider.sites;
    final totalSites = sites.length;
    final morningUploaded = _uploadStatus.values.where((s) => s['morning'] == true).length;
    final eveningUploaded = _uploadStatus.values.where((s) => s['evening'] == true).length;

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadSites(forceRefresh: true);
        await _loadUploadStatuses();
      },
      color: AppColors.deepNavy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.engineering, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${widget.user.name ?? "Engineer"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Site Engineer Dashboard',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            const Text(
              'Today\'s Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                SummaryCard(
                  title: 'Total Sites',
                  value: '$totalSites',
                  icon: Icons.location_city,
                  color: AppColors.deepNavy,
                ),
                SummaryCard(
                  title: 'Morning Photos',
                  value: '$morningUploaded/$totalSites',
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                ),
                SummaryCard(
                  title: 'Evening Photos',
                  value: '$eveningUploaded/$totalSites',
                  icon: Icons.nights_stay,
                  color: Colors.purple,
                ),
                SummaryCard(
                  title: 'Pending',
                  value: '${totalSites - morningUploaded}',
                  icon: Icons.pending_actions,
                  color: AppColors.statusOverdue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'View Sites',
                    Icons.location_city,
                    () => setState(() => _currentBottomIndex = 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Notifications',
                    Icons.notifications,
                    () => setState(() => _currentBottomIndex = 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Material Inventory',
                    Icons.inventory_2,
                    _openMaterialInventory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Labor Entry',
                    Icons.people,
                    _openLaborEntry,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Documents',
                    Icons.description,
                    _openDocuments,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.deepNavy, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
          ],
        ),
      ),
    );
  }

  // Sites Tab - Dropdown Selection instead of Cards
  Widget _buildSitesTab(ConstructionProvider provider) {
    final sites = provider.sites;
    final filteredSites = _searchQuery.isEmpty
        ? sites
        : sites.where((site) {
            final name = (site['display_name'] ?? site['site_name'] ?? '').toString().toLowerCase();
            final area = (site['area'] ?? '').toString().toLowerCase();
            final street = (site['street'] ?? '').toString().toLowerCase();
            final customer = (site['customer_name'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || area.contains(query) || street.contains(query) || customer.contains(query);
          }).toList();

    final isLoading = sites.isEmpty && _uploadStatus.isEmpty;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.deepNavy));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadSites(forceRefresh: true);
        await _loadUploadStatuses();
      },
      color: AppColors.deepNavy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Select Site',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a site to view details and upload photos',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search sites by name, area, or customer...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.deepNavy),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () => setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(height: 16),

            // Results count
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Found ${filteredSites.length} site(s)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),

            // Sites Dropdown List
            if (filteredSites.isEmpty)
              CommonWidgets.buildEmptyState(
                context,
                message: 'No Sites Assigned',
                icon: Icons.location_city,
                actionText: 'Refresh',
                onAction: () async {
                  await provider.loadSites(forceRefresh: true);
                  await _loadUploadStatuses();
                },
              )
            else
              ...filteredSites.map((site) => _buildSiteDropdownItem(site)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteDropdownItem(Map<String, dynamic> site) {
    final siteId = site['id'].toString();
    final status = _uploadStatus[siteId] ?? {'morning': false, 'evening': false};
    final siteName = site['display_name'] ?? site['site_name'] ?? 'Unknown Site';
    final location = '${site['area'] ?? ''}, ${site['street'] ?? ''}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.deepNavy.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openSiteDetail(site),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Site Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.navyGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Site Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siteName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Photo Status Row
                    Row(
                      children: [
                        _buildCompactStatusChip(
                          '🌅',
                          'Morning',
                          status['morning'] ?? false,
                        ),
                        const SizedBox(width: 8),
                        _buildCompactStatusChip(
                          '🌆',
                          'Evening',
                          status['evening'] ?? false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatusChip(String icon, String label, bool uploaded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: uploaded 
            ? AppColors.statusCompleted.withValues(alpha: 0.1) 
            : AppColors.statusOverdue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: uploaded ? AppColors.statusCompleted : AppColors.statusOverdue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: uploaded ? AppColors.statusCompleted : AppColors.statusOverdue,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            uploaded ? Icons.check_circle : Icons.pending,
            size: 12,
            color: uploaded ? AppColors.statusCompleted : AppColors.statusOverdue,
          ),
        ],
      ),
    );
  }

  // Notifications Tab
  Widget _buildNotificationsTab() {
    return CommonWidgets.buildEmptyState(
      context,
      message: 'No Notifications\n\nYou\'re all caught up!\nNotifications will appear here',
      icon: Icons.notifications_none,
    );
  }

  // Profile Tab
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.navyGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name ?? 'Site Engineer',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email ?? '',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Site Engineer',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Options
          _buildProfileOption(Icons.person_outline, 'Edit Profile', () {}),
          _buildProfileOption(Icons.lock_outline, 'Change Password', () {}),
          _buildProfileOption(Icons.settings_outlined, 'Settings', () {}),
          _buildProfileOption(Icons.help_outline, 'Help & Support', () {}),
          _buildProfileOption(Icons.info_outline, 'About', () {}),
          const SizedBox(height: 16),
          _buildProfileOption(Icons.logout, 'Sign Out', _logout, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppColors.statusOverdue : AppColors.deepNavy),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.statusOverdue : AppColors.deepNavy,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive ? AppColors.statusOverdue : AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _openSiteDetail(Map<String, dynamic> site) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteEngineerSiteDetailScreen(
          site: site,
          user: widget.user,
        ),
      ),
    );
    
    // Reload status if returned from detail screen
    if (result == true) {
      await _loadSiteUploadStatus(site['id']);
    }
  }

  void _openMaterialInventory() {
    final sites = context.read<ConstructionProvider>().sites;
    
    if (sites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sites available. Please add sites first.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    // If only one site, open directly
    if (sites.length == 1) {
      final site = sites[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SiteEngineerMaterialScreen(
            siteId: site['id'].toString(),
            siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
          ),
        ),
      );
      return;
    }

    // Multiple sites - show selection dialog
    _showSiteSelectionDialog(
      title: 'Select Site for Material Inventory',
      onSiteSelected: (site) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteEngineerMaterialScreen(
              siteId: site['id'].toString(),
              siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
            ),
          ),
        );
      },
    );
  }

  void _openLaborEntry() {
    final sites = context.read<ConstructionProvider>().sites;
    
    if (sites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sites available. Please add sites first.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    // If only one site, open directly
    if (sites.length == 1) {
      final site = sites[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SiteEngineerLabourScreen(
            siteId: site['id'].toString(),
            siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
          ),
        ),
      );
      return;
    }

    // Multiple sites - show selection dialog
    _showSiteSelectionDialog(
      title: 'Select Site for Labor Entry',
      onSiteSelected: (site) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SiteEngineerLabourScreen(
              siteId: site['id'].toString(),
              siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
            ),
          ),
        );
      },
    );
  }

  void _openDocuments() {
    final sites = context.read<ConstructionProvider>().sites;
    
    if (sites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sites available. Please add sites first.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    // If only one site, open directly
    if (sites.length == 1) {
      final site = sites[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SiteEngineerDocumentScreen(
            siteId: site['id'].toString(),
            siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
          ),
        ),
      );
      return;
    }

    // Multiple sites - show selection dialog
    _showSiteSelectionDialog(
      title: 'Select Site for Documents',
      onSiteSelected: (site) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteEngineerDocumentScreen(
              siteId: site['id'].toString(),
              siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
            ),
          ),
        );
      },
    );
  }

  void _showSiteSelectionDialog({
    required String title,
    required Function(Map<String, dynamic>) onSiteSelected,
  }) {
    final sites = context.read<ConstructionProvider>().sites;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cleanWhite,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sites.length,
            itemBuilder: (context, index) {
              final site = sites[index];
              final siteName = site['display_name'] ?? site['site_name'] ?? 'Unknown Site';
              final location = '${site['area'] ?? ''}, ${site['street'] ?? ''}';
              
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.navyGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_city, color: Colors.white, size: 20),
                ),
                title: Text(
                  siteName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                subtitle: Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSiteSelected(site);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showLaborEntryDialog(Map<String, dynamic> site) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LaborEntrySheet(
        siteId: site['id'].toString(),
        siteName: site['display_name'] ?? site['site_name'] ?? 'Unknown Site',
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Labor entry submitted successfully!'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
        },
      ),
    );
  }
}

// Labor Entry Sheet for Site Engineer
class _LaborEntrySheet extends StatefulWidget {
  final String siteId;
  final String siteName;
  final VoidCallback onSuccess;

  const _LaborEntrySheet({
    required this.siteId,
    required this.siteName,
    required this.onSuccess,
  });

  @override
  State<_LaborEntrySheet> createState() => _LaborEntrySheetState();
}

class _LaborEntrySheetState extends State<_LaborEntrySheet> {
  final _constructionService = ConstructionService();
  final _budgetService = BudgetManagementService();
  final Map<String, int> _labourCounts = {
    'Carpenter': 0,
    'Mason': 0,
    'Electrician': 0,
    'Plumber': 0,
    'Painter': 0,
    'Helper': 0,
    'General': 0,
    'Tile Layer': 0,
    'Tile Layerhelper': 0,
    'Kambi Fitter': 0,
    'Concrete Kot': 0,
    'Pile Labour': 0,
  };

  // Rates loaded from admin global rates (single source of truth)
  Map<String, double> _rates = {};

  final _extraCostController = TextEditingController();
  final _extraCostNotesController = TextEditingController();
  bool _isSubmitting = false;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    final rates = await _budgetService.getLabourRates('global');
    if (rates.isNotEmpty && mounted) {
      final Map<String, double> loaded = {};
      for (final r in rates) {
        final type = r['labour_type'] as String?;
        final rate = (r['daily_rate'] as num?)?.toDouble();
        if (type != null && rate != null) loaded[type] = rate;
      }
      setState(() => _rates = loaded);
    }
  }

  int get _totalCount => _labourCounts.values.fold(0, (sum, count) => sum + count);

  double get _totalSalary => _labourCounts.entries.fold(
        0,
        (sum, e) => sum + e.value * (_rates[e.key] ?? 0),
      );

  @override
  void dispose() {
    _extraCostController.dispose();
    _extraCostNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                '👷 Labor Entry',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Workers: $_totalCount',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₹${_totalSalary.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.siteName,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 300,
            child: ListView(
              children: _labourCounts.keys.map((type) => _buildLabourTypeRow(type)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Extra Cost Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 20, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Extra Cost (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _extraCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount (₹)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange.shade200),
                    ),
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.orange.shade700),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _extraCostNotesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Notes (e.g., transport, tools)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange.shade200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _totalCount > 0 && !_isSubmitting ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.safetyOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Submit Labor Entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabourTypeRow(String type) {
    final count = _labourCounts[type]!;
    final icon = _getLabourIcon(type);
    final rate = _rates[type] ?? 0;
    final rowTotal = count * rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: count > 0 ? AppColors.deepNavy.withValues(alpha: 0.05) : AppColors.lightSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: count > 0 ? AppColors.deepNavy.withValues(alpha: 0.2) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: count > 0 ? AppColors.deepNavy : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: count > 0 ? FontWeight.bold : FontWeight.w500,
                    color: count > 0 ? AppColors.deepNavy : AppColors.textSecondary,
                  ),
                ),
                Text(
                  count > 0
                      ? '₹${rate.toStringAsFixed(0)}/day × $count = ₹${rowTotal.toStringAsFixed(0)}'
                      : '₹${rate.toStringAsFixed(0)}/day',
                  style: TextStyle(
                    fontSize: 12,
                    color: count > 0 ? Colors.green.shade700 : AppColors.textSecondary,
                    fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _labourCounts[type] = (count - 1).clamp(0, 50)),
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                color: count > 0 ? AppColors.safetyOrange : AppColors.textSecondary,
              ),
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  gradient: count > 0 ? AppColors.orangeGradient : null,
                  color: count == 0 ? AppColors.lightSlate : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: count > 0 ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _labourCounts[type] = (count + 1).clamp(0, 50)),
                icon: const Icon(Icons.add_circle_outline, size: 32),
                color: AppColors.safetyOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLabourIcon(String type) {
    switch (type) {
      case 'Carpenter': return Icons.carpenter;
      case 'Mason': return Icons.construction;
      case 'Electrician': return Icons.electrical_services;
      case 'Plumber': return Icons.plumbing;
      case 'Painter': return Icons.format_paint;
      case 'Helper': return Icons.handyman;
      case 'Tile Layer': return Icons.layers;
      case 'Tile Layerhelper': return Icons.layers_outlined;
      case 'Kambi Fitter': return Icons.build;
      case 'Concrete Kot': return Icons.foundation;
      case 'Pile Labour': return Icons.vertical_align_bottom;
      default: return Icons.person;
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    
    final extraCost = double.tryParse(_extraCostController.text.trim()) ?? 0;
    final extraCostNotes = _extraCostNotesController.text.trim();
    
    // Submit each labour type with count > 0
    for (final entry in _labourCounts.entries) {
      if (entry.value > 0) {
        await _constructionService.submitLabourCount(
          siteId: widget.siteId,
          labourCount: entry.value,
          labourType: entry.key,
          extraCost: extraCost > 0 ? extraCost : null,
          extraCostNotes: extraCostNotes.isNotEmpty ? extraCostNotes : null,
          customDateTime: _selectedDateTime,
        );
      }
    }
    
    setState(() => _isSubmitting = false);
    
    if (mounted) {
      Navigator.pop(context);
      widget.onSuccess();
    }
  }
}

// Summary Card Widget
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

