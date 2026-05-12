import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/change_request_provider.dart';
import '../utils/app_colors.dart';

class SupervisorChangesScreen extends StatefulWidget {
  const SupervisorChangesScreen({super.key});

  @override
  State<SupervisorChangesScreen> createState() => _SupervisorChangesScreenState();
}

class _SupervisorChangesScreenState extends State<SupervisorChangesScreen> {
  @override
  void initState() {
    super.initState();
    // Load modified entries only once using provider caching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeRequestProvider>().loadModifiedEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeRequestProvider>(
      builder: (context, provider, child) {
        final labourEntries = provider.modifiedLabourEntries;
        final materialEntries = provider.modifiedMaterialEntries;
        final isLoading = provider.isLoadingModified;

        final allEntries = [
          ...labourEntries.map((e) => {'type': 'labour', 'data': e}),
          ...materialEntries.map((e) => {'type': 'material', 'data': e}),
        ];

        // Sort by modified date
        allEntries.sort((a, b) {
          final dataA = a['data'] as Map<String, dynamic>?;
          final dataB = b['data'] as Map<String, dynamic>?;
          final dateA = dataA?['modified_at'] as String?;
          final dateB = dataB?['modified_at'] as String?;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return Scaffold(
          backgroundColor: AppColors.lightSlate,
          appBar: AppBar(
            title: Text(
              'Modified Entries',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.cleanWhite,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.deepNavy),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.deepNavy),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadModifiedEntries(forceRefresh: true),
                  color: AppColors.deepNavy,
                  child: allEntries.isEmpty
                      ? _buildEmptyState()
                      : _buildEntriesList(allEntries),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_off,
            size: 80.sp,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Modified Entries',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Entries modified by accountant will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<Map<String, dynamic>> entries) {
    // Group by date
    final groupedEntries = <String, List<Map<String, dynamic>>>{};
    for (var entry in entries) {
      final date = _formatDateHeader(entry['data']['modified_at']);
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final date = groupedEntries.keys.elementAt(index);
        final dateEntries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            ...dateEntries.map((entry) {
              if (entry['type'] == 'labour') {
                return _buildLabourCard(entry['data']);
              } else {
                return _buildMaterialCard(entry['data']);
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.statusOverdue.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modified badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 14.sp, color: AppColors.statusOverdue),
                  SizedBox(width: 4.w),
                  Text(
                    'MODIFIED',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusOverdue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Modified by
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.person, size: 18.sp, color: AppColors.deepNavy),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modified by',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        entry['modified_by_name'] ?? 'Accountant',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Site info
            Text(
              entry['site_name'] ?? 'Unknown Site',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            SizedBox(height: 8.h),
            // Labour details
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.engineering,
                    entry['labour_type'] ?? 'General',
                    AppColors.deepNavy,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildInfoChip(
                    Icons.groups,
                    '${entry['labour_count'] ?? 0} Workers',
                    AppColors.statusCompleted,
                  ),
                ),
              ],
            ),
            if (entry['modification_reason'] != null && entry['modification_reason'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.lightSlate,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16.sp, color: AppColors.deepNavy),
                        SizedBox(width: 6.w),
                        Text(
                          'Reason for Change',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      entry['modification_reason'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.statusOverdue.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modified badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 14.sp, color: AppColors.statusOverdue),
                  SizedBox(width: 4.w),
                  Text(
                    'MODIFIED',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusOverdue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Modified by
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.person, size: 18.sp, color: AppColors.deepNavy),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modified by',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        entry['modified_by_name'] ?? 'Accountant',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Site info
            Text(
              entry['site_name'] ?? 'Unknown Site',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            SizedBox(height: 8.h),
            // Material details
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.category,
                    entry['material_type'] ?? 'Unknown',
                    AppColors.deepNavy,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildInfoChip(
                    Icons.straighten,
                    '${entry['quantity'] ?? 0} ${entry['unit'] ?? ''}',
                    AppColors.statusCompleted,
                  ),
                ),
              ],
            ),
            if (entry['modification_reason'] != null && entry['modification_reason'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.lightSlate,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16.sp, color: AppColors.deepNavy),
                        SizedBox(width: 6.w),
                        Text(
                          'Reason for Change',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      entry['modification_reason'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);

      if (entryDate == today) {
        return 'Today';
      } else if (entryDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
