import 'package:flutter/material.dart';
import '../services/material_service.dart';
import '../utils/app_colors.dart';

class SupervisorMaterialUsageDialog extends StatefulWidget {
  final String siteId;
  final VoidCallback onSuccess;

  const SupervisorMaterialUsageDialog({
    Key? key,
    required this.siteId,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<SupervisorMaterialUsageDialog> createState() => _SupervisorMaterialUsageDialogState();
}

class _SupervisorMaterialUsageDialogState extends State<SupervisorMaterialUsageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _materialService = MaterialService();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _availableMaterials = [];
  String? _selectedMaterialType;
  String? _selectedUnit;
  double? _currentBalance;

  @override
  void initState() {
    super.initState();
    _loadAvailableMaterials();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableMaterials() async {
    setState(() => _isLoading = true);

    try {
      final result = await _materialService.getMaterialBalance(widget.siteId);

      if (result['success'] == true) {
        setState(() {
          _availableMaterials = List<Map<String, dynamic>>.from(result['balance'] ?? []);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMaterialType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a material'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _materialService.recordMaterialUsage(
        siteId: widget.siteId,
        materialType: _selectedMaterialType!,
        quantityUsed: double.parse(_quantityController.text),
        unit: _selectedUnit!,
        notes: _notesController.text.trim(),
      );

      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        
        // Show warning if insufficient stock
        if (result['warning'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usage recorded but stock is insufficient!'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Material usage recorded successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to record usage'),
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

  void _onMaterialSelected(String? materialType) {
    if (materialType == null) return;

    final material = _availableMaterials.firstWhere(
      (m) => m['material_type'] == materialType,
      orElse: () => {},
    );

    setState(() {
      _selectedMaterialType = materialType;
      _selectedUnit = material['unit'];
      _currentBalance = (material['current_balance'] as num?)?.toDouble();
    });
  }

  Color _getBalanceColor() {
    if (_currentBalance == null) return AppColors.textSecondary;
    if (_currentBalance! <= 0) return AppColors.error;
    if (_currentBalance! < 20) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Row(
        children: [
          Icon(Icons.remove_circle_outline, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Record Material Usage',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
        ],
      ),
      content: _isLoading
          ? Container(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : _availableMaterials.isEmpty
              ? Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text(
                          'No materials available',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ask Site Engineer to add materials first',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Material Selection
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Material',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2, color: AppColors.primary),
                          ),
                          value: _selectedMaterialType,
                          items: _availableMaterials.map((material) {
                            final materialType = material['material_type'] as String;
                            final balance = (material['current_balance'] as num?)?.toDouble() ?? 0;
                            final unit = material['unit'] as String;
                            final status = material['stock_status'] as String;
                            
                            return DropdownMenuItem(
                              value: materialType,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(materialType),
                                  ),
                                  Text(
                                    '${balance.toStringAsFixed(1)} $unit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: status == 'OUT_OF_STOCK'
                                          ? AppColors.error
                                          : status == 'LOW_STOCK'
                                              ? AppColors.warning
                                              : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _onMaterialSelected,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a material';
                            }
                            return null;
                          },
                        ),
                        
                        // Current Balance Display
                        if (_selectedMaterialType != null) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getBalanceColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getBalanceColor().withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: _getBalanceColor(),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Available: ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${_currentBalance?.toStringAsFixed(1)} $_selectedUnit',
                                  style: TextStyle(
                                    color: _getBalanceColor(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 16),
                        
                        // Quantity Used
                        TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: _selectedUnit != null
                                ? 'Quantity Used ($_selectedUnit)'
                                : 'Quantity Used',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.remove, color: AppColors.primary),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          enabled: _selectedMaterialType != null,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quantity';
                            }
                            final quantity = double.tryParse(value);
                            if (quantity == null) {
                              return 'Please enter valid number';
                            }
                            if (quantity <= 0) {
                              return 'Quantity must be greater than 0';
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
                            hintText: 'e.g., Used for foundation work',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note, color: AppColors.primary),
                          ),
                          maxLines: 3,
                          enabled: _selectedMaterialType != null,
                        ),
                        
                        SizedBox(height: 8),
                        
                        // Info text
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'This will be recorded for today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      actions: _isLoading || _availableMaterials.isEmpty
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ]
          : [
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
                    : Text('Record Usage'),
              ),
            ],
    );
  }
}
