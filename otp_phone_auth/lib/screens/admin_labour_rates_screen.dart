import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/budget_management_service.dart';
import '../services/cache_service.dart';
import 'admin_local_labour_rates_screen.dart';

class AdminLabourRatesScreen extends StatefulWidget {
  const AdminLabourRatesScreen({super.key});

  @override
  State<AdminLabourRatesScreen> createState() => _AdminLabourRatesScreenState();
}

class _AdminLabourRatesScreenState extends State<AdminLabourRatesScreen> {
  final _budgetService = BudgetManagementService();

  // null = using canonical default (not admin-set), non-null = admin explicitly set
  Map<String, double?> _rates = {};
  // Effective rate shown in UI (admin-set OR canonical default)
  Map<String, double> _effectiveRates = {};
  Map<String, String?> _setByNames = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  void _parseAndSetRates(List<dynamic> allRates) {
    // API now returns all 12 types — admin-set rate or canonical default
    final Map<String, double?> merged = {};
    final Map<String, String?> names = {};
    final Map<String, double> effective = {};
    for (final r in allRates) {
      final type = r['labour_type'] as String?;
      final rate = (r['daily_rate'] as num?)?.toDouble();
      final isAdminSet = r['is_admin_set'] as bool? ?? false;
      final setBy = r['set_by'] as String?;
      if (type != null && rate != null) {
        effective[type] = rate;
        merged[type] = isAdminSet ? rate : null;
        if (isAdminSet && setBy != null) names[type] = setBy;
      }
    }
    _rates = merged;
    _effectiveRates = effective;
    _setByNames = names;
  }

  Future<void> _loadRates() async {
    // Try cache first
    final cached = await CacheService.loadLabourRates();
    if (cached != null) {
      final cachedRates = cached['rates'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _parseAndSetRates(cachedRates);
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    final allRates = await _budgetService.getLabourRates('global');

    await CacheService.saveLabourRates({'rates': allRates});

    if (mounted) {
      setState(() {
        _parseAndSetRates(allRates);
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewLabourType() async {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.add_circle,
                color: const Color(0xFF1A1A2E),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Add New Labour Type',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Labour Type Name',
                    prefixIcon: Icon(
                      Icons.engineering,
                      color: const Color(0xFF1A1A2E),
                      size: 18.sp,
                    ),
                    hintText: 'e.g., Welder, Driver',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A1A2E),
                        width: 2,
                      ),
                    ),
                  ),
                  autofocus: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Labour type name is required';
                    }
                    // Check if already exists
                    if (_rates.containsKey(v.trim())) {
                      return 'This labour type already exists';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: rateCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Daily Rate (₹)',
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                      color: const Color(0xFF1A1A2E),
                      size: 18.sp,
                    ),
                    hintText: 'Enter daily rate',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A1A2E),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Rate is required';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(
                      Icons.note_outlined,
                      color: const Color(0xFF6B7280),
                      size: 18.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A1A2E),
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Add Labour Type'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      nameCtrl.dispose();
      rateCtrl.dispose();
      notesCtrl.dispose();
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await _budgetService.setLabourRate(
        siteId: 'global',
        labourType: nameCtrl.text.trim(),
        dailyRate: double.parse(rateCtrl.text.trim()),
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );

      if (mounted) {
        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'New labour type "${nameCtrl.text.trim()}" added with rate ₹${rateCtrl.text}/day',
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          await CacheService.clearLabourRates();
          await _loadRates();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['error'] ?? 'Failed to add labour type'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    nameCtrl.dispose();
    rateCtrl.dispose();
    notesCtrl.dispose();
  }

  Future<void> _deleteLabourType(String labourType) async {
    // Check if this is a canonical type
    final isCanonical = const [
      'General',
      'Mason',
      'Helper',
      'Carpenter',
      'Plumber',
      'Electrician',
      'Painter',
      'Tile Layer',
      'Tile Layerhelper',
      'Kambi Fitter',
      'Concrete Kot',
      'Pile Labour',
    ].contains(labourType);

    if (isCanonical) {
      // Show warning for canonical types
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.orange,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Cannot Delete',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"$labourType" is a system default labour type and cannot be deleted.',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF1A1A2E),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'System defaults are protected to maintain data integrity.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Confirm deletion for custom types
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.delete_forever, color: Colors.red, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Delete Labour Type',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "$labourType"?',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This will remove the labour type from all screens.',
                      style: TextStyle(fontSize: 12.sp, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final result = await _budgetService.deleteLabourType(labourType);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Labour type "$labourType" deleted successfully'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          await CacheService.clearLabourRates();
          await _loadRates();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to delete labour type'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editRate(String labourType) async {
    final effectiveRate = _effectiveRates[labourType];
    final ctrl = TextEditingController(
      text: effectiveRate?.toStringAsFixed(0) ?? '',
    );
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.currency_rupee,
                color: const Color(0xFF1A1A2E),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Daily Rate',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    labourType,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Daily Rate (₹)',
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: const Color(0xFF1A1A2E),
                    size: 18.sp,
                  ),
                  helperText: effectiveRate != null
                      ? 'Current: ₹${effectiveRate.toStringAsFixed(0)}/day'
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A1A2E),
                      width: 2,
                    ),
                  ),
                ),
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Rate is required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(
                    Icons.note_outlined,
                    color: const Color(0xFF6B7280),
                    size: 18.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A1A2E),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final result = await _budgetService.setLabourRate(
        siteId: 'global',
        labourType: labourType,
        dailyRate: double.parse(ctrl.text.trim()),
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
      if (mounted) {
        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rate for $labourType updated to ₹${ctrl.text}/day',
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          await CacheService.clearLabourRates();
          await _loadRates();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['error'] ?? 'Failed to update rate'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    ctrl.dispose();
    notesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8.w),
            Text(
              'Labour Rates',
              style: TextStyle(
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: const Color(0xFF1A1A2E)),
            onPressed: _loadRates,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Theme(
        // Inherit or override FAB theme properties
        data: Theme.of(context).copyWith(useMaterial3: true),
        child: PopupMenuButton<String>(
          // Offset pushes the dropdown menu below the button
          offset: const Offset(0, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (String value) {
            // Handle menu item selection
            debugPrint('Selected: $value');
          },
          // Custom child transforms the popup trigger into a FAB shape
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: kElevationToShadow[6],
            ),
            child: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'Add Labour Type',
              child: GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.add_circle_outline),
                  title: Text('Add Labour Type'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  _addNewLabourType;
                },
              ),
            ),
            PopupMenuItem<String>(
              value: 'Local Rates',
              child: GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.location_on, size: 18),
                  title: Text('Local rates'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLocalLabourRatesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)),
            )
          : RefreshIndicator(
              onRefresh: _loadRates,
              color: const Color(0xFF1A1A2E),
              child: ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  // Info card
                  Container(
                    padding: EdgeInsets.all(14.r),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF1A1A2E),
                          size: 18.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Tap any row to set an admin rate. Updated rates will be shown to supervisors and site engineers.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(
                                0xFF1A1A2E,
                              ).withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Labour type cards
                  ..._rates.entries.map(
                    (entry) => _buildRateRow(entry.key, entry.value),
                  ),

                  if (_isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRateRow(String labourType, double? adminRate) {
    final hasAdminRate = adminRate != null;
    final effectiveRate = _effectiveRates[labourType];
    final setBy = _setByNames[labourType];

    // Check if this is a canonical type (cannot be deleted)
    final isCanonical = const [
      'General',
      'Mason',
      'Helper',
      'Carpenter',
      'Plumber',
      'Electrician',
      'Painter',
      'Tile Layer',
      'Tile Layerhelper',
      'Kambi Fitter',
      'Concrete Kot',
      'Pile Labour',
    ].contains(labourType);

    return GestureDetector(
      onTap: () => _editRate(labourType),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasAdminRate
                ? const Color(0xFF1A1A2E).withValues(alpha: 0.3)
                : const Color(0xFF1A1A2E).withValues(alpha: 0.08),
            width: hasAdminRate ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: hasAdminRate
                    ? const Color(0xFF1A1A2E).withValues(alpha: 0.1)
                    : const Color(0xFF1A1A2E).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.engineering,
                color: hasAdminRate
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF6B7280),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        labourType,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (!isCanonical)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: const Color(0xFF059669),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  if (hasAdminRate && setBy != null)
                    Text(
                      'Set by $setBy',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    )
                  else
                    Text(
                      'Canonical default',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),

            // Rate badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: hasAdminRate
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    effectiveRate != null
                        ? '₹${effectiveRate.toStringAsFixed(0)}/day'
                        : '--',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: hasAdminRate
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hasAdminRate ? 'Admin set' : 'Default',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: hasAdminRate
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),

            SizedBox(width: 8.w),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit icon
                GestureDetector(
                  onTap: () => _editRate(labourType),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                // Delete icon (for all types)
                GestureDetector(
                  onTap: () => _deleteLabourType(labourType),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      isCanonical
                          ? Icons.lock_outline
                          : Icons.delete_sweep_outlined,
                      size: 18.sp,
                      color: isCanonical ? Colors.orange : Colors.red,
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
}
