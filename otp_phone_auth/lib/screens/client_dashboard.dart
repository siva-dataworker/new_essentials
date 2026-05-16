import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
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
      await _constructionService.getClientMaterials(
        _currentSiteId!,
      );
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.deepNavy),
            )
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
        return ClientDesignsTab(siteData: _siteData, onRefresh: _loadSiteData);
      case 2:
        return ClientIssuesTab(siteData: _siteData, onRefresh: _loadSiteData);
      case 3:
        return ClientProfileTab(userName: _userName, siteId: _currentSiteId);
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
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.timeline, 'Progress', 0),
              _buildNavItem(Icons.architecture, 'Designs', 1),
              _buildNavItem(Icons.report_problem, 'Issues', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.deepNavy.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.deepNavy : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
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
            title: const Text(
              'Project Progress',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRefresh,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSiteInfo(),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Timeline',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      _buildDateFilter(context),
                    ],
                  ),
                  SizedBox(height: 16.h),
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
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Determine display text
    String displayText;
    if (selectedDate == null) {
      displayText = 'All Dates';
    } else if (selectedDate == todayStr) {
      displayText = 'Today';
    } else {
      // Check if yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      if (selectedDate == yesterdayStr) {
        displayText = 'Yesterday';
      } else {
        displayText = _formatDateShort(selectedDate!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: AppColors.deepNavy,
                ),
                SizedBox(width: 6.w),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 13.sp,
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
      final pickedStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      onDateFilter(filterDate: pickedStr);
    }
  }

  Widget _buildSiteInfo() {
    final sites = siteData?['sites'] as List? ?? [];
    if (sites.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: Text('No site assigned', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final site = sites[0];
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepNavy, AppColors.deepNavy.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.2),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.home_work, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site['site_name'] ?? 'Project',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${site['area']} • ${site['street']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    // Collect all photos into a flat list sorted newest first
    final List<Map<String, dynamic>> allPhotos = [];

    if (photosData != null && photosData!['photos_by_date'] != null) {
      final photosMap = Map<String, dynamic>.from(
        photosData!['photos_by_date'] as Map,
      );
      for (final entry in photosMap.entries) {
        for (final p in (entry.value as List)) {
          allPhotos.add({
            ...Map<String, dynamic>.from(p as Map),
            'uploaded_date': entry.key,
          });
        }
      }
    } else {
      final sites = siteData?['sites'] as List? ?? [];
      if (sites.isNotEmpty) {
        final photos = sites[0]['photos'] as List? ?? [];
        for (final p in photos) {
          allPhotos.add(Map<String, dynamic>.from(p as Map));
        }
      }
    }

    // Sort newest first
    allPhotos.sort((a, b) {
      final da = a['uploaded_date'] as String? ?? '';
      final db = b['uploaded_date'] as String? ?? '';
      return db.compareTo(da);
    });

    if (allPhotos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: allPhotos
          .map((photo) => _buildInstaPost(context, photo))
          .toList(),
    );
  }

  Widget _buildInstaPost(BuildContext context, Map<String, dynamic> photo) {
    final imageUrl = ConstructionService.getFullImageUrl(
      photo['photo_url'] ?? photo['image_url'] ?? '',
    );
    final uploadedBy = photo['uploaded_by'] as String? ?? 'Unknown';
    final role = photo['uploaded_by_role'] as String? ?? '';
    final timeOfDay = (photo['time_of_day'] as String? ?? '').toLowerCase();
    final date = photo['uploaded_date'] as String? ?? '';

    final isEvening = timeOfDay == 'evening';
    final timeLabel = isEvening ? '🌙 Evening' : '☀️ Morning';
    final timeColor = isEvening ? Colors.indigo : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (like Instagram post header) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.deepNavy.withValues(alpha: 0.1),
                  child: Icon(
                    role == 'Supervisor' ? Icons.person : Icons.engineering,
                    size: 16.sp,
                    color: AppColors.deepNavy,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uploadedBy,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      Text(
                        role.isNotEmpty ? role : 'Site Team',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: timeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: timeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: timeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Instagram-style photo with fixed aspect ratio ──
          GestureDetector(
            onTap: imageUrl.isNotEmpty
                ? () => _showFullscreenImage(context, photo)
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: imageUrl.isNotEmpty
                  ? AspectRatio(
                      aspectRatio: 4 / 3, // Instagram-like aspect ratio
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Icon(
                            Icons.photo_camera,
                            size: 40.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // ── Date caption ──
          if (date.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.photo_library, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'No photos yet',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, Map<String, dynamic> photo) {
    final imageUrl = ConstructionService.getFullImageUrl(
      photo['photo_url'] ?? photo['image_url'] ?? '',
    );
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
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                Text(
                  '$uploadedBy${role.isNotEmpty ? ' ($role)' : ''}',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
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
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64.sp,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16.h),
                      const Text(
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
      return '${months[dt.month - 1]} ${dt.day}';
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
            title: const Text(
              'Materials',
              style: TextStyle(color: Colors.white),
            ),
          ),
          materials.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No materials used yet',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.all(16.r),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final material = materials[index];
                      return _buildMaterialCard(material);
                    }, childCount: materials.length),
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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.deepNavy, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materialType,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '${totalUsed.toStringAsFixed(totalUsed % 1 == 0 ? 0 : 1)} $unit',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusCompleted,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'used',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (lastUsedDate.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Last used: $lastUsedDate',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$usageCount ${usageCount == 1 ? 'entry' : 'entries'}',
              style: TextStyle(
                fontSize: 12.sp,
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
    final architectDocs = sites.isNotEmpty
        ? (sites[0]['architect_documents'] as List? ?? [])
        : [];
    final engineerDocs = sites.isNotEmpty
        ? (sites[0]['engineer_documents'] as List? ?? [])
        : [];
    final allDocuments = [...architectDocs, ...engineerDocs];

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.deepNavy,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.deepNavy,
            title: const Text(
              'Designs & Plans',
              style: TextStyle(color: Colors.white),
            ),
          ),
          allDocuments.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.architecture,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        const Text(
                          'No designs uploaded yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.all(16.r),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final doc = allDocuments[index];
                      return _buildDesignCard(context, doc);
                    }, childCount: allDocuments.length),
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
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.insert_drive_file,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    docType,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  if (uploadDate.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      uploadDate,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
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

  Future<void> _openDocument(
    BuildContext context,
    String documentUrl,
    String title,
  ) async {
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
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      final response = await _constructionService.getClientComplaints(
        siteId: siteId,
      );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No site assigned')));
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
                SizedBox(height: 16.h),
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
                SizedBox(height: 16.h),
                const Text(
                  'Priority',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
                final response = await _constructionService
                    .createClientComplaint(
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
                      content: Text(
                        'Failed: ${response['error'] ?? 'Unknown error'}',
                      ),
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
            title: const Text(
              'Issues & Updates',
              style: TextStyle(color: Colors.white),
            ),
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
                    Icon(
                      Icons.report_problem,
                      size: 64.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No issues reported',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap + to report an issue',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final complaint = _complaints[index];
                  return _buildComplaintCard(complaint);
                }, childCount: _complaints.length),
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                ],

                // Status
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: _getStatusColor(status),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        status.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Created date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Reported: ${_formatDateTime(createdAt)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
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

      const months = [
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
  @override
  void initState() {
    super.initState();
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
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                // User Profile Card
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        widget.userName ?? 'Client',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Project Owner',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ],
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
