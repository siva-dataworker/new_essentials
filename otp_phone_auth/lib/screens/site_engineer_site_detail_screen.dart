import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/construction_service.dart';
import 'site_engineer_photo_upload_screen.dart';
import 'site_photo_gallery_screen.dart';
import 'site_engineer_labour_screen.dart';
import 'site_engineer_history_screen.dart';

class SiteEngineerSiteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;
  final UserModel user;

  const SiteEngineerSiteDetailScreen({
    super.key,
    required this.site,
    required this.user,
  });

  @override
  State<SiteEngineerSiteDetailScreen> createState() => _SiteEngineerSiteDetailScreenState();
}

class _SiteEngineerSiteDetailScreenState extends State<SiteEngineerSiteDetailScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _constructionService = ConstructionService();
  List<Map<String, dynamic>> _extraCosts = [];
  bool _isLoadingExtraCosts = false;
  List<Map<String, dynamic>> _historyEntries = [];
  bool _isLoadingHistory = false;
  List<Map<String, dynamic>> _projectFiles = [];
  bool _isLoadingProjectFiles = false;

  @override
  void initState() {
    super.initState();
    _loadExtraCosts();
    _loadHistory();
    _loadProjectFiles();
  }

  Future<void> _loadProjectFiles() async {
    setState(() => _isLoadingProjectFiles = true);

    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/project-files/${widget.site['id']}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _projectFiles = List<Map<String, dynamic>>.from(data['files']);
          _isLoadingProjectFiles = false;
        });
      } else {
        setState(() => _isLoadingProjectFiles = false);
      }
    } catch (e) {
      setState(() => _isLoadingProjectFiles = false);
    }
  }

  Future<void> _loadExtraCosts() async {
    setState(() => _isLoadingExtraCosts = true);

    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/extra-costs/${widget.site['id']}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _extraCosts = List<Map<String, dynamic>>.from(data['extra_costs']);
          _isLoadingExtraCosts = false;
        });
      } else {
        setState(() => _isLoadingExtraCosts = false);
      }
    } catch (e) {
      setState(() => _isLoadingExtraCosts = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/accountant/all-entries/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final labourEntries = List<Map<String, dynamic>>.from(data['labour_entries'] ?? []);
        final materialEntries = List<Map<String, dynamic>>.from(data['material_entries'] ?? []);

        // Filter by current site
        final siteId = widget.site['id'].toString();
        final filteredLabour = labourEntries.where((e) => e['site_id'].toString() == siteId).toList();
        final filteredMaterial = materialEntries.where((e) => e['site_id'].toString() == siteId).toList();

        // Combine and sort by date
        final combined = <Map<String, dynamic>>[];

        for (var entry in filteredLabour) {
          combined.add({
            ...entry,
            'type': 'LABOUR',
          });
        }

        for (var entry in filteredMaterial) {
          combined.add({
            ...entry,
            'type': 'MATERIAL',
          });
        }

        // Sort by date (newest first)
        combined.sort((a, b) {
          final dateA = DateTime.tryParse(a['entry_time'] ?? a['updated_at'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['entry_time'] ?? b['updated_at'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

        setState(() {
          _historyEntries = combined;
          _isLoadingHistory = false;
        });
      } else {
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: Text(
          widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site Details',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPhotosTab(),
          _buildComplaintsTab(),
          _buildProjectFilesTab(),
          _buildExtraCostTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cleanWhite,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Project Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Extra Cost',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: AppColors.safetyOrange,
        child: Icon(Icons.add, size: 32.sp),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.people,
                  label: 'Labour',
                  color: AppColors.safetyOrange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SiteEngineerLabourScreen(
                          siteId: widget.site['id'].toString(),
                          siteName: widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.history,
                  label: 'History',
                  color: AppColors.deepNavy,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SiteEngineerHistoryScreen(
                          siteId: widget.site['id'].toString(),
                          siteName: widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.inventory_2,
                  label: 'Material\nRequest',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    _showMaterialRequirementDialog();
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showMaterialRequirementDialog() {
    final _constructionService = ConstructionService();
    final materialNameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final notesController = TextEditingController();
    String selectedPriority = 'normal';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Material Requirement'),
          contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: materialNameController,
                    decoration: const InputDecoration(
                      labelText: 'Material Name *',
                      hintText: 'e.g., Cement, Steel, Bricks',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit *',
                            hintText: 'bags, tons',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'urgent', child: Text('🔴 Urgent')),
                      DropdownMenuItem(value: 'normal', child: Text('🟡 Normal')),
                      DropdownMenuItem(value: 'low', child: Text('🟢 Low')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedPriority = value ?? 'normal');
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional details...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (materialNameController.text.isEmpty ||
                    quantityController.text.isEmpty ||
                    unitController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final qty = double.tryParse(quantityController.text);
                if (qty == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity')),
                  );
                  return;
                }

                final result = await _constructionService.submitMaterialRequirement(
                  siteId: widget.site['id'].toString(),
                  materialName: materialNameController.text.trim(),
                  quantity: qty,
                  unit: unitController.text.trim(),
                  priority: selectedPriority,
                  notes: notesController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['success'] == true
                          ? result['message'] ?? 'Material requirement submitted'
                          : result['error'] ?? 'Failed to submit'),
                      backgroundColor:
                          result['success'] == true ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Site Info Card
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.cleanWhite,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.deepNavy.withValues(alpha: 0.8), AppColors.deepNavy],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.location_city, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.site['display_name'] ?? widget.site['site_name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepNavy,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.site['area'] ?? ''}, ${widget.site['street'] ?? ''}',
                            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Upload Photo Button
          ElevatedButton.icon(
            onPressed: () => _openPhotoUpload(),
            icon: Icon(Icons.camera_alt, size: 20.sp),
            label: Text('Upload Photo', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 2,
            ),
          ),
          SizedBox(height: 12.h),

          // View Gallery Button
          OutlinedButton.icon(
            onPressed: () => _openPhotoGallery(),
            icon: Icon(Icons.photo_library, size: 20.sp),
            label: Text('View Gallery', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepNavy,
              side: const BorderSide(color: AppColors.deepNavy, width: 2),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(height: 24.h),

          // Instructions
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.statusCompleted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.statusCompleted, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Photo Upload Guidelines',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildGuideline('🌅', 'Morning Photo', 'Upload before 1:00 PM - Work Started'),
                SizedBox(height: 8.h),
                _buildGuideline('🌆', 'Evening Photo', 'Upload after 1:00 PM - Work Completed'),
                SizedBox(height: 8.h),
                _buildGuideline('📸', 'Quality', 'Clear, well-lit photos of work progress'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(String icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_problem_outlined, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: 16.h),
            Text(
              'Complaints',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            SizedBox(height: 8.h),
            Text(
              'View and resolve complaints raised by clients',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Coming Soon',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.statusOverdue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectFilesTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: 16.h),
            Text(
              'Project Files',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            SizedBox(height: 8.h),
            Text(
              'View and upload project documents and files',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Coming Soon',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.statusOverdue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraCostTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Add Extra Cost Button
          Container(
            padding: EdgeInsets.all(16.r),
            color: AppColors.cleanWhite,
            child: ElevatedButton.icon(
              onPressed: () => _showAddExtraCostDialog(),
              icon: Icon(Icons.add, size: 20.sp),
              label: Text('Add Extra Cost', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.cleanWhite,
            child: TabBar(
              labelColor: AppColors.deepNavy,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.deepNavy,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              tabs: const [
                Tab(text: 'Extra Costs'),
                Tab(text: 'History'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                // Extra Costs List
                _isLoadingExtraCosts
                    ? const Center(child: CircularProgressIndicator(color: AppColors.deepNavy))
                    : _extraCosts.isEmpty
                        ? _buildEmptyExtraCostState()
                        : RefreshIndicator(
                            onRefresh: _loadExtraCosts,
                            color: AppColors.deepNavy,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.r),
                              itemCount: _extraCosts.length,
                              itemBuilder: (context, index) => _buildExtraCostCard(_extraCosts[index]),
                            ),
                          ),

                // History View
                _buildHistoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: AppColors.deepNavy));
    }

    if (_historyEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              SizedBox(height: 16.h),
              Text(
                'No History',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              SizedBox(height: 8.h),
              Text(
                'Labour and material entries will appear here',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.deepNavy,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _historyEntries.length,
        itemBuilder: (context, index) => _buildHistoryCard(_historyEntries[index]),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final isLabour = entry['type'] == 'LABOUR';
    final icon = isLabour ? Icons.people : Icons.inventory_2;
    final color = isLabour ? AppColors.statusCompleted : AppColors.deepNavy;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLabour ? entry['labour_type'] ?? 'Labour' : entry['material_type'] ?? 'Material',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isLabour
                            ? '${entry['labour_count']} workers'
                            : '${entry['quantity']} ${entry['unit'] ?? 'units'}',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    isLabour ? 'LABOUR' : 'MATERIAL',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            // Extra cost if present
            if (entry['extra_cost'] != null && entry['extra_cost'] > 0) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.statusOverdue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.statusOverdue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 16.sp, color: AppColors.statusOverdue),
                    SizedBox(width: 6.w),
                    Text(
                      'Extra Cost: ₹${entry['extra_cost']}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusOverdue,
                      ),
                    ),
                    if (entry['extra_cost_notes'] != null && entry['extra_cost_notes'].toString().isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          entry['extra_cost_notes'],
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.person, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  entry['supervisor_name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(entry['entry_time'] ?? entry['updated_at']),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExtraCostState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: 16.h),
            Text(
              'No Extra Costs',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap "Add Extra Cost" to submit additional expenses',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraCostCard(Map<String, dynamic> cost) {
    final amount = cost['amount'] ?? 0;
    final status = cost['payment_status'] ?? 'PENDING';
    final statusColor = status == 'PAID' ? AppColors.statusCompleted : AppColors.statusOverdue;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (cost['description'] != null && cost['description'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                cost['description'],
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
            if (cost['notes'] != null && cost['notes'].toString().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                cost['notes'],
                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.person, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  cost['submitted_by'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(cost['uploaded_at']),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExtraCostDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text(
            'Add Extra Cost',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount *',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: AppColors.lightSlate,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Description *',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Extra materials, Labor overtime',
                    filled: true,
                    fillColor: AppColors.lightSlate,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Notes (Optional)',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Additional details...',
                    filled: true,
                    fillColor: AppColors.lightSlate,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (amountController.text.isEmpty || descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in amount and description'),
                            backgroundColor: AppColors.statusOverdue,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        final token = await _authService.getToken();

                        final response = await http.post(
                          Uri.parse('${AuthService.baseUrl}/construction/submit-extra-cost/'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          },
                          body: json.encode({
                            'site_id': widget.site['id'],
                            'amount': amountController.text,
                            'description': descriptionController.text,
                            'notes': notesController.text,
                          }),
                        );

                        setState(() => isSubmitting = false);

                        if (response.statusCode == 201) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Extra cost submitted successfully!'),
                              backgroundColor: AppColors.statusCompleted,
                            ),
                          );
                          _loadExtraCosts();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed: ${response.body}'),
                              backgroundColor: AppColors.statusOverdue,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.statusOverdue,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _openPhotoUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteEngineerPhotoUploadScreen(site: widget.site),
      ),
    );
  }

  void _openPhotoGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SitePhotoGalleryScreen(site: widget.site),
      ),
    );
  }
}
