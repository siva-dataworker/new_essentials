import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/material_provider.dart';
import '../utils/app_colors.dart';

class MaterialUsageHistoryScreen extends StatefulWidget {
  final String siteId;
  final String materialType;

  const MaterialUsageHistoryScreen({
    Key? key,
    required this.siteId,
    required this.materialType,
  }) : super(key: key);

  @override
  State<MaterialUsageHistoryScreen> createState() => _MaterialUsageHistoryScreenState();
}

class _MaterialUsageHistoryScreenState extends State<MaterialUsageHistoryScreen> {
  Map<String, List<Map<String, dynamic>>> _groupedHistory = {};
  Set<String> _expandedDates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    await provider.loadUsageHistory(widget.siteId, materialType: widget.materialType);
    _groupHistoryByDate();
  }

  void _groupHistoryByDate() {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    final history = provider.usageHistory;

    final grouped = <String, List<Map<String, dynamic>>>{};

    for (var entry in history) {
      final dateStr = entry['usage_date'] as String?;
      if (dateStr == null) continue;

      final date = DateTime.parse(dateStr);
      final key = DateFormat('yyyy-MM-dd').format(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(entry);
    }

    // Sort by date descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      _groupedHistory = {for (var key in sortedKeys) key: grouped[key]!};
    });
  }

  String _formatDateHeader(String dateStr) {
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
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    }
  }

  void _toggleDate(String date) {
    setState(() {
      if (_expandedDates.contains(date)) {
        _expandedDates.remove(date);
      } else {
        _expandedDates.add(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Usage History'),
            Text(
              widget.materialType,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_groupedHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Usage History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No usage records found for this material.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groupedHistory.length,
              itemBuilder: (context, index) {
                final date = _groupedHistory.keys.elementAt(index);
                final entries = _groupedHistory[date]!;
                final isExpanded = _expandedDates.contains(date);
                final totalUsed = entries.fold<double>(
                  0.0,
                  (sum, entry) => sum + ((entry['quantity_used'] ?? 0.0) as num).toDouble(),
                );
                final unit = entries.first['unit'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      // Date Header
                      InkWell(
                        onTap: () => _toggleDate(date),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Expand/Collapse Icon
                              AnimatedRotation(
                                turns: isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDateHeader(date),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Used
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${totalUsed.toStringAsFixed(1)} $unit',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Total Used',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Entries List (Expandable)
                      if (isExpanded)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            border: Border(
                              top: BorderSide(color: AppColors.mediumGray),
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entries.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: AppColors.mediumGray,
                            ),
                            itemBuilder: (context, entryIndex) {
                              final entry = entries[entryIndex];
                              final supervisorName = entry['supervisor_name'] ?? 'Unknown';
                              final quantityUsed = ((entry['quantity_used'] ?? 0.0) as num).toDouble();
                              final usageTime = entry['usage_time'] as String?;
                              final notes = entry['notes'] as String?;

                              String timeStr = '';
                              if (usageTime != null) {
                                try {
                                  final time = DateTime.parse(usageTime);
                                  timeStr = DateFormat('h:mm a').format(time);
                                } catch (e) {
                                  timeStr = '';
                                }
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Time
                                    if (timeStr.isNotEmpty)
                                      Container(
                                        width: 70,
                                        child: Text(
                                          timeStr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  supervisorName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (notes != null && notes.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              notes,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Quantity
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.mediumGray),
                                      ),
                                      child: Text(
                                        '${quantityUsed.toStringAsFixed(1)} $unit',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
