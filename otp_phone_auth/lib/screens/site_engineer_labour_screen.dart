import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/construction_service.dart';
import '../services/budget_management_service.dart';
import '../utils/app_colors.dart';
import 'site_engineer_history_screen.dart';

class SiteEngineerLabourScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const SiteEngineerLabourScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<SiteEngineerLabourScreen> createState() => _SiteEngineerLabourScreenState();
}

class _SiteEngineerLabourScreenState extends State<SiteEngineerLabourScreen>
    with SingleTickerProviderStateMixin {
  final _constructionService = ConstructionService();
  final _budgetService = BudgetManagementService();

  late TabController _tabController;

  // Dynamic labour counts for morning and evening
  Map<String, int> _morningLabourCounts = {};
  Map<String, int> _eveningLabourCounts = {};

  Map<String, double> _rates = {};
  bool _isLoadingRates = true;

  // Extra cost controllers
  final _morningExtraCostController = TextEditingController();
  final _morningExtraCostNotesController = TextEditingController();
  final _eveningExtraCostController = TextEditingController();
  final _eveningExtraCostNotesController = TextEditingController();

  // History data
  List<Map<String, dynamic>> _eveningHistoryData = [];
  bool _isLoadingEveningData = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _eveningHistoryData.isEmpty) {
        _loadEveningHistory();
      }
    });
    _fetchRates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _morningExtraCostController.dispose();
    _morningExtraCostNotesController.dispose();
    _eveningExtraCostController.dispose();
    _eveningExtraCostNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoadingRates = true);

    final rates = await _budgetService.getLabourRates('global');
    if (rates.isNotEmpty && mounted) {
      final Map<String, double> loaded = {};
      final Map<String, int> morningCounts = {};
      final Map<String, int> eveningCounts = {};

      for (final r in rates) {
        final type = r['labour_type'] as String?;
        final rate = (r['daily_rate'] as num?)?.toDouble();
        if (type != null && rate != null) {
          loaded[type] = rate;
          // Initialize counts to 0 for each labour type
          morningCounts[type] = 0;
          eveningCounts[type] = 0;
        }
      }

      setState(() {
        _rates = loaded;
        _morningLabourCounts = morningCounts;
        _eveningLabourCounts = eveningCounts;
        _isLoadingRates = false;
      });

      print('✅ [Site Engineer] Loaded ${loaded.length} labour types from admin');
    } else {
      setState(() => _isLoadingRates = false);
    }
  }

  Future<void> _loadEveningHistory() async {
    setState(() => _isLoadingEveningData = true);
    try {
      final response = await _constructionService.getHistoryByDay(siteId: widget.siteId);

      if (response['success']) {
        final data = response['data'] as Map<String, dynamic>;
        final labourByDay = data['labour_by_day'] as Map<String, dynamic>? ?? {};

        // Get today's date
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        List<Map<String, dynamic>> todayEntries = [];
        labourByDay.forEach((day, entries) {
          if (entries is List && day == todayStr) {
            todayEntries.addAll(List<Map<String, dynamic>>.from(entries));
          }
        });

        setState(() {
          _eveningHistoryData = todayEntries;
        });
      }
    } catch (e) {
      print('Error loading evening history: $e');
    } finally {
      setState(() => _isLoadingEveningData = false);
    }
  }

  Map<String, int> get _currentLabourCounts =>
      _tabController.index == 0 ? _morningLabourCounts : _eveningLabourCounts;

  int get _totalCount => _currentLabourCounts.values.fold(0, (sum, count) => sum + count);

  double get _totalSalary => _currentLabourCounts.entries.fold(
        0,
        (sum, e) => sum + e.value * (_rates[e.key] ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Labour Entry - ${widget.siteName}'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header with counts
          Container(
            padding: EdgeInsets.all(16.r),
            color: AppColors.cleanWhite,
            child: Row(
              children: [
                Text(
                  '👷 Labour Count',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Workers: $_totalCount',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '₹${_totalSalary.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.lightSlate,
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                gradient: AppColors.orangeGradient,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '🌅 Morning'),
                Tab(text: '🌆 Evening'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMorningTab(),
                _buildEveningTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _isSubmitting ? null : _submitMorningEntry,
              backgroundColor: AppColors.safetyOrange,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Entry'),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SiteEngineerHistoryScreen(
                      siteId: widget.siteId,
                      siteName: widget.siteName,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.deepNavy,
              icon: const Icon(Icons.history),
              label: const Text('View History'),
            ),
    );
  }

  Widget _buildMorningTab() {
    // Show loading indicator while rates are being fetched
    if (_isLoadingRates) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Loading labour types...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show message if no labour types are available
    if (_morningLabourCounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Labour Types Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Admin needs to add labour types first',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Labour counts
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _morningLabourCounts.keys
                  .map((type) => _buildLabourTypeRow(type, true))
                  .toList(),
            ),
          ),

          SizedBox(height: 16.h),

          // Extra Cost Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 20.sp, color: Colors.orange.shade700),
                    SizedBox(width: 8.w),
                    Text(
                      'Extra Cost (Optional)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _morningExtraCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount (₹)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.orange.shade200),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _morningExtraCostNotesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Notes (optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.orange.shade200),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEveningTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Morning entered details (read-only)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.blue.shade700),
                    SizedBox(width: 8.w),
                    Text(
                      'Morning Entries',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (_isLoadingEveningData)
                  const Center(child: CircularProgressIndicator())
                else if (_eveningHistoryData.isEmpty)
                  const Text(
                    'No morning entries found for today',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ..._eveningHistoryData.map((entry) => _buildHistoryEntry(entry)),
              ],
            ),
          ),

          SizedBox(height: 80.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildLabourTypeRow(String type, bool isMorning) {
    final counts = isMorning ? _morningLabourCounts : _eveningLabourCounts;
    final count = counts[type]!;
    final rate = _rates[type] ?? 0;
    final rowTotal = count * rate;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(_getLabourIcon(type), color: AppColors.deepNavy, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
                Text(
                  '₹${rate.toStringAsFixed(0)}/day',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => counts[type] = (count - 1).clamp(0, 50)),
                icon: Icon(Icons.remove_circle_outline, size: 28.sp),
                color: count > 0 ? AppColors.safetyOrange : AppColors.textSecondary,
              ),
              Container(
                width: 40.w,
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => counts[type] = (count + 1).clamp(0, 50)),
                icon: Icon(Icons.add_circle_outline, size: 28.sp),
                color: AppColors.safetyOrange,
              ),
            ],
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '₹${rowTotal.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryEntry(Map<String, dynamic> entry) {
    final labourType = entry['labour_type'] as String? ?? 'Unknown';
    final count = entry['labour_count'] as int? ?? 0;
    final rate = _rates[labourType] ?? 0;
    final total = count * rate;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(_getLabourIcon(labourType), size: 20.sp, color: AppColors.deepNavy),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              labourType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$count workers',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '₹${total.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
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

  Future<void> _submitMorningEntry() async {
    if (_totalCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one labour entry'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final extraCost = double.tryParse(_morningExtraCostController.text) ?? 0;
      final extraCostNotes = _morningExtraCostNotesController.text.trim();

      // Submit each labour type with count > 0
      for (final entry in _morningLabourCounts.entries) {
        if (entry.value > 0) {
          await _constructionService.submitLabourCount(
            siteId: widget.siteId,
            labourCount: entry.value,
            labourType: entry.key,
            notes: '',
            extraCost: extraCost > 0 ? extraCost : null,
            extraCostNotes: extraCostNotes.isNotEmpty ? extraCostNotes : null,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Labour entry submitted successfully!'),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
