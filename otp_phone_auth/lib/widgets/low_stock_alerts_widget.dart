import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../utils/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LowStockAlertsWidget extends StatefulWidget {
  const LowStockAlertsWidget({Key? key}) : super(key: key);

  @override
  State<LowStockAlertsWidget> createState() => _LowStockAlertsWidgetState();
}

class _LowStockAlertsWidgetState extends State<LowStockAlertsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  Future<void> _loadAlerts() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    await provider.loadLowStockAlerts();
  }

  Color _getAlertColor(String status) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return AppColors.error;
      case 'LOW_STOCK':
        return AppColors.mediumGray;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getAlertIcon(String status) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return Icons.error;
      case 'LOW_STOCK':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAlerts) {
          return Card(
            margin: EdgeInsets.all(16.r),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (provider.lowStockAlerts.isEmpty) {
          return Card(
            margin: EdgeInsets.all(16.r),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 32.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Stock Levels Good',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'No low stock alerts at this time.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Count alerts by type
        final outOfStock = provider.lowStockAlerts
            .where((alert) => alert['stock_status'] == 'OUT_OF_STOCK')
            .length;
        final lowStock = provider.lowStockAlerts
            .where((alert) => alert['stock_status'] == 'LOW_STOCK')
            .length;

        return Card(
          margin: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: AppColors.mediumGray),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Low Stock Alerts',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$outOfStock out of stock, $lowStock running low',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${provider.lowStockAlerts.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Alerts List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.lowStockAlerts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.mediumGray,
                ),
                itemBuilder: (context, index) {
                  final alert = provider.lowStockAlerts[index];
                  final siteName = alert['site_name'] ?? 'Unknown Site';
                  final customerName = alert['customer_name'] ?? '';
                  final materialType = alert['material_type'] ?? 'Unknown';
                  final currentBalance = ((alert['current_balance'] ?? 0.0) as num).toDouble();
                  final unit = alert['unit'] ?? '';
                  final status = alert['stock_status'] ?? 'LOW_STOCK';
                  final alertColor = _getAlertColor(status);
                  final alertIcon = _getAlertIcon(status);

                  return Container(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        // Alert Icon
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: alertColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            alertIcon,
                            color: alertColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                materialType,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                customerName.isNotEmpty
                                    ? '$customerName - $siteName'
                                    : siteName,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currentBalance.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: alertColor,
                              ),
                            ),
                            Text(
                              unit,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Refresh Button
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.mediumGray),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loadAlerts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Alerts'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
