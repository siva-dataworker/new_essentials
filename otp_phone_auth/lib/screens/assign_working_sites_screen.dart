import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignWorkingSitesScreen extends StatefulWidget {
  const AssignWorkingSitesScreen({super.key});

  @override
  State<AssignWorkingSitesScreen> createState() => _AssignWorkingSitesScreenState();
}

class _AssignWorkingSitesScreenState extends State<AssignWorkingSitesScreen> {
  final _constructionService = ConstructionService();

  List<Map<String, dynamic>> _allSites = [];
  final Set<String> _selectedSiteIds = {};

  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAllSites();
  }

  Future<void> _loadAllSites() async {
    setState(() => _isLoading = true);

    try {
      final result = await _constructionService.getAllSites();

      if (result['success'] && mounted) {
        setState(() {
          _allSites = result['sites'] as List<Map<String, dynamic>>;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error'] ?? 'Failed to load sites'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedSiteIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one site'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Prepare sites data
    final sites = _selectedSiteIds.map((siteId) {
      return {
        'site_id': siteId,
        'description': '',
      };
    }).toList();

    final result = await _constructionService.assignWorkingSites(
      sites: sites,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success']
              ? '✅ ${result['message']}'
              : '❌ ${result['error']}'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Assign Working Sites',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Sites to Assign',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Selected sites will be assigned to all supervisors',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                if (_selectedSiteIds.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_selectedSiteIds.length} site${_selectedSiteIds.length != 1 ? 's' : ''} selected',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Sites List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF1A1A2E)),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading sites...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  )
                : _allSites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.construction,
                              size: 64.sp,
                              color: const Color(0xFF6B7280).withValues(alpha: 0.4),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No sites available',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(16.r),
                        itemCount: _allSites.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final site = _allSites[index];
                          final siteId = site['id'].toString();
                          final isSelected = _selectedSiteIds.contains(siteId);

                          return _buildSiteCard(site, siteId, isSelected);
                        },
                      ),
          ),

          // Submit Button
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: _isSubmitting || _selectedSiteIds.isEmpty
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedSiteIds.isEmpty ? null : _submitAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedSiteIds.isEmpty
                                  ? 'Select Sites to Assign'
                                  : 'Assign ${_selectedSiteIds.length} Site${_selectedSiteIds.length != 1 ? 's' : ''} to All Supervisors',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_selectedSiteIds.isNotEmpty) ...[
                              SizedBox(width: 8.w),
                              Icon(Icons.arrow_forward_rounded, size: 20.sp),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site, String siteId, bool isSelected) {
    final siteName = site['site_name'] ?? 'Unknown Site';
    final customerName = site['customer_name'] ?? '';
    final area = site['area'] ?? '';
    final street = site['street'] ?? '';
    final displayName = site['display_name'] ?? (customerName.isNotEmpty ? '$customerName $siteName' : siteName);

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? const Color(0xFF059669) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedSiteIds.remove(siteId);
            } else {
              _selectedSiteIds.add(siteId);
            }
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF059669) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF059669) : const Color(0xFF6B7280),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),

              // Site Icon
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.construction, color: const Color(0xFF1A1A2E), size: 24.sp),
              ),
              SizedBox(width: 12.w),

              // Site Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Area Badge
                    if (area.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_city, size: 12.sp, color: const Color(0xFF1A1A2E)),
                            SizedBox(width: 4.w),
                            Text(
                              area,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 6.h),
                    // Street
                    Row(
                      children: [
                        Icon(Icons.route, size: 14.sp, color: const Color(0xFF6B7280)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            street.isNotEmpty ? street : 'No street',
                            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
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
      ),
    );
  }
}
