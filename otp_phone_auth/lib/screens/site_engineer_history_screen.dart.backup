import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/construction_provider.dart';
import '../utils/app_colors.dart';

class SiteEngineerHistoryScreen extends StatefulWidget {
  final String? siteId;
  final String? siteName;

  const SiteEngineerHistoryScreen({
    super.key,
    this.siteId,
    this.siteName,
  });

  @override
  State<SiteEngineerHistoryScreen> createState() => _SiteEngineerHistoryScreenState();
}

class _SiteEngineerHistoryScreenState extends State<SiteEngineerHistoryScreen> {
  final Set<String> _expandedDates = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await context.read<ConstructionProvider>().loadSupervisorHistory(
      forceRefresh: true,
      siteId: widget.siteId,
    );
    setState(() => _isLoading = false);
  }

  void _expandAllDates() {
    setState(() {
      final constructionProvider = context.read<ConstructionProvider>();
      final allDates = <String>{};
      
      // Filter only Site Engineer entries
      final siteEngineerEntries = constructionProvider.labourEntries.where((e) {
        final role = (e['user_role'] as String? ?? '').toLowerCase();
        return role == 'site engineer';
      });
      
      for (var entry in siteEngineerEntries) {
        final date = entry['entry_date'] ?? '';
        if (date.isNotEmpty) allDates.add(date);
      }
      
      _expandedDates.addAll(allDates);
    });
  }

  void _collapseAllDates() {
    setState(() {
      _expandedDates.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: Text(
          widget.siteName ?? 'Labour History',
          style: const TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.deepNavy),
            onSelected: (value) {
              if (value == 'expand_all') {
                _expandAllDates();
              } else if (value == 'collapse_all') {
                _collapseAllDates();
              } else if (value == 'refresh') {
                _loadData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'expand_all',
                child: Row(
                  children: [
                    Icon(Icons.expand_more, size: 20, color: AppColors.deepNavy),
                    SizedBox(width: 12),
                    Text('Expand All Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'collapse_all',
                child: Row(
                  children: [
                    Icon(Icons.expand_less, size: 20, color: AppColors.deepNavy),
                    SizedBox(width: 12),
                    Text('Collapse All Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20, color: AppColors.deepNavy),
                    SizedBox(width: 12),
                    Text('Refresh Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ConstructionProvider>(
        builder: (context, provider, child) {
          // Filter only Site Engineer labour entries
          final siteEngineerLabourEntries = provider.labourEntries.where((e) {
            final role = (e['user_role'] as String? ?? '').toLowerCase();
            return role == 'site engineer';
          }).toList();

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (siteEngineerLabourEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Labour History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your labour entries will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: _buildHistoryList(siteEngineerLabourEntries),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: AppColors.deepNavy,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> entries) {
    // Group entries by date
    final Map<String, List<Map<String, dynamic>>> entriesByDate = {};
    
    for (var entry in entries) {
      final date = entry['entry_date'] as String? ?? '';
      if (date.isNotEmpty) {
        entriesByDate.putIfAbsent(date, () => []);
        entriesByDate[date]!.add(entry);
      }
    }

    // Sort dates in descending order
    final sortedDates = entriesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return const Center(
        child: Text('No entries found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateEntries = entriesByDate[date]!;
        final isExpanded = _expandedDates.contains(date);

        return _buildDateSection(date, dateEntries, isExpanded);
      },
    );
  }

  Widget _buildDateSection(String date, List<Map<String, dynamic>> entries, bool isExpanded) {
    final formattedDate = _formatDate(date);
    final totalWorkers = entries.fold<int>(0, (sum, e) => sum + (e['labour_count'] as int? ?? 0));
    final totalCost = entries.fold<double>(0, (sum, e) => sum + (e['total_cost'] as num? ?? 0).toDouble());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDates.remove(date);
                } else {
                  _expandedDates.add(date);
                }
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalWorkers workers • ₹${totalCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.deepNavy,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ...entries.map((entry) => _buildLabourEntry(entry)),
        ],
      ),
    );
  }

  Widget _buildLabourEntry(Map<String, dynamic> entry) {
    final labourType = entry['labour_type'] as String? ?? 'Unknown';
    final count = entry['labour_count'] as int? ?? 0;
    final rate = (entry['daily_rate'] as num?)?.toDouble() ?? 0;
    final totalCost = (entry['total_cost'] as num?)?.toDouble() ?? 0;
    final extraCost = (entry['extra_cost'] as num?)?.toDouble() ?? 0;
    final notes = entry['notes'] as String? ?? '';
    final extraCostNotes = entry['extra_cost_notes'] as String? ?? '';
    final entryTime = entry['entry_time'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getLabourIcon(labourType), color: AppColors.deepNavy, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labourType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    Text(
                      '$count workers × ₹${rate.toStringAsFixed(0)}/day',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${totalCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  if (entryTime.isNotEmpty)
                    Text(
                      _formatTime(entryTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (extraCost > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Extra Cost: ₹${extraCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  if (extraCostNotes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        extraCostNotes,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: $notes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getLabourIcon(String type) {
    switch (type) {
      case 'Carpenter':
        return Icons.carpenter;
      case 'Mason':
        return Icons.construction;
      case 'Electrician':
        return Icons.electrical_services;
      case 'Plumber':
        return Icons.plumbing;
      case 'Painter':
        return Icons.format_paint;
      case 'Helper':
        return Icons.handyman;
      case 'Tile Layer':
        return Icons.grid_on;
      case 'Kambi Fitter':
        return Icons.build;
      case 'Concrete Kot':
        return Icons.foundation;
      case 'Pile Labour':
        return Icons.vertical_align_bottom;
      default:
        return Icons.person;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final checkDate = DateTime(date.year, date.month, date.day);

      if (checkDate == today) {
        return 'Today';
      } else if (checkDate == yesterday) {
        return 'Yesterday';
      }
      
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return '';
    }
  }
}
