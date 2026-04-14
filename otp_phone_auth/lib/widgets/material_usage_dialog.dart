import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../utils/app_colors.dart';

class MaterialUsageDialog extends StatefulWidget {
  final String siteId;
  final List<Map<String, dynamic>> availableMaterials;

  const MaterialUsageDialog({
    Key? key,
    required this.siteId,
    required this.availableMaterials,
  }) : super(key: key);

  @override
  State<MaterialUsageDialog> createState() => _MaterialUsageDialogState();
}

class _MaterialUsageDialogState extends State<MaterialUsageDialog> {
  String? _selectedMaterial;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String _unit = '';
  double _currentBalance = 0.0;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMaterialSelected(String? materialType) {
    if (materialType == null) return;

    setState(() {
      _selectedMaterial = materialType;
      
      // Find the material details
      final material = widget.availableMaterials.firstWhere(
        (m) => m['material_type'] == materialType,
        orElse: () => {},
      );
      
      _unit = material['unit'] ?? '';
      _currentBalance = (material['current_balance'] ?? 0.0).toDouble();
    });
  }

  Future<void> _submitUsage() async {
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a material')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    // Warning if quantity exceeds balance
    if (quantity > _currentBalance) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Stock'),
          content: Text(
            'You are trying to use $quantity $_unit but only $_currentBalance $_unit is available. Continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    final provider = Provider.of<MaterialProvider>(context, listen: false);
    
    final result = await provider.recordMaterialUsage(
      siteId: widget.siteId,
      materialType: _selectedMaterial!,
      quantityUsed: quantity,
      unit: _unit,
      notes: _notesController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Material usage recorded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to record usage'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaterialProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory_2, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Record Material Usage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Material Dropdown
            const Text(
              'Material Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mediumGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMaterial,
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Select material'),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: widget.availableMaterials.map((material) {
                    final materialType = material['material_type'] as String;
                    final balance = (material['current_balance'] ?? 0.0).toDouble();
                    final unit = material['unit'] ?? '';
                    final status = material['stock_status'] ?? 'IN_STOCK';
                    
                    Color statusColor = AppColors.success;
                    if (status == 'LOW_STOCK') statusColor = AppColors.mediumGray;
                    if (status == 'OUT_OF_STOCK') statusColor = AppColors.error;

                    return DropdownMenuItem<String>(
                      value: materialType,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(materialType),
                          ),
                          Text(
                            '$balance $unit',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onMaterialSelected,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Current Balance Display
            if (_selectedMaterial != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Current Balance: $_currentBalance $_unit',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quantity Input
            const Text(
              'Quantity Used',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                suffixText: _unit.isNotEmpty ? _unit : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Notes Input
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about usage...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submitUsage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Record Usage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
