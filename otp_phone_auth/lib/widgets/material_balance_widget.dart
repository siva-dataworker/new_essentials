import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../utils/app_colors.dart';
import 'material_usage_dialog.dart';
import '../screens/material_usage_history_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.r),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        if (provider.materialBalance.isEmpty) {
          return Card(
            margin: EdgeInsets.all(16.r),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64.sp,
                    color: AppColors.mediumGray,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No Material Inventory',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
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
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Icon(Icons.inventory_2, color: AppColors.textPrimary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Material Inventory',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.canRecordUsage)
                    ElevatedButton.icon(
                      onPressed: _showUsageDialog,
                      icon: Icon(Icons.remove_circle_outline, size: 18.sp),
                      label: const Text('Use Material'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
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
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: InkWell(
                    onTap: () => _viewHistory(materialType),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Material Type and Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  materialType,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Current Balance (Large)
                          Row(
                            children: [
                              Text(
                                currentBalance.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'remaining',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Stock Details
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8.r),
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
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '${initialStock.toStringAsFixed(1)} $unit',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1.w,
                                  height: 40.h,
                                  color: AppColors.mediumGray,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Used',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '${totalUsed.toStringAsFixed(1)} $unit',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),

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
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16.sp,
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
