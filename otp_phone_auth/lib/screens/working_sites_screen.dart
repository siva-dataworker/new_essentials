import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';
import 'site_detail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkingSitesScreen extends StatefulWidget {
  const WorkingSitesScreen({super.key});

  @override
  State<WorkingSitesScreen> createState() => _WorkingSitesScreenState();
}

class _WorkingSitesScreenState extends State<WorkingSitesScreen> {
  final _constructionService = ConstructionService();

  List<Map<String, dynamic>> _workingSites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkingSites();
  }

  Future<void> _loadWorkingSites() async {
    setState(() => _isLoading = true);

    try {
      final result = await _constructionService.getWorkingSites();

      if (result['success'] && mounted) {
        setState(() {
          _workingSites = result['sites'] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSite(Map<String, dynamic> site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteDetailScreen(site: site),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text('Working Sites'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkingSites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWorkingSites,
        color: AppColors.safetyOrange,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.deepNavy),
              )
            : _workingSites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: _workingSites.length,
                    itemBuilder: (context, index) {
                      final site = _workingSites[index];
                      return _buildSiteCard(site);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Working Sites Assigned',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your accountant will assign sites to you',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSite(site),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.navyGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.construction,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        site['display_name'] ?? site['site_name'] ?? 'Site',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: AppColors.deepNavy,
                    ),
                  ],
                ),

                // Description (if available)
                if (site['description'] != null && site['description'].toString().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.lightSlate,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18.sp,
                          color: AppColors.deepNavy,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            site['description'],
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.deepNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Assigned Date
                if (site['assigned_date'] != null) ...[
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Assigned: ${site['assigned_date']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
