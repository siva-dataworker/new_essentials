import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/construction_service.dart';

class AccountantCompareScreen extends StatefulWidget {
  const AccountantCompareScreen({super.key});

  @override
  State<AccountantCompareScreen> createState() => _AccountantCompareScreenState();
}

class _AccountantCompareScreenState extends State<AccountantCompareScreen> {
  final _constructionService = ConstructionService();

  DateTime _selectedDate = DateTime.now();
  String? _selectedSite; // null = All Sites
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _supervisorEntries = [];
  List<Map<String, dynamic>> _engineerEntries = [];
  bool _isLoading = false;
  bool _isLoadingSites = false;
  String? _error;

  // Selection state
  String? _selectedEntryId; // ID of selected entry
  String? _selectedEntryType; // 'supervisor' or 'site_engineer'
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
    _loadComparisonData();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoadingSites = true);

    try {
      final sites = await _constructionService.getSites();

      if (mounted) {
        setState(() {
          _sites = sites;
          _isLoadingSites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSites = false);
      }
    }
  }

  Future<void> _loadComparisonData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      print('🔍 [COMPARE] Loading data for date: $dateStr');

      // Load supervisor entries
      final supervisorData = await _constructionService.getEntriesByDateAndRole(dateStr, 'Supervisor');
      print('📊 [COMPARE] Supervisor data: ${supervisorData.length} sites');
      if (supervisorData.isNotEmpty) {
        print('📊 [COMPARE] First supervisor entry: ${supervisorData[0]}');
      }

      // Load site engineer entries
      final engineerData = await _constructionService.getEntriesByDateAndRole(dateStr, 'Site Engineer');
      print('📊 [COMPARE] Engineer data: ${engineerData.length} sites');
      if (engineerData.isNotEmpty) {
        print('📊 [COMPARE] First engineer entry: ${engineerData[0]}');
      }

      if (mounted) {
        setState(() {
          // Filter by selected site if one is selected
          if (_selectedSite != null) {
            print('🔍 [COMPARE] Filtering by site: $_selectedSite');
            _supervisorEntries = supervisorData.where((entry) => entry['site_id'] == _selectedSite).toList();
            _engineerEntries = engineerData.where((entry) => entry['site_id'] == _selectedSite).toList();
            print('📊 [COMPARE] After filter - Supervisor: ${_supervisorEntries.length}, Engineer: ${_engineerEntries.length}');
          } else {
            _supervisorEntries = supervisorData;
            _engineerEntries = engineerData;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [COMPARE] Error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1A2E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadComparisonData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Compare Entries',
          style: TextStyle(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        actions: [
          // Add custom entry button
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateCustomEntryDialog,
            tooltip: 'Create Custom Entry',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComparisonData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector card
          Container(
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.compare_arrows,
                        color: const Color(0xFF1A1A2E),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comparing Entries For',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: _selectDate,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(height: 1),
                SizedBox(height: 12.h),
                // Site filter dropdown
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Site:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _isLoadingSites
                          ? Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedSite,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(color: Color(0xFF1A1A2E)),
                                ),
                              ),
                              hint: Text(
                                'All Sites',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All Sites'),
                                ),
                                ..._sites.map((site) {
                                  return DropdownMenuItem<String>(
                                    value: site['id'],
                                    child: Text(
                                      site['display_name'] ?? site['site_name'] ?? 'Unknown',
                                      style: TextStyle(fontSize: 14.sp),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSite = value);
                                _loadComparisonData();
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A1A2E),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.sp,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Error: $_error',
                              style: const TextStyle(color: Colors.red),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _loadComparisonData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildComparisonView(),
          ),

          // Confirm button at bottom
          if (_selectedEntryId != null)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isConfirming
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirm Selection',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    if (_supervisorEntries.isEmpty && _engineerEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 50.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Entries Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No labour entries for this date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        // Supervisor Section
        _buildSectionHeader(
          'Supervisor Entries',
          _supervisorEntries.length,
          Icons.engineering,
          const Color(0xFF059669),
        ),
        SizedBox(height: 12.h),
        ..._supervisorEntries.map((entry) => _buildEntryCard(entry, true)),

        SizedBox(height: 24.h),

        // Site Engineer Section
        _buildSectionHeader(
          'Site Engineer Entries',
          _engineerEntries.length,
          Icons.construction,
          const Color(0xFF2563EB),
        ),
        SizedBox(height: 12.h),
        ..._engineerEntries.map((entry) => _buildEntryCard(entry, false)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count ${count == 1 ? 'Entry' : 'Entries'}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry, bool isSupervisor) {
    final siteName = entry['site_name'] ?? 'Unknown Site';
    final siteId = entry['site_id'] ?? '';
    final labourEntries = entry['labour_entries'] as List? ?? [];
    final submittedBy = entry['submitted_by'] ?? 'Unknown';
    final submittedAt = entry['submitted_at'] as String?;

    final color = isSupervisor ? const Color(0xFF059669) : const Color(0xFF2563EB);
    final entryType = isSupervisor ? 'supervisor' : 'site_engineer';
    final isSelected = _selectedEntryId == siteId && _selectedEntryType == entryType;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Selection checkbox row
          InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedEntryId = null;
                  _selectedEntryType = null;
                } else {
                  _selectedEntryId = siteId;
                  _selectedEntryType = entryType;
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedEntryId = siteId;
                          _selectedEntryType = entryType;
                        } else {
                          _selectedEntryId = null;
                          _selectedEntryType = null;
                        }
                      });
                    },
                    activeColor: color,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isSelected ? 'Selected for confirmation' : 'Tap to select this entry',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Existing expansion tile
          ExpansionTile(
            leading: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isSupervisor ? Icons.engineering : Icons.construction,
                color: color,
                size: 20.sp,
              ),
            ),
            title: Text(
              siteName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(
                  'By: $submittedBy',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                if (submittedAt != null)
                  Text(
                    'At: ${_formatTime(submittedAt)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),
            children: [
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Labour Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...labourEntries.map((labour) => _buildLabourRow(labour)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabourRow(Map<String, dynamic> labour) {
    final labourType = labour['labour_type'] ?? 'Unknown';
    final count = labour['labour_count'] ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              labourType,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedEntryId == null || _selectedEntryType == null) return;

    setState(() => _isConfirming = true);

    try {
      // Find the selected entry
      final entries = _selectedEntryType == 'supervisor' ? _supervisorEntries : _engineerEntries;
      final selectedEntry = entries.firstWhere((e) => e['site_id'] == _selectedEntryId);

      final labourEntries = selectedEntry['labour_entries'] as List;
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Fetch labour rates for each labour type
      final labourEntriesWithRates = <Map<String, dynamic>>[];
      for (var labour in labourEntries) {
        final labourType = labour['labour_type'];
        final labourCount = labour['labour_count'];

        // Get rate from backend (global rates)
        final ratesResponse = await _constructionService.getLabourRates('global');
        final rates = ratesResponse['rates'] as List? ?? [];
        final rateData = rates.firstWhere(
          (r) => r['labour_type'] == labourType,
          orElse: () => {'daily_rate': 600.0}, // Default fallback
        );

        final dailyRate = (rateData['daily_rate'] as num).toDouble();

        labourEntriesWithRates.add({
          'labour_type': labourType,
          'labour_count': labourCount,
          'daily_rate': dailyRate,
        });
      }

      // Call confirm cash entry API
      final result = await _constructionService.confirmCashEntry(
        siteId: _selectedEntryId!,
        entryDate: dateStr,
        sourceType: _selectedEntryType!,
        sourceEntryId: null, // We don't have individual entry IDs in the grouped data
        labourEntries: labourEntriesWithRates,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Entry confirmed successfully'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _selectedEntryId = null;
            _selectedEntryType = null;
          });

          // Reload data
          _loadComparisonData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to confirm entry'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        setState(() => _isConfirming = false);
      }
    }
  }

  void _showCreateCustomEntryDialog() {
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate));
    String? selectedSiteId;
    String? selectedLabourType;
    final countController = TextEditingController();
    final notesController = TextEditingController();
    double? dailyRate;
    List<Map<String, dynamic>> labourRates = [];
    bool isLoadingRates = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Load labour rates on first build
          if (isLoadingRates && labourRates.isEmpty) {
            _constructionService.getLabourRates('global').then((response) {
              setDialogState(() {
                labourRates = List<Map<String, dynamic>>.from(response['rates'] ?? []);
                isLoadingRates = false;
              });
            });
          }

          return AlertDialog(
            title: Text(
              'Create Custom Entry',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Site selector
                  Text(
                    'Site',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: selectedSiteId,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      hintText: 'Select site',
                    ),
                    items: _sites.map((site) {
                      return DropdownMenuItem<String>(
                        value: site['id'],
                        child: Text(
                          site['display_name'] ?? site['site_name'] ?? 'Unknown',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedSiteId = value);
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Date picker
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Labour type selector
                  Text(
                    'Labour Type',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  isLoadingRates
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: selectedLabourType,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            hintText: 'Select labour type',
                          ),
                          items: labourRates.map((rate) {
                            return DropdownMenuItem<String>(
                              value: rate['labour_type'],
                              child: Text(
                                rate['labour_type'],
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedLabourType = value;
                              // Auto-fill daily rate
                              final rateData = labourRates.firstWhere(
                                (r) => r['labour_type'] == value,
                                orElse: () => {'daily_rate': 600.0},
                              );
                              dailyRate = (rateData['daily_rate'] as num).toDouble();
                            });
                          },
                        ),
                  SizedBox(height: 16.h),

                  // Labour count
                  Text(
                    'Labour Count',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      hintText: 'Enter count',
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Daily rate (auto-filled, read-only)
                  Text(
                    'Daily Rate',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      dailyRate != null ? '₹${dailyRate!.toStringAsFixed(0)}' : 'Select labour type first',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: dailyRate != null ? const Color(0xFF1A1A2E) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Notes
                  Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.r),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      hintText: 'Enter notes',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validation
                  if (selectedSiteId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a site'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (selectedLabourType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a labour type'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (countController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter labour count'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final count = int.tryParse(countController.text);
                  if (count == null || count <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid count'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  // Show loading
                  if (mounted) {
                    setState(() => _isConfirming = true);
                  }

                  try {
                    // Create custom cash entry
                    final result = await _constructionService.createCustomCashEntry(
                      siteId: selectedSiteId!,
                      entryDate: dateController.text,
                      labourEntries: [
                        {
                          'labour_type': selectedLabourType!,
                          'labour_count': count,
                          'daily_rate': dailyRate!,
                        }
                      ],
                      notes: notesController.text.isNotEmpty ? notesController.text : null,
                    );

                    if (mounted) {
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Custom entry created successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadComparisonData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['error'] ?? 'Failed to create entry'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                      setState(() => _isConfirming = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
