import 'package:flutter/material.dart';
import 'dart:async';
import '../services/budget_service.dart';
import '../models/budget_model.dart';

class RealTimeUpdatesWidget extends StatefulWidget {
  final String? siteId;
  final bool autoRefresh;
  final Duration refreshInterval;

  const RealTimeUpdatesWidget({
    Key? key,
    this.siteId,
    this.autoRefresh = true,
    this.refreshInterval = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  State<RealTimeUpdatesWidget> createState() => _RealTimeUpdatesWidgetState();
}

class _RealTimeUpdatesWidgetState extends State<RealTimeUpdatesWidget> {
  final _budgetService = BudgetService();
  List<RealTimeUpdate> _updates = [];
  bool _isLoading = false;
  Timer? _refreshTimer;
  String? _lastSync;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
    if (widget.autoRefresh) {
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(widget.refreshInterval, (_) {
      _loadUpdates();
    });
  }

  Future<void> _loadUpdates() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final updates = await _budgetService.getRealTimeUpdates(
        lastSync: _lastSync,
        siteId: widget.siteId,
      );

      if (updates.isNotEmpty) {
        setState(() {
          _updates.insertAll(0, updates.map((u) => RealTimeUpdate.fromJson(u)));
          _lastSync = DateTime.now().toIso8601String();
        });
      }
    } catch (e) {
      print('Error loading updates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with refresh button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadUpdates,
                      tooltip: 'Refresh',
                    ),
                  if (widget.autoRefresh)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.sync, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Auto',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Updates list
        Expanded(
          child: _updates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No updates yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _updates.length,
                  itemBuilder: (context, index) {
                    final update = _updates[index];
                    return _buildUpdateCard(update);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUpdateCard(RealTimeUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showUpdateDetails(update),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getUpdateColor(update.updateType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getUpdateIcon(update.updateType),
                  color: _getUpdateColor(update.updateType),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.updateTypeDisplay,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      update.siteName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          update.changedBy,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Time and action badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(update.changedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getActionColor(update.action),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      update.actionDisplay,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateDetails(RealTimeUpdate update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(update.updateTypeDisplay),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Site', update.siteName),
            _buildDetailRow('Action', update.actionDisplay),
            _buildDetailRow('Changed By', update.changedBy),
            _buildDetailRow('Time', _formatFullTime(update.changedAt)),
            _buildDetailRow('Record Type', update.recordType),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getUpdateColor(String updateType) {
    switch (updateType) {
      case 'LABOUR_ENTRY':
        return Colors.blue;
      case 'LABOUR_CORRECTION':
        return Colors.orange;
      case 'BILL_UPLOAD':
        return Colors.purple;
      case 'BUDGET_UPDATE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getUpdateIcon(String updateType) {
    switch (updateType) {
      case 'LABOUR_ENTRY':
        return Icons.people;
      case 'LABOUR_CORRECTION':
        return Icons.edit;
      case 'BILL_UPLOAD':
        return Icons.receipt;
      case 'BUDGET_UPDATE':
        return Icons.account_balance_wallet;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'CREATE':
        return Colors.green;
      case 'UPDATE':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  String _formatFullTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
