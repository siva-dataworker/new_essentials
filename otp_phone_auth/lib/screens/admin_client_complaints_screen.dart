import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../services/construction_service.dart';
import '../services/cache_service.dart';
import '../utils/smooth_animations.dart';

class AdminClientComplaintsScreen extends StatefulWidget {
  const AdminClientComplaintsScreen({super.key});

  @override
  State<AdminClientComplaintsScreen> createState() => _AdminClientComplaintsScreenState();
}

class _AdminClientComplaintsScreenState extends State<AdminClientComplaintsScreen> with AutomaticKeepAliveClientMixin {
  final _constructionService = ConstructionService();
  List<dynamic> _complaints = [];
  bool _isLoading = false;
  String? _selectedStatus;
  final Map<String?, List<dynamic>> _complaintsCache = {}; // Cache by status
  Timer? _refreshTimer; // Background refresh timer
  
  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    _loadComplaints();
    _startBackgroundRefresh();
  }
  
  @override
  void dispose() {
    _stopBackgroundRefresh();
    super.dispose();
  }
  
  void _startBackgroundRefresh() {
    // Refresh complaints every 60 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        if (mounted) {
          _loadComplaints(forceRefresh: true);
        }
      },
    );
  }
  
  void _stopBackgroundRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> _loadComplaints({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    // Load from persistent cache first (instant display)
    if (!forceRefresh && !_complaintsCache.containsKey(_selectedStatus)) {
      final cached = await CacheService.loadComplaints(_selectedStatus);
      if (cached != null && mounted) {
        setState(() {
          _complaints = cached;
          _complaintsCache[_selectedStatus] = cached;
        });
        print('✅ [ADMIN] Loaded ${_complaints.length} complaints from persistent cache');
      }
    }
    
    // Check memory cache
    if (_complaintsCache.containsKey(_selectedStatus) && !forceRefresh) {
      setState(() {
        _complaints = _complaintsCache[_selectedStatus]!;
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Admin sees ALL complaints (no site_id filter)
      final response = await _constructionService.getClientComplaintsForArchitect(
        status: _selectedStatus,
      );
      
      if (mounted) {
        final complaints = response['complaints'] as List? ?? [];
        
        // Save to persistent cache
        await CacheService.saveComplaints(complaints, _selectedStatus);
        
        // Cache the complaints in memory
        _complaintsCache[_selectedStatus] = complaints;
        setState(() {
          _complaints = complaints;
          _isLoading = false;
        });
        
        print('✅ [ADMIN] Loaded ${_complaints.length} complaints and saved to cache');
      }
    } catch (e) {
      print('❌ [ADMIN] Error loading complaints: $e');
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Material(
      color: const Color(0xFFF8F9FA),
      child: RefreshIndicator(
        onRefresh: () => _loadComplaints(forceRefresh: true),
        color: const Color(0xFF1A1A2E),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _complaints.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Filter bar with dropdown
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list, color: const Color(0xFF1A1A2E), size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Filter:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatus ?? 'ALL',
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF1A1A2E)),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value == 'ALL' ? null : value;
                                      });
                                      _loadComplaints();
                                    },
                                    items: const [
                                      DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                                      DropdownMenuItem(value: 'OPEN', child: Text('Open')),
                                      DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                                      DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved')),
                                      DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Complaints list
                      Expanded(
                        child: ListView.builder(
                          physics: const SmoothScrollPhysics(),
                              padding: EdgeInsets.all(16.r),
                          itemCount: _complaints.length,
                          itemBuilder: (context, index) {
                            final complaint = _complaints[index];
                            return _buildComplaintCard(complaint);
                          },
                        ),
                      ),
                    ],
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
    final siteName = complaint['site_name'] as String? ?? 'Unknown Site';
    final customerName = complaint['customer_name'] as String? ?? '';
    final messageCount = complaint['message_count'] as int? ?? 0;

    return GestureDetector(
      onTap: () => _showComplaintDialog(complaint),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and priority
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
                  // Client info
                  Row(
                    children: [
                      Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        'Client: ',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                      Text(
                        clientName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Site info
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        'Site: ',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                      Expanded(
                        child: Text(
                          siteName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (customerName.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.business, size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          'Customer: ',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                        ),
                        Text(
                          customerName,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],

                  if (description.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // Status and message count
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

                  // Created date and tap hint
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        'Reported: ${_formatDateTime(createdAt)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        'Tap for details',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF1A1A2E),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_ios, size: 12.sp, color: const Color(0xFF1A1A2E)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDialog(Map<String, dynamic> complaint) {
    final title = complaint['title'] as String? ?? 'Untitled';
    final description = complaint['description'] as String? ?? 'No description provided';
    final status = complaint['status'] as String? ?? 'OPEN';
    final priority = complaint['priority'] as String? ?? 'MEDIUM';
    final createdAt = complaint['created_at'] as String? ?? '';
    final client = complaint['client'] as Map<String, dynamic>? ?? {};
    final clientName = client['name'] as String? ?? 'Unknown Client';
    final clientUsername = client['username'] as String? ?? '';
    final siteName = complaint['site_name'] as String? ?? 'Unknown Site';
    final customerName = complaint['customer_name'] as String? ?? '';
    final messageCount = complaint['message_count'] as int? ?? 0;
    final resolvedAt = complaint['resolved_at'] as String?;
    final resolutionNotes = complaint['resolution_notes'] as String? ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client info
              _buildDetailRow(Icons.person, 'Client', '$clientName ($clientUsername)'),
              SizedBox(height: 12.h),

              // Site info
              _buildDetailRow(Icons.location_city, 'Site', siteName),
              SizedBox(height: 12.h),

              if (customerName.isNotEmpty) ...[
                _buildDetailRow(Icons.business, 'Customer', customerName),
                SizedBox(height: 12.h),
              ],

              // Status
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Status: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
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
                ],
              ),
              SizedBox(height: 12.h),

              // Message count
              _buildDetailRow(Icons.chat_bubble_outline, 'Messages', '$messageCount'),
              SizedBox(height: 12.h),

              // Created date
              _buildDetailRow(Icons.calendar_today, 'Reported', _formatDateTime(createdAt)),

              if (resolvedAt != null) ...[
                SizedBox(height: 12.h),
                _buildDetailRow(Icons.check_circle, 'Resolved', _formatDateTime(resolvedAt)),
              ],

              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 8.h),

              // Description
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A2E),
                ),
              ),

              if (resolutionNotes.isNotEmpty) ...[
                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 8.h),
                Text(
                  'Resolution Notes:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  resolutionNotes,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
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
