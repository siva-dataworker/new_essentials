import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import '../services/notification_service.dart';
import '../services/cache_service.dart';
import '../utils/smooth_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'admin_labour_rates_screen.dart';
import 'admin_budget_management_screen.dart';
import 'admin_client_complaints_screen.dart';
import 'admin_manage_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService();
  final _notificationService = NotificationService();
  int _selectedIndex = 0;
  
  // Background refresh timers
  Timer? _notificationsRefreshTimer;
  Timer? _sitesRefreshTimer;

  // Profile state
  Map<String, dynamic>? _currentAdminUser;
  String _profileName = 'Admin';
  String _profilePhone = '';

  // Sites tab state
  static const String _sitesBaseUrl = 'https://new-essentials.onrender.com/api';
  List<String> _areas = [];
  List<String> _streets = [];
  List<Map<String, dynamic>> _sites = [];
  String? _selectedArea;
  String? _selectedStreet;
  bool _sitesLoading = false;
  
  // Cache for streets and sites
  final Map<String, List<String>> _streetsCache = {};
  final Map<String, List<Map<String, dynamic>>> _sitesCache = {};

  // Notifications state
  List<Map<String, dynamic>> _notifications = [];
  bool _notificationsLoading = false;
  int _unreadCount = 0;
  bool _notificationsLoaded = false; // Cache flag

  @override
  void initState() {
    super.initState();
    _loadAdminUser();
    _loadData();
    _loadAreas();
    _startBackgroundRefresh();
  }
  
  @override
  void dispose() {
    _stopBackgroundRefresh();
    super.dispose();
  }
  
  void _startBackgroundRefresh() {
    // Refresh notifications every 30 seconds
    _notificationsRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (_selectedIndex == 1 && mounted) {
          _loadNotifications(forceRefresh: true);
        }
      },
    );
    
    // Refresh sites data every 60 seconds
    _sitesRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        if (_selectedIndex == 0 && mounted) {
          // Silently refresh areas
          _loadAreas();
        }
      },
    );
  }
  
  void _stopBackgroundRefresh() {
    _notificationsRefreshTimer?.cancel();
    _sitesRefreshTimer?.cancel();
  }

  Future<void> _loadAdminUser() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentAdminUser = user;
        _profileName = user['full_name'] ?? user['username'] ?? 'Admin';
        _profilePhone = user['phone'] ?? '';
      });
    }
  }
  
  void _loadData() {
    if (_selectedIndex == 1) {
      // Notifications tab
      _loadNotifications();
    }
    // Add other tab data loading here
  }

  Future<void> _loadNotifications({bool forceRefresh = false}) async {
    // Load from persistent cache first (instant display)
    if (!forceRefresh && !_notificationsLoaded) {
      final cached = await CacheService.loadNotifications();
      if (cached != null && mounted) {
        setState(() {
          _notifications = cached['notifications'];
          _unreadCount = cached['unread_count'];
          _notificationsLoaded = true;
        });
        print('✅ [NOTIFICATIONS] Loaded ${_notifications.length} from persistent cache');
      }
    }
    
    // Skip API call if already loaded and not forcing refresh
    if (_notificationsLoaded && !forceRefresh) return;
    
    setState(() => _notificationsLoading = true);

    try {
      print('🔍 [NOTIFICATIONS] Loading notifications from API...');
      final result = await _notificationService.getNotifications();
      
      print('🔍 [NOTIFICATIONS] Result: ${result['success']}');
      print('🔍 [NOTIFICATIONS] Notifications count: ${result['notifications']?.length ?? 0}');
      print('🔍 [NOTIFICATIONS] Unread count: ${result['unread_count']}');
      
      if (result['success'] == true && mounted) {
        final notifications = List<Map<String, dynamic>>.from(result['notifications'] ?? []);
        final unreadCount = result['unread_count'] ?? 0;
        
        // Save to persistent cache
        await CacheService.saveNotifications(notifications, unreadCount);
        
        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
          _notificationsLoaded = true;
        });
        
        print('✅ [NOTIFICATIONS] Loaded ${_notifications.length} notifications and saved to cache');
      } else {
        print('❌ [NOTIFICATIONS] Error: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error'] ?? 'Failed to load notifications'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [NOTIFICATIONS] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _notificationsLoading = false);
      }
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      final result = await _notificationService.markAsRead(notificationId);
      
      if (result['success'] == true) {
        _loadNotifications(forceRefresh: true); // Refresh list
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      final result = await _notificationService.markAllAsRead();
      
      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
        _loadNotifications(forceRefresh: true); // Refresh list
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: const Color(0xFF1A1A2E),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Notification badge
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: const Color(0xFF1A1A2E)),
            onPressed: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: const Color(0xFF1A1A2E)),
            onPressed: _logout,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(Icons.location_city_outlined, Icons.location_city, 'Sites'),
      _NavItem(Icons.notifications_outlined, Icons.notifications, 'Alerts'),
      _NavItem(Icons.report_problem_outlined, Icons.report_problem, 'Issues'),
      _NavItem(Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedIndex == i;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedIndex = i;
                  _loadData();
                }),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? 18 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected ? LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge dot for Alerts tab
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        color: selected ? Colors.white : const Color(0xFF6B7280),
                        size: 22,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Site Management';
      case 1:
        return 'Notifications';
      case 2:
        return 'Client Issues';
      case 3:
        return 'Profile';
      default:
        return 'Admin Dashboard';
    }
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildSitesTab(),
        _buildNotificationsTab(),
        const AdminClientComplaintsScreen(),
        _buildProfileTab(),
      ],
    );
  }

  Future<void> _loadAreas() async {
    setState(() => _sitesLoading = true);
    try {
      final token = await _authService.getToken();
      print('🔍 Loading areas from: $_sitesBaseUrl/construction/areas/');
      final res = await http.get(
        Uri.parse('$_sitesBaseUrl/construction/areas/'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      print('🔍 Areas response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        print('🔍 Areas data: $data');
        if (mounted) {
          setState(() {
            _areas = List<String>.from(data['areas'] ?? []);
          });
        }
        print('🔍 Loaded ${_areas.length} areas');
      } else {
        print('❌ Failed to load areas: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      print('❌ Error loading areas: $e');
    }
    if (mounted) setState(() => _sitesLoading = false);
  }

  Future<void> _loadStreets(String area) async {
    // Always clear sites and selected street when area changes
    setState(() {
      _sites = [];
      _selectedStreet = null;
    });
    
    // Check cache first
    if (_streetsCache.containsKey(area)) {
      setState(() {
        _streets = _streetsCache[area]!;
      });
      return;
    }
    
    setState(() {
      _sitesLoading = true;
      _streets = [];
    });
    try {
      final token = await _authService.getToken();
      final res = await http.get(
        Uri.parse('$_sitesBaseUrl/construction/streets/${Uri.encodeComponent(area)}/'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final streets = List<String>.from(data['streets'] ?? []);
        // Cache the streets
        _streetsCache[area] = streets;
        if (mounted) {
          setState(() {
            _streets = streets;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading streets: $e');
    }
    if (mounted) setState(() => _sitesLoading = false);
  }

  Future<void> _loadSites(String area, String street) async {
    // Create cache key
    final cacheKey = '$area|$street';
    
    // Check cache first
    if (_sitesCache.containsKey(cacheKey)) {
      setState(() {
        _sites = _sitesCache[cacheKey]!;
      });
      return;
    }
    
    setState(() {
      _sitesLoading = true;
      _sites = [];
    });
    try {
      final token = await _authService.getToken();
      final res = await http.get(
        Uri.parse(
            '$_sitesBaseUrl/construction/sites/?area=${Uri.encodeComponent(area)}&street=${Uri.encodeComponent(street)}'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final sites = List<Map<String, dynamic>>.from(data['sites'] ?? []);
        // Cache the sites
        _sitesCache[cacheKey] = sites;
        if (mounted) {
          setState(() {
            _sites = sites;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading sites: $e');
    }
    if (mounted) setState(() => _sitesLoading = false);
  }

  Widget _buildSitesTab() {
    return Column(
      children: [
        // Global Labour Rates card
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              SmoothPageRoute(
                  page: const AdminLabourRatesScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.currency_rupee,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Labour Rates',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text('Set default rates for all labour types',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
        ),
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Site Budget Management',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 12),
              // Area dropdown
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: InputDecoration(
                  labelText: 'Select Area',
                  prefixIcon: const Icon(Icons.location_city,
                      color: const Color(0xFF1A1A2E), size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                items: _areas
                    .map((a) =>
                        DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedArea = val);
                    _loadStreets(val);
                  }
                },
                hint: const Text('Choose area'),
              ),
              if (_streets.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedStreet,
                  decoration: InputDecoration(
                    labelText: 'Select Street',
                    prefixIcon: const Icon(Icons.streetview,
                        color: const Color(0xFF1A1A2E), size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: _streets
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null && _selectedArea != null) {
                      setState(() => _selectedStreet = val);
                      _loadSites(_selectedArea!, val);
                    }
                  },
                  hint: const Text('Choose street'),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        // Site list
        Expanded(
          child: _sitesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: const Color(0xFF1A1A2E)))
              : _selectedArea == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 60,
                              color:
                                  const Color(0xFF6B7280).withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('Select an area to view sites',
                              style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 14)),
                        ],
                      ),
                    )
                  : _selectedStreet == null
                      ? Center(
                          child: Text('Select a street to view sites',
                              style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 14)),
                        )
                      : _sites.isEmpty
                          ? Center(
                              child: Text('No sites found',
                                  style: TextStyle(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 14)),
                            )
                          : ListView.builder(
                              physics: const SmoothScrollPhysics(),
                              padding: const EdgeInsets.all(14),
                              itemCount: _sites.length,
                              itemBuilder: (context, i) {
                                final site = _sites[i];
                                final siteId =
                                    site['id']?.toString() ?? '';
                                final siteName =
                                    site['display_name'] ?? site['site_name'] ?? 'Site ${i + 1}';
                                return AnimatedListItem(
                                  index: i,
                                  child: _buildSiteManagementCard(
                                      siteId, siteName),
                                );
                              },
                            ),
        ),
      ],
    );
  }

  Widget _buildSiteManagementCard(String siteId, String siteName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Site name header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.apartment,
                      color: const Color(0xFF1A1A2E), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    siteName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E)),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildSiteActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Budget Management',
              color: const Color(0xFF1A1A2E),
              onTap: () => Navigator.push(
                context,
                SmoothPageRoute(
                  page: AdminBudgetManagementScreen(
                    siteId: siteId,
                    siteName: siteName,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(forceRefresh: true),
      color: const Color(0xFF1A1A2E),
      child: _notificationsLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
            )
          : _notifications.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Work Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Notifications for work not done\nwill appear here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _loadNotifications(forceRefresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Notifications'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A2E),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header with actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadNotifications(forceRefresh: true),
                tooltip: 'Refresh',
              ),
              if (_unreadCount > 0)
                TextButton.icon(
                  onPressed: _markAllNotificationsAsRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all read'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A2E),
                  ),
                ),
            ],
          ),
        ),
                    // Notifications list
                    Expanded(
                      child: ListView.builder(
                        physics: const SmoothScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return AnimatedListItem(
                            index: index,
                            child: _buildNotificationCard(notification),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] == true;
    final message = notification['message'] ?? 'No message';
    final createdAt = notification['created_at'] ?? '';
    final siteName = notification['site_name'] ?? 'Unknown Site';
    final supervisorName = notification['supervisor_name'] ?? 'Unknown Supervisor';
    final entryType = notification['entry_type'] ?? '';
    final actualTime = notification['actual_time'] ?? '';
    
    // Parse entry type for display
    String entryTypeDisplay = '';
    IconData entryIcon = Icons.warning;
    Color entryColor = Colors.orange;
    
    switch (entryType) {
      case 'labour':
        entryTypeDisplay = 'Labour Entry';
        entryIcon = Icons.people;
        entryColor = Colors.blue;
        break;
      case 'material':
        entryTypeDisplay = 'Material Balance';
        entryIcon = Icons.inventory_2;
        entryColor = Colors.green;
        break;
      case 'morning_photo':
        entryTypeDisplay = 'Morning Photo';
        entryIcon = Icons.wb_sunny;
        entryColor = Colors.amber;
        break;
      case 'evening_photo':
        entryTypeDisplay = 'Evening Photo';
        entryIcon = Icons.nights_stay;
        entryColor = Colors.indigo;
        break;
      default:
        entryTypeDisplay = 'Late Entry';
        entryIcon = Icons.access_time;
        entryColor = Colors.red;
    }

    // Parse timestamp
    String timeAgo = '';
    try {
      final timestamp = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      if (difference.inMinutes < 1) {
        timeAgo = 'Just now';
      } else if (difference.inMinutes < 60) {
        timeAgo = '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        timeAgo = '${difference.inHours}h ago';
      } else {
        timeAgo = '${difference.inDays}d ago';
      }
    } catch (e) {
      timeAgo = createdAt;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 0 : 2,
      color: isRead ? const Color(0xFFF8F9FA) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? Colors.transparent : entryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markNotificationAsRead(notification['id'].toString());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: entryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      entryIcon,
                      color: entryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entryTypeDisplay,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: entryColor,
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      siteName,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      supervisorName,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              if (actualTime.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Submitted at: $actualTime',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE TAB
  // ============================================================

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Avatar + name ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _profileName.isNotEmpty
                          ? _profileName.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _profileName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileInfoRow(Icons.email_outlined,
                    _currentAdminUser?['email'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildProfileInfoRow(Icons.phone_outlined,
                    _profilePhone.isNotEmpty ? _profilePhone : 'N/A'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Account Settings ──
          _buildSectionHeader('Account'),
          _buildProfileActionTile(
            icon: Icons.edit_outlined,
            color: const Color(0xFF1A1A2E),
            title: 'Edit Profile',
            subtitle: 'Update name and phone',
            onTap: _showEditProfileDialog,
          ),

          const SizedBox(height: 20),

          // ── Management ──
          _buildSectionHeader('Management'),
          _buildProfileActionTile(
            icon: Icons.people_outline,
            color: const Color(0xFF4CAF50),
            title: 'Manage Users',
            subtitle: 'View all users and pending requests',
            onTap: _showManageUsersScreen,
          ),
          _buildProfileActionTile(
            icon: Icons.add_location_alt_outlined,
            color: const Color(0xFF1A1A2E),
            title: 'Create Site',
            subtitle: 'Add new area, street, and site',
            onTap: _showCreateSiteDialog,
          ),
          _buildProfileActionTile(
            icon: Icons.person_add_outlined,
            color: const Color(0xFF2196F3),
            title: 'Create User',
            subtitle: 'Add Supervisor, Engineer, Accountant etc.',
            onTap: _showCreateUserDialog,
          ),
          _buildProfileActionTile(
            icon: Icons.admin_panel_settings_outlined,
            color: const Color(0xFF1A1A2E),
            title: 'Create Admin',
            subtitle: 'Add another admin account',
            onTap: _showCreateAdminDialog,
          ),
          _buildProfileActionTile(
            icon: Icons.badge_outlined,
            color: const Color(0xFF9C27B0),
            title: 'Create Role',
            subtitle: 'Add a new custom role',
            onTap: _showCreateRoleDialog,
          ),

          const SizedBox(height: 20),

          // ── Logout ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(value,
            style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildProfileActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: const Color(0xFF6B7280))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: const Color(0xFF6B7280), size: 16),
          ],
        ),
      ),
    );
  }

  // ── Edit Profile ──────────────────────────────────────────

  Future<void> _showEditProfileDialog() async {
    final nameCtrl = TextEditingController(text: _profileName);
    final phoneCtrl = TextEditingController(text: _profilePhone);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Profile',
              style: TextStyle(
                  color: const Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline,
                        color: const Color(0xFF1A1A2E)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: const Color(0xFF1A1A2E), width: 2),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    counterText: '',
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: const Color(0xFF1A1A2E)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: const Color(0xFF1A1A2E), width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Phone is required';
                    if (v.trim().length != 10)
                      return 'Must be exactly 10 digits';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDS(() => isSaving = true);
                      final newName = nameCtrl.text.trim();
                      final newPhone = phoneCtrl.text.trim();
                      final result = await ConstructionService().updateProfile(
                          fullName: newName, phone: newPhone);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (result['success'] == true) {
                        setState(() {
                          _profileName =
                              newName.isNotEmpty ? newName : _profileName;
                          _profilePhone =
                              newPhone.isNotEmpty ? newPhone : _profilePhone;
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(result['success'] == true
                            ? 'Profile updated!'
                            : result['error'] ?? 'Update failed'),
                        backgroundColor: result['success'] == true
                            ? const Color(0xFF4CAF50)
                            : Colors.red,
                      ));
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  // ── Manage Users ──────────────────────────────────────────

  void _showManageUsersScreen() {
    Navigator.push(
      context,
      SmoothPageRoute(
        page: const AdminManageUsersScreen(),
      ),
    );
  }

  // ── Create Site ───────────────────────────────────────────

  Future<void> _showCreateSiteDialog() async {
    final areaCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final siteNameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Site',
              style: TextStyle(
                  color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogField(areaCtrl, 'Area', Icons.location_city,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(streetCtrl, 'Street', Icons.streetview,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(siteNameCtrl, 'Site Name', Icons.apartment,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDS(() => isSaving = true);
                      
                      try {
                        final token = await _authService.getToken();
                        final response = await http.post(
                          Uri.parse('$_sitesBaseUrl/construction/sites/create/'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${token ?? ''}',
                          },
                          body: json.encode({
                            'area': areaCtrl.text.trim(),
                            'street': streetCtrl.text.trim(),
                            'site_name': siteNameCtrl.text.trim(),
                          }),
                        );

                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);

                        if (response.statusCode == 201) {
                          // Clear sites cache to force refresh
                          await CacheService.clearSites();
                          _loadAreas(); // Refresh areas
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Site created successfully!'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        } else {
                          final error = json.decode(response.body);
                          throw Exception(error['error'] ?? 'Failed to create site');
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
    areaCtrl.dispose();
    streetCtrl.dispose();
    siteNameCtrl.dispose();
  }

  // ── Create User ───────────────────────────────────────────

  Future<void> _showCreateUserDialog() async {
    final nameCtrl     = TextEditingController();
    final usernameCtrl = TextEditingController();
    final emailCtrl    = TextEditingController();
    final phoneCtrl    = TextEditingController();
    final passCtrl     = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedRole;
    List<String> roles = [];
    List<Map<String, dynamic>> allSites = [];
    Set<String> selectedSiteIds = {};
    bool isSaving = false;
    bool loadingRoles = true;
    bool loadingSites = false;

    // Load roles
    try {
      final token = await _authService.getToken();
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/roles/'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        roles = List<Map<String, dynamic>>.from(data['roles'])
            .map((r) => r['role_name'] as String)
            .where((r) => r != 'Admin')
            .toList();
      }
    } catch (_) {}

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) {
          if (loadingRoles) {
            loadingRoles = false;
            if (roles.isNotEmpty) selectedRole = roles.first;
          }
          
          // Check if Client role is selected
          final isClientRole = selectedRole?.toLowerCase() == 'client';
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Create User',
                style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogField(nameCtrl, 'Full Name', Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(usernameCtrl, 'Username', Icons.alternate_email,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(emailCtrl, 'Email', Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Valid email required'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(phoneCtrl, 'Phone', Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) => (v == null || v.trim().length != 10)
                            ? '10 digits required'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(passCtrl, 'Password', Icons.lock_outline,
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.length < 6)
                                ? 'Min 6 characters'
                                : null),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: roles
                          .map((r) => DropdownMenuItem(
                              value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) async {
                        print('🎯 ROLE CHANGED TO: $v');
                        setDS(() => selectedRole = v);
                        
                        // Load sites if Client role is selected
                        final isClient = v?.toLowerCase() == 'client';
                        print('🎯 Is client role: $isClient');
                        print('🎯 All sites count: ${allSites.length}');
                        print('🎯 Loading sites: $loadingSites');
                        
                        if (isClient && allSites.isEmpty) {
                          print('🎯 Starting to load sites...');
                          setDS(() => loadingSites = true);
                          try {
                            final token = await _authService.getToken();
                            final url = '${AuthService.baseUrl}/construction/all-sites/';
                            print('🎯 Fetching from: $url');
                            
                            final res = await http.get(
                              Uri.parse(url),
                              headers: {
                                'Authorization': 'Bearer ${token ?? ''}',
                                'Content-Type': 'application/json',
                              },
                            );
                            
                            print('🎯 Response: ${res.statusCode}');
                            
                            if (res.statusCode == 200) {
                              final data = json.decode(res.body);
                              final sites = List<Map<String, dynamic>>.from(data['sites'] ?? []);
                              print('🎯 ✅ Loaded ${sites.length} sites');
                              
                              setDS(() {
                                allSites = sites;
                                loadingSites = false;
                              });
                              print('🎯 State updated - allSites now has ${allSites.length} items');
                            } else {
                              print('🎯 ❌ Failed: ${res.statusCode}');
                              setDS(() => loadingSites = false);
                            }
                          } catch (e) {
                            print('🎯 ❌ Error: $e');
                            setDS(() => loadingSites = false);
                          }
                        }
                      },
                      validator: (v) =>
                          v == null ? 'Select a role' : null,
                    ),
                    
                    // Show site selection for Client role
                    if (isClientRole) ...[
                      Builder(
                        builder: (context) {
                          print('🎯 RENDERING SITE SELECTION UI');
                          print('🎯 isClientRole: $isClientRole');
                          print('🎯 loadingSites: $loadingSites');
                          print('🎯 allSites.length: ${allSites.length}');
                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_city, color: Color(0xFF2196F3), size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Assign Site(s)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Client will only see assigned site(s)',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              
                              if (loadingSites)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (allSites.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No sites available', style: TextStyle(color: Colors.grey)),
                                )
                              else
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: allSites.length,
                                    itemBuilder: (context, index) {
                                      final site = allSites[index];
                                      final siteId = site['id'].toString();
                                      final isSelected = selectedSiteIds.contains(siteId);
                                      
                                      return CheckboxListTile(
                                        dense: true,
                                        value: isSelected,
                                        onChanged: (value) {
                                          setDS(() {
                                            if (value == true) {
                                              selectedSiteIds.add(siteId);
                                            } else {
                                              selectedSiteIds.remove(siteId);
                                            }
                                          });
                                        },
                                        title: Text(
                                          site['display_name'] ?? site['site_name'] ?? 'Site',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        controlAffinity: ListTileControlAffinity.leading,
                                      );
                                    },
                                  ),
                                ),
                              
                              if (isClientRole && selectedSiteIds.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '⚠️ Please select at least one site',
                                    style: TextStyle(color: Colors.orange, fontSize: 12),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ), // Column
              ), // Form
            ), // SingleChildScrollView
            ), // SizedBox
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style:
                        TextStyle(color: const Color(0xFF6B7280))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        
                        // Validate site selection for Client role
                        if (isClientRole && selectedSiteIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one site for the client'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        
                        setDS(() => isSaving = true);
                        try {
                          final token = await _authService.getToken();
                          final Map<String, dynamic> body = {
                            'full_name': nameCtrl.text.trim(),
                            'username': usernameCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'password': passCtrl.text,
                            'role': selectedRole,
                          };
                          
                          // Add site_ids for Client role
                          if (isClientRole) {
                            body['site_ids'] = selectedSiteIds.toList();
                          }
                          
                          final res = await http.post(
                            Uri.parse(
                                '${AuthService.baseUrl}/admin/create-user/'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer ${token ?? ''}',
                            },
                            body: json.encode(body),
                          );
                          
                          final data = json.decode(res.body);
                          final success = res.statusCode == 201;
                          final message = success 
                              ? (data['message'] ?? 'User created!')
                              : (data['error'] ?? 'Failed');
                          
                          if (!ctx.mounted) return;
                          
                          // Close dialog first
                          Navigator.pop(ctx);
                          
                          // Then show snackbar
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(success ? '✅ $message' : '❌ $message'),
                              backgroundColor: success
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red,
                            ));
                          }
                        } catch (e) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
    nameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
  }

  // ── Create Admin ──────────────────────────────────────────

  Future<void> _showCreateAdminDialog() async {
    final nameCtrl     = TextEditingController();
    final usernameCtrl = TextEditingController();
    final emailCtrl    = TextEditingController();
    final phoneCtrl    = TextEditingController();
    final passCtrl     = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Admin',
              style: TextStyle(
                  color: const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl, 'Full Name', Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null),
                  const SizedBox(height: 12),
                  _dialogField(
                      usernameCtrl, 'Username', Icons.alternate_email,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null),
                  const SizedBox(height: 12),
                  _dialogField(emailCtrl, 'Email', Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Valid email required'
                          : null),
                  const SizedBox(height: 12),
                  _dialogField(phoneCtrl, 'Phone', Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) =>
                          (v == null || v.trim().length != 10)
                              ? '10 digits required'
                              : null),
                  const SizedBox(height: 12),
                  _dialogField(passCtrl, 'Password', Icons.lock_outline,
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.length < 6)
                              ? 'Min 6 characters'
                              : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDS(() => isSaving = true);
                      try {
                        final token = await _authService.getToken();
                        final res = await http.post(
                          Uri.parse(
                              '${AuthService.baseUrl}/admin/create-admin/'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${token ?? ''}',
                          },
                          body: json.encode({
                            'full_name': nameCtrl.text.trim(),
                            'username': usernameCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'password': passCtrl.text,
                          }),
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        final data = json.decode(res.body);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(res.statusCode == 201
                              ? data['message'] ?? 'Admin created!'
                              : data['error'] ?? 'Failed'),
                          backgroundColor: res.statusCode == 201
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                        ));
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
  }

  // ── Create Role ───────────────────────────────────────────

  Future<void> _showCreateRoleDialog() async {
    final roleCtrl = TextEditingController();
    final formKey  = GlobalKey<FormState>();
    bool isSaving  = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Role',
              style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: roleCtrl,
              decoration: InputDecoration(
                labelText: 'Role Name',
                hintText: 'e.g. Quality Inspector',
                prefixIcon: const Icon(Icons.badge_outlined,
                    color: Color(0xFF9C27B0)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF9C27B0), width: 2),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Role name is required'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDS(() => isSaving = true);
                      try {
                        final token = await _authService.getToken();
                        final res = await http.post(
                          Uri.parse(
                              '${AuthService.baseUrl}/admin/create-role/'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${token ?? ''}',
                          },
                          body: json.encode(
                              {'role_name': roleCtrl.text.trim()}),
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        final data = json.decode(res.body);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(res.statusCode == 201
                              ? data['message'] ?? 'Role created!'
                              : data['error'] ?? 'Failed'),
                          backgroundColor: res.statusCode == 201
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                        ));
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
    roleCtrl.dispose();
  }

  // ── Shared dialog field builder ───────────────────────────

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        counterText: maxLength != null ? '' : null,
        prefixIcon: Icon(icon, color: const Color(0xFF1A1A2E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: const Color(0xFF1A1A2E), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: validator,
    );
  }

  // Removed unused user card methods - Users tab removed from bottom navigation
  // User management now accessed via Profile → Manage Users button
  // Methods removed: _buildPendingUserCard, _buildExistingUserCard, 
  // _buildInstagramDetailRow, _buildActionPillButton, _formatDate

  // Removed user management dialog methods - use Manage Users screen instead
  // void _showApproveDialog(...) { ... }
  // void _showRejectDialog(...) { ... }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
