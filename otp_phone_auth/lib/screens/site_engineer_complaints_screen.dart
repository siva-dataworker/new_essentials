import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/site_engineer_provider.dart';
import '../utils/app_colors.dart';

class SiteEngineerComplaintsScreen extends StatefulWidget {
  const SiteEngineerComplaintsScreen({super.key});

  @override
  State<SiteEngineerComplaintsScreen> createState() => _SiteEngineerComplaintsScreenState();
}

class _SiteEngineerComplaintsScreenState extends State<SiteEngineerComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SiteEngineerProvider>().loadComplaints(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Complaints',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            Text(
              'Raised by Architect',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SiteEngineerProvider>(
        builder: (context, provider, child) {
          final complaints = provider.complaints;
          final isLoading = provider.isLoading;

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.deepNavy),
            );
          }

          if (complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightSlate,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 60.sp,
                      color: AppColors.statusCompleted,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No Complaints',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'All complaints have been resolved',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadComplaints(forceRefresh: true),
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return _buildComplaintCard(complaint);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final isOpen = complaint['status'] == 'OPEN';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: isOpen
                        ? AppColors.statusOverdue.withValues(alpha: 0.2)
                        : AppColors.statusCompleted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isOpen ? Icons.warning_amber_rounded : Icons.check_circle,
                    color: isOpen ? AppColors.statusOverdue : AppColors.statusCompleted,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complaint #${complaint['complaint_id']}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        complaint['created_at'] ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? AppColors.statusOverdue.withValues(alpha: 0.1)
                        : AppColors.statusCompleted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isOpen ? 'OPEN' : 'RESOLVED',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isOpen ? AppColors.statusOverdue : AppColors.statusCompleted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.lightSlate,
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.deepNavy,
                    height: 1.5,
                  ),
                ),
                if (isOpen) ...[
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to rectification upload screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rectification upload coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Upload Rectification Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepNavy,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
