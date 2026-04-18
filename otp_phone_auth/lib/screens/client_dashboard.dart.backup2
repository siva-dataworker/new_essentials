import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final _authService = AuthService();
  final _constructionService = ConstructionService();
  
  int _selectedIndex = 0;
  Map<String, dynamic>? _siteData;
  Map<String, dynamic>? _materialsData;
  Map<String, dynamic>? _photosData;
  bool _isLoading = true;
  String? _userName;
  String? _currentSiteId;
  String? _selectedDate; // For photo date filter

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSiteData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _userName = user?['full_name'] ?? 'Client';
    });
  }

  Future<void> _loadSiteData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _constructionService.getClientSiteDetails();
      final sites = response['sites'] as List? ?? [];
      
      setState(() {
        _siteData = response;
        _currentSiteId = sites.isNotEmpty ? sites[0]['site_id'] : null;
        _isLoading = false;
      });

      // Load materials and photos if site exists
      if (_currentSiteId != null) {
        _loadMaterials();
        // Load photos filtered to today's date by default
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        _loadPhotos(filterDate: todayStr);
      }
    } catch (e) {
      print('Error loading site data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMaterials() async {
    if (_currentSiteId == null) return;
    
    try {
      final response = await _constructionService.getClientMaterials(_currentSiteId!);
      setState(() {
        _materialsData = response;
      });
    } catch (e) {
      print('Error loading materials: $e');
    }
  }

  Future<void> _loadPhotos({String? filterDate}) async {
    if (_currentSiteId == null) return;
    
    try {
      final response = await _constructionService.getClientPhotosByDate(
        siteId: _currentSiteId!,
        filterDate: filterDate,
      );
      setState(() {
        _photosData = response;
        _selectedDate = filterDate;
      });
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.deepNavy))
          : _buildContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return ClientProgressTab(
          siteData: _siteData,
          photosData: _photosData,
          selectedDate: _selectedDate,
          onRefresh: _loadSiteData,
          onDateFilter: _loadPhotos,
        );
      case 1:
        return ClientMaterialsTab(
          materialsData: _materialsData,
          onRefresh: _loadMaterials,
        );
      case 2:
        return ClientDesignsTab(siteData: _siteData, onRefresh: _loadSiteData);
      case 3:
        return ClientIssuesTab(siteData: _siteData, onRefresh: _loadSiteData);
      case 4:
        return ClientProfileTab(
          userName: _userName,
          siteId: _currentSiteId,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.timeline, 'Progress', 0),
              _buildNavItem(Icons.inventory_2, 'Materials', 1),
              _buildNavItem(Icons.architecture, 'Designs', 2),
              _buildNavItem(Icons.report_problem, 'Issues', 3),
              _buildNavItem(Icons.person, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepNavy.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.deepNavy : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.deepNavy : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Progress Tab - Timeline with photos
class ClientProgressTab extends StatelessWidget {
  final Map<String, dynamic>? siteData;
  final Map<String, dynamic>? photosData;
  final String? selectedDate;
  final VoidCallback onRefresh;
  final void Function({String? filterDate}) onDateFilter;

  const ClientProgressTab({
    super.key,
    required this.siteData,
    required this.photosData,
    required this.selectedDate,
    required this.onRefresh,
    required this.onDateFilter,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.deepNavy,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.deepNavy,
            title: const Text('Project Progress', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRefresh,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSiteInfo(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Timeline',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      _buildDateFilter(context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // Determine display text
    String displayText;
    if (selectedDate == null) {
      displayText = 'All Dates';
    } else if (selectedDate == todayStr) {
      displayText = 'Today';
    } else {
      // Check if yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      if (selectedDate == yesterdayStr) {
        displayText = 'Yesterday';
      } else {
        displayText = _formatDateShort(selectedDate!);
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.deepNavy,
                ),
                const SizedBox(width: 6),
                Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null 
          ? DateTime.parse(selectedDate!) 
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final pickedStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      onDateFilter(filterDate: pickedStr);
    }
  }


  Widget _buildSiteInfo() {
    final sites = siteData?['sites'] as List? ?? [];
    if (sites.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No site assigned', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final site = sites[0];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepNavy, AppColors.deepNavy.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_work, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site['site_name'] ?? 'Project',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${site['area']} • ${site['street']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    // Use photosData if available, otherwise fall back to siteData
    final Map<String, List<dynamic>> photosByDate;
    
    if (photosData != null && photosData!['photos_by_date'] != null) {
      // Using new API with photos grouped by date
      final photosMap = Map<String, dynamic>.from(photosData!['photos_by_date'] as Map);
      photosByDate = photosMap.map((key, value) => MapEntry(key, List<dynamic>.from(value as List)));
    } else {
      // Fallback to old structure from siteData
      final sites = siteData?['sites'] as List? ?? [];
      if (sites.isEmpty) {
        return _buildEmptyState();
      }
      
      final photos = sites[0]['photos'] as List? ?? [];
      if (photos.isEmpty) {
        return _buildEmptyState();
      }
      
      // Group photos by date manually
      photosByDate = {};
      for (final photo in photos) {
        final date = photo['uploaded_date'] ?? '';
        if (!photosByDate.containsKey(date)) {
          photosByDate[date] = [];
        }
        photosByDate[date]!.add(photo);
      }
    }

    if (photosByDate.isEmpty) {
      return _buildEmptyState();
    }

    final sortedDates = photosByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedDates.map((date) {
        final dayPhotos = photosByDate[date]!;
        final morning = dayPhotos.where((p) => (p['time_of_day'] as String? ?? '').toLowerCase() == 'morning').toList();
        final evening = dayPhotos.where((p) => (p['time_of_day'] as String? ?? '').toLowerCase() == 'evening').toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.deepNavy),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusCompleted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayPhotos.length} ${dayPhotos.length == 1 ? 'photo' : 'photos'}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPhotoCard(context, 'Morning', morning.isNotEmpty ? morning[0] : null),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPhotoCard(context, 'Evening', evening.isNotEmpty ? evening[0] : null),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No photos yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, String label, Map<String, dynamic>? photo) {
    return GestureDetector(
      onTap: photo != null ? () => _showFullscreenImage(context, photo) : null,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.lightSlate,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
        ),
        child: photo != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      ConstructionService.getFullImageUrl(photo['photo_url']),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (photo['uploaded_by_role'] != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                photo['uploaded_by_role'] == 'Supervisor' 
                                    ? Icons.person 
                                    : Icons.engineering,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${photo['uploaded_by']} (${photo['uploaded_by_role']})',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera, size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No $label photo',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, Map<String, dynamic> photo) {
    final imageUrl = ConstructionService.getFullImageUrl(photo['photo_url']);
    final uploadedBy = photo['uploaded_by'] as String? ?? 'Unknown';
    final role = photo['uploaded_by_role'] as String? ?? '';
    final timeOfDay = photo['time_of_day'] as String? ?? '';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeOfDay,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '$uploadedBy${role.isNotEmpty ? ' ($role)' : ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateShort(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (e) {
      return date;
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final checkDate = DateTime(dt.year, dt.month, dt.day);

      if (checkDate == today) return 'Today';
      if (checkDate == yesterday) return 'Yesterday';
      
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (e) {
      return date;
    }
  }
}

// Materials Tab - Real API data
class ClientMaterialsTab extends StatelessWidget {
  final Map<String, dynamic>? materialsData;
  final VoidCallback onRefresh;

  const ClientMaterialsTab({
    super.key,
    required this.materialsData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final materials = materialsData?['materials'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.deepNavy,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.deepNavy,
            title: const Text('Materials', style: TextStyle(color: Colors.white)),
          ),
          materials.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No materials used yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final material = materials[index];
                        return _buildMaterialCard(material);
                      },
                      childCount: materials.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final materialType = material['material_type'] as String? ?? 'Unknown';
    final totalUsed = material['total_used'] as num? ?? 0;
    final unit = material['unit'] as String? ?? 'units';
    final usageCount = material['usage_count'] as int? ?? 0;
    final lastUsedDate = material['last_used_date'] as String? ?? '';

    // Icon mapping
    final iconMap = {
      'cement': Icons.construction,
      'sand': Icons.grain,
      'steel': Icons.hardware,
      'brick': Icons.view_module,
      'gravel': Icons.landscape,
    };
    
    final icon = iconMap[materialType.toLowerCase()] ?? Icons.inventory_2;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.deepNavy, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materialType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${totalUsed.toStringAsFixed(totalUsed % 1 == 0 ? 0 : 1)} $unit',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusCompleted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'used',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (lastUsedDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last used: $lastUsedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$usageCount ${usageCount == 1 ? 'entry' : 'entries'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Designs Tab - Real API data
class ClientDesignsTab extends StatelessWidget {
  final Map<String, dynamic>? siteData;
  final VoidCallback onRefresh;

  const ClientDesignsTab({
    super.key,
    required this.siteData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final sites = siteData?['sites'] as List? ?? [];
    final architectDocs = sites.isNotEmpty ? (sites[0]['architect_documents'] as List? ?? []) : [];
    final engineerDocs = sites.isNotEmpty ? (sites[0]['engineer_documents'] as List? ?? []) : [];
    final allDocuments = [...architectDocs, ...engineerDocs];

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.deepNavy,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.deepNavy,
            title: const Text('Designs & Plans', style: TextStyle(color: Colors.white)),
          ),
          allDocuments.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.architecture, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No designs uploaded yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = allDocuments[index];
                        return _buildDesignCard(context, doc);
                      },
                      childCount: allDocuments.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDesignCard(BuildContext context, Map<String, dynamic> doc) {
    final title = doc['title'] as String? ?? 'Document';
    final docType = doc['document_type'] as String? ?? 'Design';
    final uploadDate = doc['upload_date'] as String? ?? '';
    final documentUrl = doc['file_url'] as String? ?? '';

    return GestureDetector(
      onTap: () => _openDocument(context, documentUrl, title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightSlate,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(Icons.insert_drive_file, size: 48, color: Colors.grey[400]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    docType,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (uploadDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      uploadDate,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument(BuildContext context, String documentUrl, String title) async {
    if (documentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final fullUrl = ConstructionService.getFullImageUrl(documentUrl);
      final uri = Uri.parse(fullUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open document: $title'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Issues Tab - Client Complaints
class ClientIssuesTab extends StatefulWidget {
  final Map<String, dynamic>? siteData;
  final VoidCallback onRefresh;

  const ClientIssuesTab({
    super.key,
    required this.siteData,
    required this.onRefresh,
  });

  @override
  State<ClientIssuesTab> createState() => _ClientIssuesTabState();
}

class _ClientIssuesTabState extends State<ClientIssuesTab> {
  final _constructionService = ConstructionService();
  List<dynamic> _complaints = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final sites = widget.siteData?['sites'] as List? ?? [];
      if (sites.isEmpty) {
        if (mounted) {
          setState(() {
            _complaints = [];
            _isLoading = false;
          });
        }
        return;
      }
      
      final siteId = sites[0]['site_id'] as String;
      final response = await _constructionService.getClientComplaints(siteId: siteId);
      
      if (mounted) {
        setState(() {
          _complaints = response['complaints'] as List? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading complaints: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateComplaintDialog() {
    final sites = widget.siteData?['sites'] as List? ?? [];
    if (sites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No site assigned')),
      );
      return;
    }
    
    final siteId = sites[0]['site_id'] as String;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'MEDIUM';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report an Issue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Title *',
                    hintText: 'Brief description of the issue',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Detailed explanation (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'].map((priority) {
                    final isSelected = selectedPriority == priority;
                    return ChoiceChip(
                      label: Text(priority),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedPriority = priority;
                        });
                      },
                      selectedColor: _getPriorityColor(priority),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                
                // Show loading
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating complaint...')),
                  );
                }
                
                // Create complaint
                final response = await _constructionService.createClientComplaint(
                  siteId: siteId,
                  title: title,
                  description: descriptionController.text.trim(),
                  priority: selectedPriority,
                );
                
                if (!mounted) return;
                
                if (response['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue reported successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload complaints
                  await _loadComplaints();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: ${response['error'] ?? 'Unknown error'}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'LOW':
        return Colors.blue;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.deepOrange;
      case 'URGENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadComplaints();
        widget.onRefresh();
      },
      color: AppColors.deepNavy,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.deepNavy,
            title: const Text('Issues & Updates', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _showCreateComplaintDialog,
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_complaints.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report_problem, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'No issues reported',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to report an issue',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final complaint = _complaints[index];
                    return _buildComplaintCard(complaint);
                  },
                  childCount: _complaints.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final title = complaint['title'] as String? ?? 'Untitled';
    final description = complaint['description'] as String? ?? '';
    final status = complaint['status'] as String? ?? 'OPEN';
    final priority = complaint['priority'] as String? ?? 'MEDIUM';
    final createdAt = complaint['created_at'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priority,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty) ...[
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Status
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: _getStatusColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        'Status: ',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Created date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Reported: ${_formatDateTime(createdAt)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final checkDate = DateTime(dt.year, dt.month, dt.day);

      if (checkDate == today) {
        return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (checkDate == yesterday) {
        return 'Yesterday ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}

// Profile Tab
class ClientProfileTab extends StatefulWidget {
  final String? userName;
  final String? siteId;

  const ClientProfileTab({super.key, required this.userName, this.siteId});

  @override
  State<ClientProfileTab> createState() => _ClientProfileTabState();
}

class _ClientProfileTabState extends State<ClientProfileTab> {
  Map<String, dynamic>? _budgetAllocation;
  bool _isLoadingBudget = false;

  @override
  void initState() {
    super.initState();
    _loadBudgetAllocation();
  }

  @override
  void didUpdateWidget(ClientProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteId != widget.siteId) {
      _loadBudgetAllocation();
    }
  }

  Future<void> _loadBudgetAllocation() async {
    if (widget.siteId == null) return;
    
    setState(() => _isLoadingBudget = true);
    try {
      final response = await ConstructionService().getClientBudgetAllocation(widget.siteId!);
      if (mounted) {
        setState(() {
          _budgetAllocation = response;
          _isLoadingBudget = false;
        });
      }
    } catch (e) {
      print('Error loading budget allocation: $e');
      if (mounted) {
        setState(() => _isLoadingBudget = false);
      }
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    double value = amount is String ? double.tryParse(amount) ?? 0 : amount.toDouble();

    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(2)} K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.deepNavy,
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Profile Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 40, color: AppColors.deepNavy),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.userName ?? 'Client',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Project Owner',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                
                // Budget Allocation Section
                if (widget.siteId != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.deepNavy.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.deepNavy,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Budget Allocation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isLoadingBudget)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_budgetAllocation == null)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, 
                                    size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    'No budget allocated yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          _buildBudgetCard(
                            'Total Budget',
                            _formatCurrency(_budgetAllocation!['total_budget']),
                            Icons.account_balance_wallet,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          if (_budgetAllocation!['material_budget'] != null)
                            _buildBudgetCard(
                              'Material Budget',
                              _formatCurrency(_budgetAllocation!['material_budget']),
                              Icons.inventory_2,
                              Colors.brown,
                            ),
                          const SizedBox(height: 12),
                          if (_budgetAllocation!['labour_budget'] != null)
                            _buildBudgetCard(
                              'Labour Budget',
                              _formatCurrency(_budgetAllocation!['labour_budget']),
                              Icons.people,
                              AppColors.safetyOrange,
                            ),
                          const SizedBox(height: 12),
                          if (_budgetAllocation!['other_budget'] != null)
                            _buildBudgetCard(
                              'Other Budget',
                              _formatCurrency(_budgetAllocation!['other_budget']),
                              Icons.more_horiz,
                              Colors.purple,
                            ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildDetailRow('Status', _budgetAllocation!['status'] ?? 'N/A'),
                          _buildDetailRow('Allocated Date', 
                            _budgetAllocation!['allocated_date']?.substring(0, 10) ?? 'N/A'),
                          if (_budgetAllocation!['notes'] != null && 
                              _budgetAllocation!['notes'].toString().isNotEmpty)
                            _buildDetailRow('Notes', _budgetAllocation!['notes']),
                        ],
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await AuthService().logout();
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

