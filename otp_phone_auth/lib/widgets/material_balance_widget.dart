import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../utils/app_colors.dart';
import 'material_usage_dialog.dart';
import '../screens/material_usage_history_screen.dart';

class MaterialBalanceWidget extends StatefulWidget {
  final String siteId;
  final bool canRecordUsage; // Supervisor can record usage

  const MaterialBalanceWidget({
    Key? key,
    required this.siteId,
    this.canRecordUsage = false,
  }) : super(key: key);

  @override
  State<MaterialBalanceWidget> createState() => _MaterialBalanceWidgetState();
}

class _MaterialBalanceWidgetState extends State<MaterialBalanceWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    await provider.loadMaterialBalance(widget.siteId);
  }

  Future<void> _showUsageDialog() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    
    if (provider.materialBalance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No materials available. Please add stock first.'),
        ),
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => MaterialUsageDialog(
        siteId: widget.siteId,
        availableMaterials: provider.materialBalance,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _viewHistory(String materialType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialUsageHistoryScreen(
          siteId: widget.siteId,
          materialType: materialType,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return AppColors.error;
      case 'LOW_STOCK':
        return AppColors.mediumGray;
      case 'IN_STOCK':
      default:
        return AppColors.success;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return 'Out of Stock';
      case 'LOW_STOCK':
        return 'Low Stock';
      case 'IN_STOCK':
      default:
        return 'In Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBalance) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.materialBalance.isEmpty) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Material Inventory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No materials have been added to this site yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.inventory_2, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Material Inventory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.canRecordUsage)
                    ElevatedButton.icon(
                      onPressed: _showUsageDialog,
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('Use Material'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Material List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.materialBalance.length,
              itemBuilder: (context, index) {
                final material = provider.materialBalance[index];
                final materialType = material['material_type'] ?? 'Unknown';
                final currentBalance = (material['current_balance'] ?? 0.0).toDouble();
                final totalUsed = (material['total_used'] ?? 0.0).toDouble();
                final initialStock = (material['initial_stock'] ?? 0.0).toDouble();
                final unit = material['unit'] ?? '';
                final status = material['stock_status'] ?? 'IN_STOCK';
                final statusColor = _getStatusColor(status);
                final statusText = _getStatusText(status);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _viewHistory(materialType),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Material Type and Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  materialType,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Current Balance (Large)
                          Row(
                            children: [
                              Text(
                                currentBalance.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'remaining',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Stock Details
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Initial Stock',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${initialStock.toStringAsFixed(1)} $unit',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.mediumGray,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Used',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${totalUsed.toStringAsFixed(1)} $unit',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // View History Link
                          InkWell(
                            onTap: () => _viewHistory(materialType),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View Usage History',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
