import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/construction_provider.dart';
import '../providers/change_request_provider.dart';
import '../utils/app_colors.dart';

class SupervisorHistoryScreen extends StatefulWidget {
  final String? siteId;
  final String? siteName;
  final bool showRequestButton;

  const SupervisorHistoryScreen({
    super.key,
    this.siteId,
    this.siteName,
    this.showRequestButton = false,
  });

  // Static method to invalidate cache from other screens
  static void invalidateCache(String? siteId) {
    _SupervisorHistoryScreenState.invalidateCache(siteId);
  }

  @override
  State<SupervisorHistoryScreen> createState() => _SupervisorHistoryScreenState();
}

class _SupervisorHistoryScreenState extends State<SupervisorHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedDates = {};
  
  // Cache management
  static final Map<String, bool> _screenLoadedCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10); // Cache expires after 10 minutes
  
  String get _cacheKey => '${widget.siteId ?? 'all_sites'}_history';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataWithCache();
    });
  }

  void _loadDataWithCache() {
    print('🏗️ [HISTORY] Loading data for cache key: $_cacheKey');
    
    // Check if we have valid cached data
    if (_screenLoadedCache.containsKey(_cacheKey) && _cacheTimestamps.containsKey(_cacheKey)) {
      final cacheTime = _cacheTimestamps[_cacheKey]!;
      final now = DateTime.now();
      
      if (now.difference(cacheTime) < _cacheExpiry) {
        print('🎯 [HISTORY] Using cached data for $_cacheKey - skipping API calls');
        // Data is already loaded in provider, just use it
        return;
      } else {
        print('⏰ [HISTORY] Cache expired for $_cacheKey, refreshing...');
      }
    }
    
    // Load fresh data and mark as cached
    print('🔄 [HISTORY] Loading fresh data for $_cacheKey');
    context.read<ConstructionProvider>().loadSupervisorHistory(forceRefresh: true, siteId: widget.siteId);
    context.read<ChangeRequestProvider>().loadMyChangeRequests();
    
    // Mark as loaded and cache timestamp
    _screenLoadedCache[_cacheKey] = true;
    _cacheTimestamps[_cacheKey] = DateTime.now();
    print('💾 [HISTORY] Cached data for $_cacheKey');
  }

  void _forceRefresh() {
    print('🔄 [HISTORY] Force refresh requested for $_cacheKey');
    // Clear cache for this screen
    _screenLoadedCache.remove(_cacheKey);
    _cacheTimestamps.remove(_cacheKey);
    
    // Load fresh data
    context.read<ConstructionProvider>().loadSupervisorHistory(forceRefresh: true, siteId: widget.siteId);
    context.read<ChangeRequestProvider>().loadMyChangeRequests();
    
    // Mark as loaded and cache timestamp
    _screenLoadedCache[_cacheKey] = true;
    _cacheTimestamps[_cacheKey] = DateTime.now();
  }

  // Method to invalidate cache when new entries are added
  static void invalidateCache(String? siteId) {
    final cacheKey = '${siteId ?? 'all_sites'}_history';
    print('🗑️ [HISTORY] Invalidating cache for $cacheKey');
    _screenLoadedCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _expandAllDates() {
    setState(() {
      // Get all dates from both labour and material entries
      final constructionProvider = context.read<ConstructionProvider>();
      final allDates = <String>{};
      
      for (var entry in constructionProvider.labourEntries) {
        final date = entry['entry_date'] ?? '';
        if (date.isNotEmpty) allDates.add(date);
      }
      
      for (var entry in constructionProvider.materialEntries) {
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
          widget.siteName ?? 'All Sites History',
          style: const TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        actions: [
          // Expand/Collapse All Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.deepNavy),
            onSelected: (value) {
              if (value == 'expand_all') {
                _expandAllDates();
              } else if (value == 'collapse_all') {
                _collapseAllDates();
              } else if (value == 'refresh') {
                _forceRefresh();
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepNavy,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.deepNavy,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Labour'),
            Tab(text: 'Material'),
          ],
        ),
      ),
      body: Consumer2<ConstructionProvider, ChangeRequestProvider>(
        builder: (context, constructionProvider, changeProvider, child) {
          final labourEntries = constructionProvider.labourEntries;
          final materialEntries = constructionProvider.materialEntries;
          
          print('🔄 History screen rebuild - Labour: ${labourEntries.length}, Material: ${materialEntries.length}');
          
          final pendingRequestIds = <String>{};
          for (var request in changeProvider.myChangeRequests) {
            if (request['status'] == 'PENDING') {
              pendingRequestIds.add(request['entry_id'].toString());
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              print('🔄 Manual refresh triggered');
              _forceRefresh();
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryList(labourEntries, pendingRequestIds, true),
                _buildHistoryList(materialEntries, pendingRequestIds, false),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('🔄 FAB refresh triggered');
          await context.read<ConstructionProvider>().loadSupervisorHistory(forceRefresh: true, siteId: widget.siteId);
          await context.read<ChangeRequestProvider>().loadMyChangeRequests(forceRefresh: true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('History refreshed!')),
            );
          }
        },
        backgroundColor: AppColors.safetyOrange,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> entries, Set<String> pendingRequestIds, bool isLabour) {
    print('📋 Building history list - isLabour: $isLabour, entries count: ${entries.length}');
    
    // Debug: Print all entry dates
    for (var entry in entries) {
      final date = entry['entry_date'] ?? 'Unknown';
      print('📅 [HISTORY] Entry date: $date, Type: ${entry[isLabour ? 'labour_type' : 'material_type']}');
    }
    
    if (entries.isEmpty) {
      return _buildEmptyState(
        'No ${isLabour ? 'labour' : 'material'} history found',
        isLabour ? Icons.people_outline : Icons.inventory_2_outlined,
      );
    }

    // Group entries by date
    final Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var entry in entries) {
      final date = entry['entry_date'] ?? 'Unknown';
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = [];
      }
      groupedByDate[date]!.add(entry);
    }

    // Debug: Print grouped dates
    print('📅 [HISTORY] Grouped dates: ${groupedByDate.keys.toList()}');

    // Sort dates in descending order
    final sortedDates = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));
      
    print('📅 [HISTORY] Sorted dates: $sortedDates');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateEntries = groupedByDate[date]!;
        final isExpanded = _expandedDates.contains(date);

        return _buildDateCard(date, dateEntries, isExpanded, isLabour, pendingRequestIds);
      },
    );
  }

  Widget _buildDateCard(String date, List<Map<String, dynamic>> entries, bool isExpanded, bool isLabour, Set<String> pendingRequestIds) {
    final totalEntries = entries.length;
    final formattedDate = _formatDate(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dropdown Header - Always visible
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedDates.remove(date);
                  } else {
                    _expandedDates.add(date);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isExpanded ? AppColors.deepNavy.withValues(alpha: 0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded ? AppColors.deepNavy.withValues(alpha: 0.2) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Calendar Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: isExpanded ? AppColors.navyGradient : null,
                        color: isExpanded ? null : AppColors.deepNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: isExpanded ? Colors.white : AppColors.deepNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Date and Entry Count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isExpanded ? AppColors.deepNavy : AppColors.deepNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLabour 
                                      ? AppColors.safetyOrange.withValues(alpha: 0.1)
                                      : AppColors.statusCompleted.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$totalEntries ${isLabour ? 'labour' : 'material'} ${totalEntries == 1 ? 'entry' : 'entries'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isLabour ? AppColors.safetyOrange : AppColors.statusCompleted,
                                  ),
                                ),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'EXPANDED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Dropdown Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isExpanded 
                            ? AppColors.deepNavy.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.deepNavy,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Dropdown Content - Animated
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded ? Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.deepNavy.withValues(alpha: 0.1),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown Header
                      Row(
                        children: [
                          Icon(
                            isLabour ? Icons.people : Icons.inventory_2,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isLabour ? 'Labour' : 'Material'} Entries for $formattedDate',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Entry Details
                      ...entries.map((entry) {
                        return _buildEntryDetail(entry, isLabour, pendingRequestIds);
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryDetail(Map<String, dynamic> entry, bool isLabour, Set<String> pendingRequestIds) {
    final entryId = entry['id']?.toString() ?? '';
    final hasPendingRequest = pendingRequestIds.contains(entryId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPendingRequest 
              ? AppColors.safetyOrange.withValues(alpha: 0.3) 
              : AppColors.deepNavy.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entry Header with Icon and Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLabour 
                      ? AppColors.safetyOrange.withValues(alpha: 0.1)
                      : AppColors.statusCompleted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isLabour ? Icons.people : Icons.inventory_2,
                  size: 18,
                  color: isLabour ? AppColors.safetyOrange : AppColors.statusCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLabour) ..._buildLabourDetails(entry, hasPendingRequest)
                    else ..._buildMaterialDetails(entry, hasPendingRequest),
                  ],
                ),
              ),
              // Time Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatTime(entry['entry_time'] ?? entry['updated_at']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          
          // Request Change Button
          if (widget.showRequestButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: hasPendingRequest ? null : () => _showRequestChangeDialog(entry, isLabour),
                icon: Icon(
                  hasPendingRequest ? Icons.pending : Icons.edit_note,
                  size: 16,
                ),
                label: Text(
                  hasPendingRequest ? 'Change Pending' : 'Request Change',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasPendingRequest 
                      ? AppColors.textSecondary 
                      : AppColors.primaryPurple,
                  side: BorderSide(
                    color: hasPendingRequest 
                        ? AppColors.textSecondary.withValues(alpha: 0.3)
                        : AppColors.primaryPurple.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildLabourDetails(Map<String, dynamic> entry, bool hasPendingRequest) {
    return [
      Row(
        children: [
          Expanded(
            child: Text(
              entry['labour_type'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
          ),
          if (hasPendingRequest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.safetyOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Change Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.safetyOrange,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      _buildDetailRow(Icons.people, 'Workers', entry['labour_count']?.toString() ?? '0'),
      _buildDetailRow(Icons.access_time, 'Time', _formatTime(entry['entry_time'])),
      _buildDetailRow(Icons.location_on, 'Site', '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim()),
      _buildDetailRow(Icons.place, 'Location', '${entry['area'] ?? ''}, ${entry['street'] ?? ''}'.trim()),
      _buildDetailRow(Icons.person, 'Supervisor', entry['supervisor_name'] ?? 'Unknown'),
      if (entry['notes'] != null && entry['notes'].toString().isNotEmpty)
        _buildDetailRow(Icons.note, 'Notes', entry['notes']),
      // Admin-set daily rate
      if (entry['daily_rate'] != null) ...[
        const SizedBox(height: 8),
        _buildRateBadge(
          count: entry['labour_count'] as int? ?? 0,
          dailyRate: (entry['daily_rate'] as num).toDouble(),
          totalCost: (entry['total_cost'] as num?)?.toDouble(),
        ),
      ],
    ];
  }

  List<Widget> _buildMaterialDetails(Map<String, dynamic> entry, bool hasPendingRequest) {
    return [
      Row(
        children: [
          Expanded(
            child: Text(
              entry['material_type'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
          ),
          if (hasPendingRequest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.safetyOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Change Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.safetyOrange,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      _buildDetailRow(Icons.inventory_2, 'Quantity', '${entry['quantity'] ?? '0'} ${entry['unit'] ?? ''}'),
      _buildDetailRow(Icons.currency_rupee, 'Rate', '₹${entry['rate_per_unit'] ?? '0'}'),
      _buildDetailRow(Icons.calculate, 'Total', '₹${entry['total_amount'] ?? '0'}'),
      _buildDetailRow(Icons.access_time, 'Time', _formatTime(entry['timestamp'])),
      _buildDetailRow(Icons.location_on, 'Site', '${entry['customer_name'] ?? ''} ${entry['site_name'] ?? ''}'.trim()),
      _buildDetailRow(Icons.place, 'Location', '${entry['area'] ?? ''}, ${entry['street'] ?? ''}'.trim()),
      _buildDetailRow(Icons.person, 'Supervisor', entry['supervisor_name'] ?? 'Unknown'),
      if (entry['notes'] != null && entry['notes'].toString().isNotEmpty)
        _buildDetailRow(Icons.note, 'Notes', entry['notes']),
    ];
  }

  Widget _buildRateBadge({required int count, required double dailyRate, double? totalCost}) {
    final total = totalCost ?? dailyRate * count;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusCompleted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.statusCompleted.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.currency_rupee, size: 14, color: AppColors.statusCompleted),
          const SizedBox(width: 4),
          Text(
            '₹${dailyRate.toStringAsFixed(0)}/day × $count = ₹${total.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.statusCompleted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today, ${DateFormat('MMM d, yyyy').format(date)}';
      } else if (dateOnly == yesterday) {
        return 'Yesterday, ${DateFormat('MMM d, yyyy').format(date)}';
      } else {
        return DateFormat('EEEE, MMM d, yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  void _showRequestChangeDialog(Map<String, dynamic> entry, bool isLabour) {
    final entryId = entry['id']?.toString() ?? '';
    final entryType = isLabour ? 'labour' : 'material';
    
    final requestMessageController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Request Change',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entry Type: ${isLabour ? 'Labour' : 'Material'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Reason for change request:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: requestMessageController,
                  maxLines: 4,
                  autofocus: true,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Explain why you need this change...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () {
                requestMessageController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                final message = requestMessageController.text.trim();
                
                if (message.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for the change request'),
                      backgroundColor: AppColors.safetyOrange,
                    ),
                  );
                  return;
                }
                
                setState(() => isSubmitting = true);
                
                // Submit the change request
                final provider = Provider.of<ChangeRequestProvider>(dialogContext, listen: false);
                final result = await provider.requestChange(
                  entryId: entryId,
                  entryType: entryType,
                  requestMessage: message,
                );
                
                // Dispose controller
                requestMessageController.dispose();
                
                // Close dialog
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                
                // Show result and refresh - use the parent context
                if (mounted) {
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Change request sent successfully!'),
                        backgroundColor: AppColors.statusCompleted,
                      ),
                    );
                    
                    // Refresh the history data
                    Provider.of<ConstructionProvider>(this.context, listen: false)
                        .loadSupervisorHistory(forceRefresh: true, siteId: widget.siteId);
                    Provider.of<ChangeRequestProvider>(this.context, listen: false)
                        .loadMyChangeRequests(forceRefresh: true);
                  } else {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Failed: ${result['error'] ?? 'Unknown error'}'),
                        backgroundColor: AppColors.statusOverdue,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {bool isNumeric = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
