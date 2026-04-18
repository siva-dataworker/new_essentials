import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';

class AdminClientComplaintsScreen extends StatefulWidget {
  const AdminClientComplaintsScreen({super.key});

  @override
  State<AdminClientComplaintsScreen> createState() => _AdminClientComplaintsScreenState();
}

class _AdminClientComplaintsScreenState extends State<AdminClientComplaintsScreen> {
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
      // Admin sees ALL complaints (no site_id filter)
      final response = await _constructionService.getClientComplaintsForArchitect(
        status: _selectedStatus,
      );
      
      if (mounted) {
        setState(() {
          _complaints = response['complaints'] as List? ?? [];
          _isLoading = false;
        });
      }
      
      print('✅ [ADMIN] Loaded ${_complaints.length} complaints');
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
    return Material(
      color: const Color(0xFFF8F9FA),
      child: RefreshIndicator(
        onRefresh: _loadComplaints,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, color: const Color(0xFF1A1A2E), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Filter:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatus ?? 'ALL',
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: const Color(0xFF1A1A2E)),
                                    style: const TextStyle(
                                      fontSize: 14,
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
                          padding: const EdgeInsets.all(16),
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
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _selectedStatus != null 
                ? 'No ${_selectedStatus!.toLowerCase()} complaints'
                : 'No client complaints yet',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Client complaints will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
                  // Client info
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Client: ',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Site info
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Site: ',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Expanded(
                        child: Text(
                          siteName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  if (customerName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Customer: ',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        Text(
                          customerName,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                  
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Status and message count
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      const Spacer(),
                      Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$messageCount ${messageCount == 1 ? 'message' : 'messages'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Created date and tap hint
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Reported: ${_formatDateTime(createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        'Tap for details',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF1A1A2E),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 12, color: const Color(0xFF1A1A2E)),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client info
              _buildDetailRow(Icons.person, 'Client', '$clientName ($clientUsername)'),
              const SizedBox(height: 12),
              
              // Site info
              _buildDetailRow(Icons.location_city, 'Site', siteName),
              const SizedBox(height: 12),
              
              if (customerName.isNotEmpty) ...[
                _buildDetailRow(Icons.business, 'Customer', customerName),
                const SizedBox(height: 12),
              ],
              
              // Status
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const SizedBox(height: 12),
              
              // Message count
              _buildDetailRow(Icons.chat_bubble_outline, 'Messages', '$messageCount'),
              const SizedBox(height: 12),
              
              // Created date
              _buildDetailRow(Icons.calendar_today, 'Reported', _formatDateTime(createdAt)),
              
              if (resolvedAt != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.check_circle, 'Resolved', _formatDateTime(resolvedAt)),
              ],
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Description
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              
              if (resolutionNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Resolution Notes:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resolutionNotes,
                  style: TextStyle(
                    fontSize: 14,
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
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
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
