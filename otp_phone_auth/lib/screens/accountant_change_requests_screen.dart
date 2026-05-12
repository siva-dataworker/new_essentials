import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/change_request_provider.dart';
import '../utils/app_colors.dart';

class AccountantChangeRequestsScreen extends StatefulWidget {
  const AccountantChangeRequestsScreen({super.key});

  @override
  State<AccountantChangeRequestsScreen> createState() => _AccountantChangeRequestsScreenState();
}

class _AccountantChangeRequestsScreenState extends State<AccountantChangeRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Load requests only once using provider caching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeRequestProvider>().loadPendingChangeRequests();
    });
  }

  Future<void> _handleRequest(Map<String, dynamic> request) async {
    final newValueController = TextEditingController();
    final responseController = TextEditingController();

    final entryDetails = request['entry_details'] as Map<String, dynamic>?;
    final entryType = request['entry_type'] as String?;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text(
          'Handle Change Request',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request details
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16.sp, color: AppColors.deepNavy),
                        SizedBox(width: 6.w),
                        Text(
                          request['requested_by_name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      request['request_message'] ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Current value
              Text(
                'Current Value:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                entryType == 'LABOUR'
                    ? '${entryDetails?['labour_type']}: ${entryDetails?['labour_count']} workers'
                    : '${entryDetails?['material_type']}: ${entryDetails?['quantity']} ${entryDetails?['unit']}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              SizedBox(height: 16.h),
              // New value input
              TextField(
                controller: newValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'New Value',
                  hintText: 'Enter new count/quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Response message
              TextField(
                controller: responseController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Response Message',
                  hintText: 'Explain the change...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (newValueController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter new value')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text(
              'Apply Change',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == true && newValueController.text.trim().isNotEmpty) {
      // Handle the request using provider
      final changeRequestProvider = context.read<ChangeRequestProvider>();

      final response = await changeRequestProvider.handleChangeRequest(
        requestId: request['id'].toString(),
        newValue: int.tryParse(newValueController.text.trim()) ?? 0,
        responseMessage: responseController.text.trim(),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change applied successfully'),
            backgroundColor: const Color(0xFF1A1A2E),
          ),
        );
        // Requests are automatically reloaded by provider
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to apply change'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeRequestProvider>(
      builder: (context, provider, child) {
        final changeRequests = provider.pendingChangeRequests;
        final isLoading = provider.isLoadingRequests;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            title: Text(
              'Change Requests',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.deepNavy),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.deepNavy),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadPendingChangeRequests(forceRefresh: true),
                  color: AppColors.deepNavy,
                  child: changeRequests.isEmpty
                      ? _buildEmptyState()
                      : _buildRequestsList(changeRequests),
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
            Icons.check_circle_outline,
            size: 80.sp,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Pending Requests',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Change requests will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> changeRequests) {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: changeRequests.length,
      itemBuilder: (context, index) {
        final request = changeRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final entryDetails = request['entry_details'] as Map<String, dynamic>?;
    final entryType = request['entry_type'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.statusOverdue.withValues(alpha: 0.3),
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
            // Request badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pending_actions, size: 14.sp, color: AppColors.statusOverdue),
                  SizedBox(width: 4.w),
                  Text(
                    'PENDING REQUEST',
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
            // Requested by
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
                        'Requested by',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        request['requested_by_name'] ?? 'Unknown',
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
            // Entry details
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entryType == 'LABOUR' ? 'Labour Entry' : 'Material Entry',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entryType == 'LABOUR'
                        ? '${entryDetails?['labour_type']}: ${entryDetails?['labour_count']} workers'
                        : '${entryDetails?['material_type']}: ${entryDetails?['quantity']} ${entryDetails?['unit']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${entryDetails?['customer_name'] ?? ''} ${entryDetails?['site_name'] ?? 'Unknown Site'}'.trim(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Request message
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.message, size: 16.sp, color: AppColors.statusOverdue),
                      SizedBox(width: 6.w),
                      Text(
                        'Request Message',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusOverdue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    request['request_message'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Handle button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleRequest(request),
                icon: Icon(Icons.edit, size: 18.sp),
                label: const Text('Handle Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
