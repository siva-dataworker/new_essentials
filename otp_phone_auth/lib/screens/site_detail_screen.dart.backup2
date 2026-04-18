import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../services/material_service.dart';
import '../services/budget_management_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/time_validator.dart';
import 'supervisor_history_screen.dart';
import 'supervisor_photo_upload_screen.dart';

class SiteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  final _constructionService = ConstructionService();
  
  // Cache for site-specific data
  static final Map<String, Map<String, dynamic>?> _siteDataCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5); // Cache expires after 5 minutes
  
  Map<String, dynamic>? _todayEntries;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String get _siteId => widget.site['id'].toString();
  String get _cacheKey => '${_siteId}_${_selectedDate.toIso8601String().split('T')[0]}';
  
  // Dropdown functionality
  final Set<String> _expandedDates = {};

  @override
  void initState() {
    super.initState();
    _loadTodayEntriesWithCache();
  }

  Future<void> _loadTodayEntriesWithCache() async {
    print('🏗️ [SITE_DETAIL] Loading entries for site: $_siteId, date: $_selectedDate');
    
    // Check if we have valid cached data
    if (_siteDataCache.containsKey(_cacheKey) && _cacheTimestamps.containsKey(_cacheKey)) {
      final cacheTime = _cacheTimestamps[_cacheKey]!;
      final now = DateTime.now();
      
      if (now.difference(cacheTime) < _cacheExpiry) {
        print('🎯 [SITE_DETAIL] Using cached data for $_cacheKey');
        setState(() {
          _todayEntries = _siteDataCache[_cacheKey];
          _isLoading = false;
        });
        return;
      } else {
        print('⏰ [SITE_DETAIL] Cache expired for $_cacheKey, refreshing...');
      }
    }
    
    // Load fresh data
    await _loadTodayEntries();
  }

  Future<void> _loadTodayEntries() async {
    print('🔄 [SITE_DETAIL] Loading fresh data for site: $_siteId, date: $_selectedDate');
    setState(() => _isLoading = true);
    
    try {
      final entries = await _constructionService.getEntriesByDate(
        widget.site['id'],
        _selectedDate,
      );
      
      // Cache the data (handle null case)
      if (entries != null) {
        _siteDataCache[_cacheKey] = entries;
        _cacheTimestamps[_cacheKey] = DateTime.now();
        print('💾 [SITE_DETAIL] Cached data for $_cacheKey');
      }
      
      setState(() {
        _todayEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [SITE_DETAIL] Error loading entries: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Use cached loading when date changes
      _loadTodayEntriesWithCache();
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuickActionsSheet(
        onLabourTap: () {
          Navigator.pop(context);
          _showLabourEntry();
        },
        onMaterialTap: () {
          Navigator.pop(context);
          _showMaterialEntry();
        },
        onPhotoTap: () {
          Navigator.pop(context);
          _showPhotoUpload();
        },
        onHistoryTap: () {
          Navigator.pop(context);
          _openHistory();
        },
      ),
    );
  }

  void _showLabourEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // Reduced opacity for less blur
      enableDrag: true,
      isDismissible: true,
      builder: (context) => _LabourEntrySheet(
        siteId: widget.site['id'],
        onSuccess: () {
          // Invalidate cache and reload
          _invalidateCache();
          _loadTodayEntries();
          // Also invalidate history screen cache
          SupervisorHistoryScreen.invalidateCache(widget.site['id']);
        },
      ),
    );
  }

  void _showMaterialEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3), // Reduced opacity for less blur
      enableDrag: true,
      isDismissible: true,
      builder: (context) => _MaterialEntrySheet(
        siteId: widget.site['id'],
        onSuccess: () {
          // Invalidate cache and reload
          _invalidateCache();
          _loadTodayEntries();
          // Also invalidate history screen cache
          SupervisorHistoryScreen.invalidateCache(widget.site['id']);
        },
        onMaterialUpdated: () {
          // Reload available materials when material usage is submitted
          _loadTodayEntries();
        },
      ),
    );
  }

  void _invalidateCache() {
    print('🗑️ [SITE_DETAIL] Invalidating cache for site: $_siteId');
    // Remove all cache entries for this site
    _siteDataCache.removeWhere((key, value) => key.startsWith(_siteId));
    _cacheTimestamps.removeWhere((key, value) => key.startsWith(_siteId));
  }

  void _expandAllDates() {
    setState(() {
      // Get all dates from entries
      final allDates = <String>{};
      
      if (_todayEntries?['labour_entries'] != null) {
        for (var entry in _todayEntries!['labour_entries']) {
          final date = entry['entry_date'] ?? _formatSelectedDate();
          allDates.add(date);
        }
      }
      
      if (_todayEntries?['material_entries'] != null) {
        for (var entry in _todayEntries!['material_entries']) {
          final date = entry['entry_date'] ?? _formatSelectedDate();
          allDates.add(date);
        }
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
  void dispose() {
    // Optional: Clear cache for this site when screen is disposed
    // Uncomment if you want to clear cache on dispose
    // _invalidateCache();
    super.dispose();
  }

  // Method to force refresh data
  Future<void> _forceRefresh() async {
    _invalidateCache();
    await _loadTodayEntries();
  }

  void _showPhotoUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupervisorPhotoUploadScreen(site: widget.site),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupervisorHistoryScreen(
          siteId: widget.site['id'],
          siteName: widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site',
          showRequestButton: true, // Enable request button in site-specific history
        ),
      ),
    );
  }

  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  String _formatSelectedDate() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  String _formatShortDate() {
    if (_isToday()) {
      return 'Today';
    }
    
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (_selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day) {
      return 'Yesterday';
    }
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      body: RefreshIndicator(
        onRefresh: _forceRefresh,
        color: AppColors.safetyOrange,
        child: CustomScrollView(
          slivers: [
            // Site Header
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.deepNavy,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _selectDate,
                  tooltip: 'Select Date',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
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
                          Icon(Icons.expand_more, size: 20),
                          SizedBox(width: 12),
                          Text('Expand All'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'collapse_all',
                      child: Row(
                        children: [
                          Icon(Icons.expand_less, size: 20),
                          SizedBox(width: 12),
                          Text('Collapse All'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 20),
                          SizedBox(width: 12),
                          Text('Refresh Data'),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () => _openHistory(),
                  tooltip: 'View History',
                ),
              ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.lightSlate,
                          AppColors.deepNavy.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.construction, size: 100, color: Colors.white54),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.site['display_name'] ?? 'Site',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.site['area']} - ${widget.site['street']}',
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.safetyOrange),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '65% Complete',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Today's Entries with Dropdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isToday() ? "Today's Entries" : "Entries for ${_formatSelectedDate()}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: AppColors.deepNavy,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatShortDate(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // IST Time Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.statusCompleted),
                        const SizedBox(width: 6),
                        Text(
                          'IST: ${TimeValidator.formatISTTime(TimeValidator.getISTTime())}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusCompleted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
                  else if (_todayEntries == null || (_todayEntries!['labour_entries']?.isEmpty ?? true) && (_todayEntries!['material_entries']?.isEmpty ?? true))
                    _buildEmptyState()
                  else
                    _buildEntriesWithDropdown(),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
      floatingActionButton: _buildCentralFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightSlate,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_circle_outline, size: 40, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 16),
          Text(
            _isToday() ? 'No entries yet today' : 'No entries for this date',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 8),
          Text(
            _isToday() 
                ? 'Tap the + button to add labour or materials'
                : 'No data was recorded on this date',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesWithDropdown() {
    // Group entries by date and type
    final Map<String, Map<String, List<Map<String, dynamic>>>> groupedEntries = {};
    
    // Process labour entries
    if (_todayEntries?['labour_entries'] != null) {
      for (var entry in _todayEntries!['labour_entries']) {
        final date = entry['entry_date'] ?? _formatSelectedDate();
        if (!groupedEntries.containsKey(date)) {
          groupedEntries[date] = {'labour': [], 'material': []};
        }
        groupedEntries[date]!['labour']!.add(entry);
      }
    }
    
    // Process material entries
    if (_todayEntries?['material_entries'] != null) {
      for (var entry in _todayEntries!['material_entries']) {
        final date = entry['entry_date'] ?? _formatSelectedDate();
        if (!groupedEntries.containsKey(date)) {
          groupedEntries[date] = {'labour': [], 'material': []};
        }
        groupedEntries[date]!['material']!.add(entry);
      }
    }
    
    // If no entries, show empty state
    if (groupedEntries.isEmpty) {
      return _buildEmptyState();
    }
    
    // Sort dates (most recent first)
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    return Column(
      children: sortedDates.map((date) {
        final dateEntries = groupedEntries[date]!;
        final labourEntries = dateEntries['labour']!;
        final materialEntries = dateEntries['material']!;
        
        if (labourEntries.isEmpty && materialEntries.isEmpty) return const SizedBox.shrink();
        
        return _buildDateDropdownCard(date, labourEntries, materialEntries);
      }).toList(),
    );
  }

  Widget _buildDateDropdownCard(String date, List<Map<String, dynamic>> labourEntries, List<Map<String, dynamic>> materialEntries) {
    final isExpanded = _expandedDates.contains(date);
    final formattedDate = _formatDateForDropdown(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
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
                              color: AppColors.deepNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (labourEntries.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.safetyOrange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${labourEntries.length} labour',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.safetyOrange,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (materialEntries.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusCompleted.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${materialEntries.length} material',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.statusCompleted,
                                    ),
                                  ),
                                ),
                              ],
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
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.deepNavy,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expandable Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded ? Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: AppColors.lightSlate, height: 1),
                  const SizedBox(height: 16),
                  // Labour entries
                  ...labourEntries.map((entry) => _buildLabourCard(entry)),
                  // Material entries
                  ...materialEntries.map((entry) => _buildMaterialCard(entry)),
                ],
              ),
            ) : null,
          ),
        ],
      ),
    );
  }

  String _formatDateForDropdown(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);
      
      if (entryDate == today) {
        return 'Today • ${_formatDateWithDay(date)}';
      } else if (entryDate == yesterday) {
        return 'Yesterday • ${_formatDateWithDay(date)}';
      } else {
        return _formatDateWithDay(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateWithDay(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[date.weekday % 7];
    return '$dayName, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildLabourCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.safetyOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.safetyOrange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['labour_type'] ?? 'General',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry['labour_count']} workers',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (entry['entry_time'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Time: ${entry['entry_time']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry['labour_count']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusCompleted.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.statusCompleted.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['material_type'] ?? 'Material',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry['quantity']} ${entry['unit'] ?? 'units'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (entry['entry_time'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Time: ${entry['entry_time']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${entry['quantity']?.toString() ?? '0'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.statusCompleted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralFAB() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyOrange.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showQuickActions,
          borderRadius: BorderRadius.circular(32),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

// Quick Actions Sheet
class _QuickActionsSheet extends StatelessWidget {
  final VoidCallback onLabourTap;
  final VoidCallback onMaterialTap;
  final VoidCallback onPhotoTap;
  final VoidCallback onHistoryTap;

  const _QuickActionsSheet({
    required this.onLabourTap,
    required this.onMaterialTap,
    required this.onPhotoTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            icon: Icons.people_outline,
            title: 'Labour Count',
            subtitle: 'Add workers by type',
            color: AppColors.deepNavy,
            onTap: onLabourTap,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.inventory_2_outlined,
            title: 'Material Balance',
            subtitle: 'Update materials',
            color: AppColors.statusCompleted,
            onTap: onMaterialTap,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.add_a_photo_outlined,
            title: 'Add Photo',
            subtitle: 'Upload site progress pictures',
            color: AppColors.safetyOrange,
            onTap: onPhotoTap,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.history_outlined,
            title: 'View History',
            subtitle: 'Labour, materials & modifications',
            color: Color(0xFF6366F1),
            onTap: onHistoryTap,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// Labour Entry Sheet with Multiple Types
class _LabourEntrySheet extends StatefulWidget {
  final String siteId;
  final VoidCallback onSuccess;

  const _LabourEntrySheet({required this.siteId, required this.onSuccess});

  @override
  State<_LabourEntrySheet> createState() => _LabourEntrySheetState();
}

class _LabourEntrySheetState extends State<_LabourEntrySheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _constructionService = ConstructionService();
  final _budgetService = BudgetManagementService();
  
  // Morning labour counts
  final Map<String, int> _morningLabourCounts = {
    'Carpenter': 0,
    'Mason': 0,
    'Electrician': 0,
    'Plumber': 0,
    'Painter': 0,
    'Helper': 0,
    'General': 0,
    'Tile Layer': 0,
    'Tile Layerhelper': 0,
    'Kambi Fitter': 0,
    'Concrete Kot': 0,
    'Pile Labour': 0,
  };
  
  // Evening labour counts
  final Map<String, int> _eveningLabourCounts = {
    'Carpenter': 0,
    'Mason': 0,
    'Electrician': 0,
    'Plumber': 0,
    'Painter': 0,
    'Helper': 0,
    'General': 0,
    'Tile Layer': 0,
    'Tile Layerhelper': 0,
    'Kambi Fitter': 0,
    'Concrete Kot': 0,
    'Pile Labour': 0,
  };

  // Morning data for evening display
  Map<String, dynamic>? _morningData;
  bool _isLoadingMorningData = false;

  // Evening history data
  List<Map<String, dynamic>> _eveningHistoryData = [];
  bool _isLoadingEveningData = false;

  // Default salary rates (used if admin hasn't set custom rates)
  // Rates loaded from admin global rates (single source of truth)
  Map<String, double> _rates = {};

  final _morningExtraCostController = TextEditingController();
  final _morningExtraCostNotesController = TextEditingController();
  final _eveningExtraCostController = TextEditingController();
  final _eveningExtraCostNotesController = TextEditingController();
  bool _isSubmitting = false;
  late DateTime _morningSelectedDateTime;
  late DateTime _eveningSelectedDateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Load both morning data and evening history when evening tab is opened
        if (_eveningHistoryData.isEmpty) {
          _loadEveningHistory();
        }
        _loadMorningData();
      }
    });
    _morningSelectedDateTime = DateTime.now();
    _eveningSelectedDateTime = DateTime.now();
    _fetchRates();
  }

  Future<void> _loadMorningData() async {
    setState(() => _isLoadingMorningData = true);
    try {
      print('🔍 Loading morning data for site: ${widget.siteId}');
      final response = await _constructionService.getHistoryByDay(siteId: widget.siteId);
      
      if (response['success']) {
        final data = response['data'] as Map<String, dynamic>;
        final labourByDay = data['labour_by_day'] as Map<String, dynamic>? ?? {};
        
        // Get today's day of week (e.g., "Tuesday")
        final today = DateTime.now();
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final todayDayName = dayNames[today.weekday - 1];
        
        // Get today's date in YYYY-MM-DD format for filtering
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        
        print('📅 Today is: $todayDayName ($todayStr)');
        print('📦 Available days in response: ${labourByDay.keys.toList()}');
        
        // Get entries for today's day of week, then filter by actual date
        List<Map<String, dynamic>> todayEntries = [];
        
        if (labourByDay.containsKey(todayDayName)) {
          final dayEntries = labourByDay[todayDayName] as List;
          print('✅ Found ${dayEntries.length} entries for $todayDayName');
          
          for (var entry in dayEntries) {
            final entryDate = entry['entry_date'] as String?;
            print('  - Checking entry: ${entry['labour_type']} on date $entryDate');
            
            // Only include entries from today's actual date
            if (entryDate != null && entryDate.startsWith(todayStr)) {
              todayEntries.add(Map<String, dynamic>.from(entry));
              print('    ✅ Added: ${entry['labour_type']}: ${entry['labour_count']} workers');
            } else {
              print('    ❌ Skipped: date $entryDate does not match $todayStr');
            }
          }
        } else {
          print('❌ No entries found for $todayDayName');
        }
        
        print('✅ Total entries loaded for today: ${todayEntries.length}');
        
        setState(() {
          _morningData = todayEntries.isNotEmpty 
              ? {'entries': todayEntries} 
              : null;
        });
      } else {
        print('❌ Failed to load morning data: ${response['error']}');
      }
    } catch (e) {
      print('❌ Error loading morning data: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      setState(() => _isLoadingMorningData = false);
    }
  }

  Future<void> _loadEveningHistory() async {
    setState(() => _isLoadingEveningData = true);
    try {
      print('🔍 Loading evening history for site: ${widget.siteId}');
      final response = await _constructionService.getHistoryByDay(siteId: widget.siteId);
      
      if (response['success']) {
        final data = response['data'] as Map<String, dynamic>;
        final labourByDay = data['labour_by_day'] as Map<String, dynamic>? ?? {};
        
        // Get today's date in YYYY-MM-DD format
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        
        // Filter entries to only include today's data
        List<Map<String, dynamic>> todayEntries = [];
        labourByDay.forEach((day, entries) {
          if (entries is List && day == todayStr) {
            todayEntries.addAll(List<Map<String, dynamic>>.from(entries));
          }
        });
        
        print('✅ Loaded ${todayEntries.length} evening labour entries for today ($todayStr)');
        
        setState(() {
          _eveningHistoryData = todayEntries;
        });
      } else {
        print('❌ Failed to load evening history: ${response['error']}');
      }
    } catch (e) {
      print('❌ Error loading evening history: $e');
    } finally {
      setState(() => _isLoadingEveningData = false);
    }
  }

  Future<void> _fetchRates() async {
    final rates = await _budgetService.getLabourRates('global');
    if (rates.isNotEmpty && mounted) {
      final Map<String, double> loaded = {};
      for (final r in rates) {
        final type = r['labour_type'] as String?;
        final rate = (r['daily_rate'] as num?)?.toDouble();
        if (type != null && rate != null) loaded[type] = rate;
      }
      setState(() => _rates = loaded);
    }
  }

  // Get current tab's labour counts
  Map<String, int> get _currentLabourCounts => 
      _tabController.index == 0 ? _morningLabourCounts : _eveningLabourCounts;

  int get _totalCount => _currentLabourCounts.values.fold(0, (sum, count) => sum + count);

  double get _totalSalary => _currentLabourCounts.entries.fold(
        0,
        (sum, e) => sum + e.value * (_rates[e.key] ?? 0),
      );

  @override
  void dispose() {
    _tabController.dispose();
    _morningExtraCostController.dispose();
    _morningExtraCostNotesController.dispose();
    _eveningExtraCostController.dispose();
    _eveningExtraCostNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                '👷 Labour Count',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Workers: $_totalCount',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₹${_totalSalary.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Time window info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TimeValidator.isLabourEntryOnTime() 
                ? Colors.green.shade50 
                : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TimeValidator.isLabourEntryOnTime() 
                  ? Colors.green.shade200 
                  : Colors.orange.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  TimeValidator.isLabourEntryOnTime() ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: TimeValidator.isLabourEntryOnTime() 
                    ? Colors.green.shade700 
                    : Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TimeValidator.isLabourEntryOnTime()
                      ? '${TimeValidator.getLabourTimeWindow()} • Current: ${TimeValidator.formatISTTime(TimeValidator.getISTTime())}'
                      : '⚠️ Late Entry! ${TimeValidator.getLabourTimeWindow()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: TimeValidator.isLabourEntryOnTime() 
                        ? Colors.green.shade700 
                        : Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSlate,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: '🌅 Morning'),
                Tab(text: '🌆 Evening'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(true),  // Morning
                _buildTabContent(false), // Evening
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isMorning) {
    // For evening tab, show morning data in read-only format
    if (!isMorning) {
      return _buildEveningDisplayContent();
    }
    
    // Morning tab - editable form
    final labourCounts = _morningLabourCounts;
    final extraCostController = _morningExtraCostController;
    final extraCostNotesController = _morningExtraCostNotesController;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Time Picker Section
        _buildTimePicker(isMorning),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 300,
          child: ListView(
            children: labourCounts.keys.map((type) => _buildLabourTypeRow(type, isMorning)).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Extra Cost Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Extra Cost (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: extraCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount (₹)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                  ),
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.orange.shade700),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: extraCostNotesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Notes (e.g., transport, tools)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _totalCount > 0 && !_isSubmitting ? () => _submit(isMorning) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.safetyOrange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  'Submit ${isMorning ? "Morning" : "Evening"} Labour Count',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ],
    ),
    );
  }

  Widget _buildEveningDisplayContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's Labour Entries Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Labour Entries',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _isLoadingMorningData 
                            ? 'Loading...' 
                            : _morningData != null 
                                ? '${(_morningData!['entries'] as List).length} entries found'
                                : 'No entries yet',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingMorningData)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display morning entries
          if (_isLoadingMorningData)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.safetyOrange),
              ),
            )
          else if (_morningData != null && _morningData!['entries'] != null)
            ..._buildMorningEntriesDisplay(_morningData!['entries'] as List<Map<String, dynamic>>)
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.wb_sunny_outlined, size: 48, color: Colors.orange.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No labour entries found for today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Evening History Section
          if (_isLoadingEveningData)
            const Center(
              child: CircularProgressIndicator(color: AppColors.safetyOrange),
            )
          else if (_eveningHistoryData.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nightlight_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Evening History Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No evening labour entries have been submitted yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._buildEveningHistoryDisplay(),
        ],
      ),
    );
  }

  List<Widget> _buildMorningEntriesDisplay(List<Map<String, dynamic>> entries) {
    // Calculate totals
    int totalWorkers = 0;
    double totalSalary = 0.0;
    double totalExtraCost = 0.0;
    
    for (final entry in entries) {
      totalWorkers += (entry['labour_count'] as num?)?.toInt() ?? 0;
      final labourType = entry['labour_type'] as String? ?? 'General';
      final count = (entry['labour_count'] as num?)?.toInt() ?? 0;
      final rate = _rates[labourType] ?? 600;
      totalSalary += count * rate;
      totalExtraCost += (entry['extra_cost'] as num?)?.toDouble() ?? 0.0;
    }

    return [
      // Summary card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$totalWorkers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                Text(
                  'Workers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.orange.shade300,
            ),
            Column(
              children: [
                Text(
                  '₹${totalSalary.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Total Cost',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (totalExtraCost > 0) ...[
              Container(
                width: 1,
                height: 40,
                color: Colors.orange.shade300,
              ),
              Column(
                children: [
                  Text(
                    '₹${totalExtraCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  Text(
                    'Extra Cost',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Labour entries
      ...entries.map((entry) {
        final labourType = entry['labour_type'] as String? ?? 'General';
        final count = (entry['labour_count'] as num?)?.toInt() ?? 0;
        final entryTime = entry['entry_time'] as String?;
        final notes = entry['notes'] as String?;
        final extraCost = (entry['extra_cost'] as num?)?.toDouble() ?? 0.0;
        final extraCostNotes = entry['extra_cost_notes'] as String?;
        
        return _buildHistoryLabourRow(
          labourType,
          count,
          entryTime,
          notes,
          extraCost,
          extraCostNotes,
        );
      }).toList(),
    ];
  }

  List<Widget> _buildEveningHistoryDisplay() {
    // Group entries by date for better display
    final entriesByDate = <String, List<Map<String, dynamic>>>{};
    for (final entry in _eveningHistoryData) {
      final date = entry['entry_date'] as String? ?? 'Unknown';
      if (!entriesByDate.containsKey(date)) {
        entriesByDate[date] = [];
      }
      entriesByDate[date]!.add(entry);
    }

    // Sort dates in descending order (most recent first)
    final sortedDates = entriesByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade700, Colors.indigo.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.nightlight, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evening History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_eveningHistoryData.length} entries found',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Display entries grouped by date
      ...sortedDates.map((date) {
        final entries = entriesByDate[date]!;
        
        // Calculate totals for this date
        int totalWorkers = 0;
        double totalSalary = 0.0;
        double totalExtraCost = 0.0;
        
        for (final entry in entries) {
          totalWorkers += (entry['labour_count'] as num?)?.toInt() ?? 0;
          // Calculate salary based on labour type and count
          final labourType = entry['labour_type'] as String? ?? 'General';
          final count = (entry['labour_count'] as num?)?.toInt() ?? 0;
          final rate = _rates[labourType] ?? 600;
          totalSalary += count * rate;
          totalExtraCost += (entry['extra_cost'] as num?)?.toDouble() ?? 0.0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.deepNavy),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$totalWorkers workers • ₹${totalSalary.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Labour entries for this date
            ...entries.map((entry) {
              final labourType = entry['labour_type'] as String? ?? 'General';
              final count = (entry['labour_count'] as num?)?.toInt() ?? 0;
              final entryTime = entry['entry_time'] as String?;
              final notes = entry['notes'] as String?;
              final extraCost = (entry['extra_cost'] as num?)?.toDouble() ?? 0.0;
              final extraCostNotes = entry['extra_cost_notes'] as String?;
              
              return _buildHistoryLabourRow(
                labourType,
                count,
                entryTime,
                notes,
                extraCost,
                extraCostNotes,
              );
            }),
            
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    ];
  }

  Widget _buildHistoryLabourRow(
    String type,
    int count,
    String? entryTime,
    String? notes,
    double extraCost,
    String? extraCostNotes,
  ) {
    final icon = _getLabourIcon(type);
    final rate = _rates[type] ?? 600;
    final rowTotal = count * rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.deepNavy.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    if (entryTime != null)
                      Text(
                        'Time: ${_formatTimeFromString(entryTime)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$count workers',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  Text(
                    '₹${rowTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Notes
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Extra cost
          if (extraCost > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Extra Cost: ₹${extraCost.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  if (extraCostNotes != null && extraCostNotes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      extraCostNotes,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildReadOnlyLabourRow(String type, int count) {
    final icon = _getLabourIcon(type);
    final rate = _rates[type] ?? 0;
    final rowTotal = count * rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.deepNavy.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                Text(
                  '₹${rate.toStringAsFixed(0)}/day × $count = ₹${rowTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeFromString(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return isoTime;
    }
  }

  Widget _buildLabourTypeRow(String type, bool isMorning) {
    final labourCounts = isMorning ? _morningLabourCounts : _eveningLabourCounts;
    final count = labourCounts[type]!;
    final icon = _getLabourIcon(type);
    final rate = _rates[type] ?? 0;
    final rowTotal = count * rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: count > 0 ? AppColors.deepNavy.withValues(alpha: 0.05) : AppColors.lightSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: count > 0 ? AppColors.deepNavy.withValues(alpha: 0.2) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: count > 0 ? AppColors.deepNavy : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: count > 0 ? FontWeight.bold : FontWeight.w500,
                    color: count > 0 ? AppColors.deepNavy : AppColors.textSecondary,
                  ),
                ),
                Text(
                  count > 0
                      ? '₹${rate.toStringAsFixed(0)}/day × $count = ₹${rowTotal.toStringAsFixed(0)}'
                      : '₹${rate.toStringAsFixed(0)}/day',
                  style: TextStyle(
                    fontSize: 12,
                    color: count > 0 ? Colors.green.shade700 : AppColors.textSecondary,
                    fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => labourCounts[type] = (count - 1).clamp(0, 50)),
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                color: count > 0 ? AppColors.safetyOrange : AppColors.textSecondary,
              ),
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  gradient: count > 0 ? AppColors.orangeGradient : null,
                  color: count == 0 ? AppColors.lightSlate : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: count > 0 ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => labourCounts[type] = (count + 1).clamp(0, 50)),
                icon: const Icon(Icons.add_circle_outline, size: 32),
                color: AppColors.safetyOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLabourIcon(String type) {
    switch (type) {
      case 'Carpenter': return Icons.carpenter;
      case 'Mason': return Icons.construction;
      case 'Electrician': return Icons.electrical_services;
      case 'Plumber': return Icons.plumbing;
      case 'Painter': return Icons.format_paint;
      case 'Helper': return Icons.handyman;
      case 'Tile Layer': return Icons.layers;
      case 'Tile Layerhelper': return Icons.layers_outlined;
      case 'Kambi Fitter': return Icons.build;
      case 'Concrete Kot': return Icons.foundation;
      case 'Pile Labour': return Icons.vertical_align_bottom;
      default: return Icons.person;
    }
  }

  Future<void> _submit(bool isMorning) async {
    final labourCounts = isMorning ? _morningLabourCounts : _eveningLabourCounts;
    final extraCostController = isMorning ? _morningExtraCostController : _eveningExtraCostController;
    final extraCostNotesController = isMorning ? _morningExtraCostNotesController : _eveningExtraCostNotesController;
    final selectedDateTime = isMorning ? _morningSelectedDateTime : _eveningSelectedDateTime;
    
    // Check if labour entry is on time
    final isOnTime = TimeValidator.isLabourEntryOnTime();
    
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmationDialog(
        title: 'Confirm ${isMorning ? "Morning" : "Evening"} Labour Entry',
        entries: labourCounts.entries
            .where((e) => e.value > 0)
            .map((e) => {'type': e.key, 'count': e.value})
            .toList(),
        totalCount: _totalCount,
        isLabour: true,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    
    // Parse extra cost
    final extraCost = double.tryParse(extraCostController.text.trim()) ?? 0;
    final extraCostNotes = extraCostNotesController.text.trim();
    
    print('🕒 [LABOUR] About to submit with selected time: $selectedDateTime');
    print('🕒 [LABOUR] Current IST time: ${TimeValidator.getISTTime()}');
    print('🕒 [LABOUR] Is on time: $isOnTime');
    
    // Submit each labour type with count > 0
    final errors = <String>[];
    int successCount = 0;

    for (final entry in labourCounts.entries) {
      if (entry.value > 0) {
        final result = await _constructionService.submitLabourCount(
          siteId: widget.siteId,
          labourCount: entry.value,
          labourType: entry.key,
          extraCost: extraCost > 0 ? extraCost : null,
          extraCostNotes: extraCostNotes.isNotEmpty ? extraCostNotes : null,
          customDateTime: selectedDateTime,
        );
        if (result['success'] == true) {
          successCount++;
        } else {
          errors.add('${entry.key}: ${result['error'] ?? 'Failed'}');
        }
      }
    }

    // Send notification to admin if entry is late
    if (!isOnTime && successCount > 0) {
      final notificationService = NotificationService();
      await notificationService.sendLateEntryNotification(
        siteId: widget.siteId,
        entryType: 'labour',
        message: TimeValidator.getLabourLateMessage(),
        actualTime: TimeValidator.getISTTime(),
      );
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (errors.isEmpty) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOnTime 
                ? '$successCount labour types submitted successfully!'
                : '⚠️ $successCount labour types submitted (Late entry - Admin notified)',
            ),
            backgroundColor: isOnTime ? AppColors.statusCompleted : Colors.orange,
            duration: Duration(seconds: isOnTime ? 2 : 4),
          ),
        );
      } else if (successCount > 0) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount submitted. Errors: ${errors.join(', ')}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${errors.first}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildTimePicker(bool isMorning) {
    final selectedDateTime = isMorning ? _morningSelectedDateTime : _eveningSelectedDateTime;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.deepNavy),
              const SizedBox(width: 8),
              const Text(
                'Entry Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Date — read-only (today's date, not selectable)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightSlate,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateTime(selectedDateTime),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Time — tappable
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(isMorning),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 18, color: AppColors.deepNavy),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(selectedDateTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Today: ${_formatDateTime(selectedDateTime)} • Tap time to change',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(bool isMorning) async {
    final selectedDateTime = isMorning ? _morningSelectedDateTime : _eveningSelectedDateTime;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningSelectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            picked.hour,
            picked.minute,
          );
        } else {
          _eveningSelectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            picked.hour,
            picked.minute,
          );
        }
      });
      print('🕒 [LABOUR] ${isMorning ? "Morning" : "Evening"} time changed to: ${isMorning ? _morningSelectedDateTime : _eveningSelectedDateTime}');
    }
  }
}

// Material Entry Sheet with Multiple Types
class _MaterialEntrySheet extends StatefulWidget {
  final String siteId;
  final VoidCallback onSuccess;
  final VoidCallback? onMaterialUpdated;

  const _MaterialEntrySheet({
    required this.siteId, 
    required this.onSuccess,
    this.onMaterialUpdated,
  });

  @override
  State<_MaterialEntrySheet> createState() => _MaterialEntrySheetState();
}

class _MaterialEntrySheetState extends State<_MaterialEntrySheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _constructionService = ConstructionService();
  final _materialService = MaterialService();
  Map<String, double> _materialQuantities = {};
  List<Map<String, dynamic>> _availableMaterials = [];
  bool _isLoadingMaterials = false;
  final _extraCostController = TextEditingController();
  final _extraCostNotesController = TextEditingController();
  bool _isSubmitting = false;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with current local time
    _selectedDateTime = DateTime.now();
    print('🕒 [MATERIAL] Initialized with local time: $_selectedDateTime');
    
    // Load materials from inventory
    _loadAvailableMaterials();
  }
  
  Future<void> _loadAvailableMaterials() async {
    setState(() => _isLoadingMaterials = true);
    
    try {
      final result = await _materialService.getMaterialBalance(widget.siteId);
      
      if (result['success'] == true) {
        final materials = List<Map<String, dynamic>>.from(result['balance'] ?? []);
        setState(() {
          _availableMaterials = materials;
          // Initialize quantities map with available materials
          _materialQuantities = {
            for (var material in materials)
              material['material_type'] as String: 0.0
          };
        });
      }
    } catch (e) {
      print('Error loading materials: $e');
    } finally {
      setState(() => _isLoadingMaterials = false);
    }
  }

  int get _totalItems => _materialQuantities.values.where((q) => q > 0).length;

  @override
  void dispose() {
    _tabController.dispose();
    _extraCostController.dispose();
    _extraCostNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                '📦 Material Balance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalItems items',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Time window info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TimeValidator.isMaterialEntryOnTime() 
                ? Colors.green.shade50 
                : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TimeValidator.isMaterialEntryOnTime() 
                  ? Colors.green.shade200 
                  : Colors.orange.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  TimeValidator.isMaterialEntryOnTime() ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: TimeValidator.isMaterialEntryOnTime() 
                    ? Colors.green.shade700 
                    : Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TimeValidator.isMaterialEntryOnTime()
                      ? '${TimeValidator.getMaterialTimeWindow()} • Current: ${TimeValidator.formatISTTime(TimeValidator.getISTTime())}'
                      : '⚠️ Outside Time Window! ${TimeValidator.getMaterialTimeWindow()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: TimeValidator.isMaterialEntryOnTime() 
                        ? Colors.green.shade700 
                        : Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSlate,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: '📝 Update'),
                Tab(text: '📊 Available'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpdateTab(),
                _buildAvailableTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update Tab - Current functionality for material usage
  Widget _buildUpdateTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimePicker(),
          const SizedBox(height: 16),
          if (_isLoadingMaterials)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_materialQuantities.isEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightSlate,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'No materials available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Site Engineer needs to add materials first',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _materialQuantities.keys.map((type) => _buildMaterialTypeRow(type)).toList(),
            ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Extra Cost (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _extraCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount (₹)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                  ),
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.orange.shade700),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _extraCostNotesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Notes (e.g., transport, tools)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _totalItems > 0 && !_isSubmitting ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusCompleted,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Submit Material Balance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ],
    ),
    );
  }

  // Available Tab - Shows current balance of materials
  Widget _buildAvailableTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _isLoadingMaterials
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : _availableMaterials.isEmpty
                ? Container(
                    height: 400,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lightSlate,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text(
                            'No materials available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Site Engineer needs to add materials to inventory first',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _availableMaterials.length,
                      itemBuilder: (context, index) {
                        final material = _availableMaterials[index];
                        return _buildAvailableMaterialCard(material);
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildAvailableMaterialCard(Map<String, dynamic> material) {
    final materialType = material['material_type'] as String;
    final currentBalance = (material['current_balance'] as num?)?.toDouble() ?? 0.0;
    final totalUsed = (material['total_used'] as num?)?.toDouble() ?? 0.0;
    final unit = material['unit'] as String? ?? 'units';
    final icon = _getMaterialIcon(materialType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.statusCompleted.withValues(alpha: 0.1),
            AppColors.statusCompleted.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materialType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit: $unit',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.inventory, color: AppColors.statusCompleted, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentBalance.toInt()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusCompleted,
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: AppColors.borderColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.trending_down, color: AppColors.safetyOrange, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Total Used',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalUsed.toInt()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.safetyOrange,
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialTypeRow(String type) {
    final quantity = _materialQuantities[type]!;
    
    // Find the material data from available materials
    final materialData = _availableMaterials.firstWhere(
      (m) => m['material_type'] == type,
      orElse: () => {},
    );
    
    final availableBalance = (materialData['current_balance'] as num?)?.toDouble() ?? 0.0;
    final unit = materialData['unit'] as String? ?? 'units';
    final icon = _getMaterialIcon(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: quantity > 0 ? AppColors.statusCompleted.withValues(alpha: 0.05) : AppColors.lightSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quantity > 0 ? AppColors.statusCompleted.withValues(alpha: 0.2) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: quantity > 0 ? AppColors.statusCompleted : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: quantity > 0 ? FontWeight.bold : FontWeight.w500,
                        color: quantity > 0 ? AppColors.deepNavy : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Available: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${availableBalance.toInt()} $unit',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.statusCompleted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (quantity > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Using: ${quantity.toInt()} $unit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.safetyOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _materialQuantities[type] = 0),
                icon: const Icon(Icons.refresh, size: 24),
                color: quantity > 0 ? AppColors.safetyOrange : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: quantity,
                  min: 0,
                  max: availableBalance > 0 ? availableBalance : 100,
                  divisions: (availableBalance > 0 ? availableBalance : 100).toInt(),
                  activeColor: AppColors.statusCompleted,
                  inactiveColor: AppColors.lightSlate,
                  onChanged: (value) => setState(() => _materialQuantities[type] = value),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  '${quantity.toInt()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: quantity > 0 ? AppColors.statusCompleted : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(String type) {
    // Generic icon mapping based on common material types
    final typeLower = type.toLowerCase();
    
    if (typeLower.contains('brick')) return Icons.grid_4x4;
    if (typeLower.contains('sand')) return Icons.landscape;
    if (typeLower.contains('cement')) return Icons.inventory;
    if (typeLower.contains('steel') || typeLower.contains('rod') || typeLower.contains('bar')) return Icons.hardware;
    if (typeLower.contains('jelly') || typeLower.contains('water')) return Icons.water_drop;
    if (typeLower.contains('putty') || typeLower.contains('paint')) return Icons.format_paint;
    if (typeLower.contains('stone') || typeLower.contains('aggregate')) return Icons.terrain;
    if (typeLower.contains('wood') || typeLower.contains('timber')) return Icons.carpenter;
    if (typeLower.contains('wire') || typeLower.contains('cable')) return Icons.cable;
    if (typeLower.contains('pipe')) return Icons.plumbing;
    
    return Icons.inventory_2; // Default icon
  }

  Future<void> _submit() async {
    // Check if material entry is on time
    final isOnTime = TimeValidator.isMaterialEntryOnTime();
    final currentIST = TimeValidator.getISTTime();
    
    print('🕒 [MATERIAL] Current IST time: $currentIST (${TimeValidator.formatISTTime(currentIST)})');
    print('🕒 [MATERIAL] Is on time: $isOnTime');
    print('🕒 [MATERIAL] Time window: 4:00 PM - 7:00 PM IST');
    
    // Parse extra cost
    final extraCost = double.tryParse(_extraCostController.text.trim()) ?? 0;
    final extraCostNotes = _extraCostNotesController.text.trim();
    
    // Prepare materials list with correct units from available materials
    final materials = _materialQuantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          // Find the material data to get the correct unit
          final materialData = _availableMaterials.firstWhere(
            (m) => m['material_type'] == entry.key,
            orElse: () => {'unit': 'units'},
          );
          
          return {
            'material_type': entry.key,
            'quantity': entry.value,
            'unit': materialData['unit'] as String? ?? 'units',
          };
        })
        .toList();

    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmationDialog(
        title: 'Confirm Material Entry',
        entries: materials,
        totalCount: materials.length,
        isLabour: false,
      ),
    );

    if (confirmed != true) return;
    
    setState(() => _isSubmitting = true);
    
    print('🕒 [MATERIAL] About to submit with selected time: $_selectedDateTime');
    
    final result = await _constructionService.submitMaterialBalance(
      siteId: widget.siteId,
      materials: materials,
      extraCost: extraCost > 0 ? extraCost : null,
      extraCostNotes: extraCostNotes.isNotEmpty ? extraCostNotes : null,
      customDateTime: _selectedDateTime, // Pass the selected local time
    );
    
    print('🕒 [MATERIAL] Submission result: ${result['success']}');
    print('🕒 [MATERIAL] Should send notification: ${!isOnTime && result['success']}');
    
    // Send notification to admin if entry is late
    if (!isOnTime && result['success']) {
      print('📧 [MATERIAL] Sending late entry notification to admin...');
      final notificationService = NotificationService();
      final notificationResult = await notificationService.sendLateEntryNotification(
        siteId: widget.siteId,
        entryType: 'material',
        message: TimeValidator.getMaterialLateMessage(),
        actualTime: currentIST,
      );
      print('📧 [MATERIAL] Notification result: ${notificationResult['success']}');
      if (!notificationResult['success']) {
        print('❌ [MATERIAL] Notification error: ${notificationResult['error']}');
      }
    }
    
    setState(() => _isSubmitting = false);
    
    if (mounted) {
      // Reload available materials to show updated total_used
      if (result['success']) {
        await _loadAvailableMaterials();
        widget.onMaterialUpdated?.call();
      }
      
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] 
              ? (isOnTime 
                  ? '✅ Materials updated!' 
                  : '⚠️ Materials updated (Late entry - Admin notified)')
              : '❌ ${result['error']}'
          ),
          backgroundColor: result['success'] 
            ? (isOnTime ? AppColors.statusCompleted : Colors.orange)
            : AppColors.statusOverdue,
          duration: Duration(seconds: result['success'] && !isOnTime ? 4 : 2),
        ),
      );
    }
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusCompleted.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.statusCompleted),
              const SizedBox(width: 8),
              const Text(
                'Entry Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.statusCompleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: AppColors.statusCompleted),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(_selectedDateTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusCompleted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 18, color: AppColors.statusCompleted),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(_selectedDateTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusCompleted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selected: ${_formatDate(_selectedDateTime)} at ${_formatTime(_selectedDateTime)} • Tap to change',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.statusCompleted,
              onPrimary: Colors.white,
              onSurface: AppColors.statusCompleted,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
      print('🕒 [MATERIAL] Date changed to: $_selectedDateTime');
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.statusCompleted,
              onPrimary: Colors.white,
              onSurface: AppColors.statusCompleted,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
      print('🕒 [MATERIAL] Time changed to: $_selectedDateTime');
    }
  }
}


// Confirmation Dialog
class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> entries;
  final int totalCount;
  final bool isLabour;

  const _ConfirmationDialog({
    required this.title,
    required this.entries,
    required this.totalCount,
    required this.isLabour,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isLabour ? AppColors.navyGradient : AppColors.greenGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLabour ? Icons.people : Icons.inventory_2,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please review your entries',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Entries List
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: entries.map((entry) {
                    if (isLabour) {
                      return _buildLabourRow(entry['type'], entry['count']);
                    } else {
                      return _buildMaterialRow(
                        entry['material_type'],
                        entry['quantity'],
                        entry['unit'],
                      );
                    }
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Total Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isLabour ? AppColors.orangeGradient : AppColors.greenGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isLabour 
                        ? 'Total: $totalCount Workers'
                        : 'Total: $totalCount Items',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLabour ? AppColors.safetyOrange : AppColors.statusCompleted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabourRow(String type, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightSlate,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getLabourIcon(type), color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(String type, double quantity, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightSlate,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.statusCompleted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getMaterialIcon(type), color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
          ),
          Text(
            '${quantity.toInt()} $unit',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.statusCompleted,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLabourIcon(String type) {
    switch (type) {
      case 'Carpenter': return Icons.carpenter;
      case 'Mason': return Icons.construction;
      case 'Electrician': return Icons.electrical_services;
      case 'Plumber': return Icons.plumbing;
      case 'Painter': return Icons.format_paint;
      case 'Helper': return Icons.handyman;
      case 'Tile Layer': return Icons.layers;
      case 'Tile Layerhelper': return Icons.layers_outlined;
      case 'Kambi Fitter': return Icons.build;
      case 'Concrete Kot': return Icons.foundation;
      case 'Pile Labour': return Icons.vertical_align_bottom;
      default: return Icons.person;
    }
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'Bricks': return Icons.grid_4x4;
      case 'M Sand': return Icons.landscape;
      case 'P Sand': return Icons.terrain;
      case 'Cement': return Icons.inventory;
      case 'Steel': return Icons.hardware;
      case 'Jelly': return Icons.water_drop;
      case 'Putty': return Icons.format_paint;
      default: return Icons.inventory_2;
    }
  }
}
