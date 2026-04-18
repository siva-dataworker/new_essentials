import 'package:flutter/material.dart';
import '../services/material_service.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class SiteEngineerMaterialScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const SiteEngineerMaterialScreen({
    Key? key,
    required this.siteId,
    required this.siteName,
  }) : super(key: key);

  @override
  State<SiteEngineerMaterialScreen> createState() => _SiteEngineerMaterialScreenState();
}

class _SiteEngineerMaterialScreenState extends State<SiteEngineerMaterialScreen> {
  final _materialService = MaterialService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _materialBalance = [];
  Map<String, dynamic> _todayUsageSummary = {};

  @override
  void initState() {
    super.initState();
    _loadMaterialData();
  }

  Future<void> _loadMaterialData() async {
    setState(() => _isLoading = true);

    try {
      // Load material balance
      final balanceResult = await _materialService.getMaterialBalance(widget.siteId);
      
      // Load today's usage
      final todayUsageResult = await _materialService.getTodayMaterialUsage(widget.siteId);

      if (balanceResult['success'] == true) {
        setState(() {
          _materialBalance = List<Map<String, dynamic>>.from(balanceResult['balance'] ?? []);
        });
      }

      if (todayUsageResult['success'] == true) {
        // Create a map for quick lookup of today's usage
        final todayUsageList = List<Map<String, dynamic>>.from(
          todayUsageResult['today_usage_summary'] ?? []
        );
        
        setState(() {
          _todayUsageSummary = {
            for (var item in todayUsageList)
              item['material_type']: item['total_used_today']
          };
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading materials: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMaterialDialog(
        siteId: widget.siteId,
        onSuccess: () {
          _loadMaterialData();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'IN_STOCK':
        return AppColors.success;
      case 'LOW_STOCK':
        return AppColors.textSecondary;
      case 'OUT_OF_STOCK':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'IN_STOCK':
        return 'In Stock';
      case 'LOW_STOCK':
        return 'Low Stock';
      case 'OUT_OF_STOCK':
        return 'Out of Stock';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Material Inventory', style: TextStyle(fontSize: 18)),
            Text(
              widget.siteName,
              style: TextStyle(fontSize: 12, color: AppColors.white.withOpacity(0.8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMaterialData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _materialBalance.isEmpty
              ? _buildEmptyState()
              : _buildMaterialList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMaterialDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add),
        label: Text('Add Material'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No materials added yet',
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the button below to add materials',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialList() {
    return RefreshIndicator(
      onRefresh: _loadMaterialData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _materialBalance.length,
        itemBuilder: (context, index) {
          final material = _materialBalance[index];
          return _buildMaterialCard(material);
        },
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final materialType = material['material_type'] ?? '';
    final initialStock = (material['initial_stock'] as num?)?.toDouble() ?? 0;
    final totalUsed = (material['total_used'] as num?)?.toDouble() ?? 0;
    final currentBalance = (material['current_balance'] as num?)?.toDouble() ?? 0;
    final unit = material['unit'] ?? '';
    final status = material['stock_status'] ?? 'IN_STOCK';
    final todayUsed = (_todayUsageSummary[materialType] as num?)?.toDouble() ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with material name and status
            Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    materialType,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Current Balance (Large Display)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${currentBalance.toStringAsFixed(1)} $unit',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Stock Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Initial Stock',
                    '${initialStock.toStringAsFixed(1)} $unit',
                    Icons.add_circle_outline,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Total Used',
                    '${totalUsed.toStringAsFixed(1)} $unit',
                    Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            
            // Today's Usage (Highlighted)
            if (todayUsed > 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.today, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Used Today: ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${todayUsed.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Action Buttons
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddStockDialog(material),
                    icon: Icon(Icons.add, size: 18),
                    label: Text('Add Stock'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUsageHistory(material),
                    icon: Icon(Icons.history, size: 18),
                    label: Text('History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.textSecondary),
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

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddStockDialog(Map<String, dynamic> material) {
    showDialog(
      context: context,
      builder: (context) => _AddStockDialog(
        siteId: widget.siteId,
        materialType: material['material_type'],
        unit: material['unit'],
        onSuccess: () {
          _loadMaterialData();
        },
      ),
    );
  }

  void _showUsageHistory(Map<String, dynamic> material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MaterialUsageHistoryScreen(
          siteId: widget.siteId,
          materialType: material['material_type'],
          siteName: widget.siteName,
        ),
      ),
    );
  }
}

// ============================================
// ADD NEW MATERIAL DIALOG
// ============================================

class _AddMaterialDialog extends StatefulWidget {
  final String siteId;
  final VoidCallback onSuccess;

  const _AddMaterialDialog({
    required this.siteId,
    required this.onSuccess,
  });

  @override
  State<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<_AddMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materialTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();
  final _materialService = MaterialService();
  bool _isSubmitting = false;

  // Common material types
  final List<String> _commonMaterials = [
    'Cement',
    'Sand',
    'Bricks',
    'Steel',
    'Gravel',
    'Concrete',
    'Wood',
    'Paint',
    'Tiles',
    'Other',
  ];

  // Common units
  final List<String> _commonUnits = [
    'Bags',
    'Tons',
    'Pieces',
    'Cubic Meters',
    'Liters',
    'Kg',
    'Sq Meters',
  ];

  @override
  void dispose() {
    _materialTypeController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _materialService.addMaterialStock(
        siteId: widget.siteId,
        materialType: _materialTypeController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to add material'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Text('Add Material Stock', style: TextStyle(color: AppColors.textPrimary)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Material Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Material Type',
                  border: OutlineInputBorder(),
                ),
                items: _commonMaterials.map((material) {
                  return DropdownMenuItem(value: material, child: Text(material));
                }).toList(),
                onChanged: (value) {
                  if (value == 'Other') {
                    _materialTypeController.clear();
                  } else {
                    _materialTypeController.text = value ?? '';
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select material type';
                  }
                  return null;
                },
              ),
              
              // Custom material type (if Other selected)
              if (_materialTypeController.text.isEmpty) ...[
                SizedBox(height: 16),
                TextFormField(
                  controller: _materialTypeController,
                  decoration: InputDecoration(
                    labelText: 'Custom Material Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter material type';
                    }
                    return null;
                  },
                ),
              ],
              
              SizedBox(height: 16),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Quantity must be greater than 0';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Unit Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                items: _commonUnits.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  _unitController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select unit';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text('Add Material'),
        ),
      ],
    );
  }
}

// ============================================
// ADD STOCK TO EXISTING MATERIAL DIALOG
// ============================================

class _AddStockDialog extends StatefulWidget {
  final String siteId;
  final String materialType;
  final String unit;
  final VoidCallback onSuccess;

  const _AddStockDialog({
    required this.siteId,
    required this.materialType,
    required this.unit,
    required this.onSuccess,
  });

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _materialService = MaterialService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _materialService.addMaterialStock(
        siteId: widget.siteId,
        materialType: widget.materialType,
        quantity: double.parse(_quantityController.text),
        unit: widget.unit,
        notes: _notesController.text.trim(),
      );

      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to add stock'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Text('Add Stock', style: TextStyle(color: AppColors.textPrimary)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adding stock to: ${widget.materialType}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (${widget.unit})',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter quantity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Quantity must be greater than 0';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text('Add Stock'),
        ),
      ],
    );
  }
}

// ============================================
// MATERIAL USAGE HISTORY SCREEN
// ============================================

class _MaterialUsageHistoryScreen extends StatefulWidget {
  final String siteId;
  final String materialType;
  final String siteName;

  const _MaterialUsageHistoryScreen({
    required this.siteId,
    required this.materialType,
    required this.siteName,
  });

  @override
  State<_MaterialUsageHistoryScreen> createState() => _MaterialUsageHistoryScreenState();
}

class _MaterialUsageHistoryScreenState extends State<_MaterialUsageHistoryScreen> {
  final _materialService = MaterialService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _usageHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUsageHistory();
  }

  Future<void> _loadUsageHistory() async {
    setState(() => _isLoading = true);

    try {
      final result = await _materialService.getMaterialUsageHistory(
        siteId: widget.siteId,
        materialType: widget.materialType,
      );

      if (result['success'] == true) {
        setState(() {
          _usageHistory = List<Map<String, dynamic>>.from(result['usage_history'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usage History', style: TextStyle(fontSize: 18)),
            Text(
              widget.materialType,
              style: TextStyle(fontSize: 12, color: AppColors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _usageHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'No usage history',
                        style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _usageHistory.length,
                  itemBuilder: (context, index) {
                    final usage = _usageHistory[index];
                    return _buildUsageCard(usage);
                  },
                ),
    );
  }

  Widget _buildUsageCard(Map<String, dynamic> usage) {
    final supervisorName = usage['supervisor_name'] ?? 'Unknown';
    final quantityUsed = (usage['quantity_used'] as num?)?.toDouble() ?? 0;
    final unit = usage['unit'] ?? '';
    final usageDate = usage['usage_date'] ?? '';
    final usageTime = usage['usage_time'] ?? '';
    final notes = usage['notes'] ?? '';

    // Format date
    String formattedDate = '';
    try {
      final date = DateTime.parse(usageDate);
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      formattedDate = usageDate;
    }

    // Format time
    String formattedTime = '';
    try {
      final time = DateTime.parse(usageTime);
      formattedTime = DateFormat('hh:mm a').format(time);
    } catch (e) {
      formattedTime = usageTime.split('T').last.substring(0, 5);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supervisorName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${quantityUsed.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  formattedTime,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            if (notes.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                notes,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
