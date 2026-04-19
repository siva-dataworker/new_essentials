import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../utils/smooth_animations.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late TabController _tabController;
  
  // Background refresh timer
  Timer? _refreshTimer;

  // New Users (Pending) state
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoadingPending = false;
  bool _pendingLoaded = false;

  // All Users state
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingAll = false;
  bool _allLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0 && !_pendingLoaded) {
          _loadPendingUsers();
        } else if (_tabController.index == 1 && !_allLoaded) {
          _loadAllUsers();
        }
      }
    });
    _loadPendingUsers();
    _startBackgroundRefresh();
  }

  @override
  void dispose() {
    _stopBackgroundRefresh();
    _tabController.dispose();
    super.dispose();
  }

  void _startBackgroundRefresh() {
    // Refresh every 60 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        if (mounted) {
          if (_tabController.index == 0) {
            _loadPendingUsers(forceRefresh: true);
          } else {
            _loadAllUsers(forceRefresh: true);
          }
        }
      },
    );
  }

  void _stopBackgroundRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> _loadPendingUsers({bool forceRefresh = false}) async {
    // Load from persistent cache first
    if (!forceRefresh && !_pendingLoaded) {
      final cached = await CacheService.loadPendingUsers();
      if (cached != null && mounted) {
        setState(() {
          _pendingUsers = cached;
          _pendingLoaded = true;
        });
        print('✅ [USERS] Loaded ${_pendingUsers.length} pending users from cache');
      }
    }

    // Skip if already loaded and not forcing refresh
    if (_pendingLoaded && !forceRefresh) return;

    setState(() => _isLoadingPending = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('https://new-essentials.onrender.com/api/admin/pending-users/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = List<Map<String, dynamic>>.from(data['users']);
        
        // Save to persistent cache
        await CacheService.savePendingUsers(users);
        
        if (mounted) {
          setState(() {
            _pendingUsers = users;
            _pendingLoaded = true;
          });
        }
        print('✅ [USERS] Loaded ${_pendingUsers.length} pending users from API');
      }
    } catch (e) {
      print('Error loading pending users: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPending = false);
      }
    }
  }

  Future<void> _loadAllUsers({bool forceRefresh = false}) async {
    // Load from persistent cache first
    if (!forceRefresh && !_allLoaded) {
      final cached = await CacheService.loadAllUsers();
      if (cached != null && mounted) {
        setState(() {
          _allUsers = cached;
          _allLoaded = true;
        });
        print('✅ [USERS] Loaded ${_allUsers.length} all users from cache');
      }
    }

    // Skip if already loaded and not forcing refresh
    if (_allLoaded && !forceRefresh) return;

    setState(() => _isLoadingAll = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('https://new-essentials.onrender.com/api/admin/all-users/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = List<Map<String, dynamic>>.from(data['users']);
        
        // Save to persistent cache
        await CacheService.saveAllUsers(users);
        
        if (mounted) {
          setState(() {
            _allUsers = users;
            _allLoaded = true;
          });
        }
        print('✅ [USERS] Loaded ${_allUsers.length} all users from API');
      }
    } catch (e) {
      print('Error loading all users: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAll = false);
      }
    }
  }

  Future<void> _approveUser(String userId, String username) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('https://new-essentials.onrender.com/api/admin/approve-user/$userId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $username approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingUsers(forceRefresh: true);
        _loadAllUsers(forceRefresh: true);
      } else {
        throw Exception('Failed to approve user');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(String userId, String username) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('https://new-essentials.onrender.com/api/admin/reject-user/$userId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $username rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadPendingUsers(forceRefresh: true);
      } else {
        throw Exception('Failed to reject user');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4CAF50),
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: const Color(0xFF6B7280),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New Users'),
                  if (_pendingUsers.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingUsers.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'All Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewUsersTab(),
          _buildAllUsersTab(),
        ],
      ),
    );
  }

  Widget _buildNewUsersTab() {
    return RefreshIndicator(
      onRefresh: () => _loadPendingUsers(forceRefresh: true),
      color: const Color(0xFF4CAF50),
      child: _isLoadingPending && _pendingUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? _buildEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'All Caught Up!',
                  subtitle: 'No pending user approvals',
                )
              : ListView.builder(
                  physics: const SmoothScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    return AnimatedListItem(
                      index: index,
                      child: _buildPendingUserCard(user),
                    );
                  },
                ),
    );
  }

  Widget _buildAllUsersTab() {
    return RefreshIndicator(
      onRefresh: () => _loadAllUsers(forceRefresh: true),
      color: const Color(0xFF4CAF50),
      child: _isLoadingAll && _allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _allUsers.isEmpty
              ? _buildEmptyState(
                  icon: Icons.people_outline,
                  title: 'No Users Found',
                  subtitle: 'No users in the system',
                )
              : ListView.builder(
                  physics: const SmoothScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                  itemCount: _allUsers.length,
                  itemBuilder: (context, index) {
                    final user = _allUsers[index];
                    return AnimatedListItem(
                      index: index,
                      child: _buildUserCard(user),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingUserCard(Map<String, dynamic> user) {
    final userId = user['id']?.toString() ?? '';
    final username = user['username'] ?? 'Unknown';
    final fullName = user['full_name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';
    final phone = user['phone'] ?? 'N/A';
    final role = user['role'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@$username',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.email_outlined, email),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone_outlined, phone),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveUser(userId, username),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectUser(userId, username),
                        icon: const Icon(Icons.cancel, size: 20),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final username = user['username'] ?? 'Unknown';
    final fullName = user['full_name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';
    final phone = user['phone'] ?? 'N/A';
    final role = user['role'] ?? 'N/A';
    final isActive = user['is_active'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('@$username', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(phone, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                role,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }
}
