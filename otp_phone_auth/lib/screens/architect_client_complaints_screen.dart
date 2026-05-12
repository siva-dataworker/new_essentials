import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';

class ArchitectClientComplaintsScreen extends StatefulWidget {
  final String siteId;

  const ArchitectClientComplaintsScreen({
    super.key,
    required this.siteId,
  });

  @override
  State<ArchitectClientComplaintsScreen> createState() => _ArchitectClientComplaintsScreenState();
}

class _ArchitectClientComplaintsScreenState extends State<ArchitectClientComplaintsScreen> {
  final _constructionService = ConstructionService();
  List<dynamic> _complaints = [];
  bool _isLoading = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _constructionService.getClientComplaintsForArchitect(
        siteId: widget.siteId,
        status: _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _complaints = response['complaints'] as List? ?? [];
          _isLoading = false;
        });
      }

      print('✅ [ARCHITECT] Loaded ${_complaints.length} complaints for site ${widget.siteId}');
    } catch (e) {
      print('❌ [ARCHITECT] Error loading complaints: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: Text('Client Complaints', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value == 'ALL' ? null : value;
              });
              _loadComplaints();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('All Status')),
              const PopupMenuItem(value: 'OPEN', child: Text('Open')),
              const PopupMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
              const PopupMenuItem(value: 'RESOLVED', child: Text('Resolved')),
              const PopupMenuItem(value: 'CLOSED', child: Text('Closed')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        color: AppColors.deepNavy,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _complaints.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _complaints[index];
                      return _buildComplaintCard(complaint);
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
          Icon(Icons.chat_bubble_outline, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            _selectedStatus != null
                ? 'No ${_selectedStatus!.toLowerCase()} complaints'
                : 'No client complaints yet',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            'Client complaints will appear here',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
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
    final client = complaint['client'] as Map<String, dynamic>? ?? {};
    final clientName = client['name'] as String? ?? 'Unknown Client';
    final messageCount = complaint['message_count'] as int? ?? 0;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14.sp, color: Colors.grey[600]),
                            SizedBox(width: 4.w),
                            Text(
                              clientName,
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
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

                  // Status and Messages
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                      const Spacer(),
                      Icon(Icons.chat_bubble_outline, size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        '$messageCount ${messageCount == 1 ? 'message' : 'messages'}',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Created date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        'Reported: ${_formatDateTime(createdAt)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
        return 'Yesterday';
      }

      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
