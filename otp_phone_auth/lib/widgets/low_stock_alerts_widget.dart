import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../utils/app_colors.dart';

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
            margin: const EdgeInsets.all(16),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (provider.lowStockAlerts.isEmpty) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Stock Levels Good',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No low stock alerts at this time.',
                          style: TextStyle(
                            fontSize: 14,
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
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
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
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Low Stock Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$outOfStock out of stock, $lowStock running low',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Alert Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: alertColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            alertIcon,
                            color: alertColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                materialType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                customerName.isNotEmpty
                                    ? '$customerName - $siteName'
                                    : siteName,
                                style: TextStyle(
                                  fontSize: 12,
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: alertColor,
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
                      ],
                    ),
                  );
                },
              ),

              // Refresh Button
              Container(
                padding: const EdgeInsets.all(16),
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
