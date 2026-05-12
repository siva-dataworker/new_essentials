import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/smooth_animations.dart';

class AdminMaterialPurchasesScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const AdminMaterialPurchasesScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<AdminMaterialPurchasesScreen> createState() => _AdminMaterialPurchasesScreenState();
}

class _AdminMaterialPurchasesScreenState extends State<AdminMaterialPurchasesScreen> {
  List<Map<String, dynamic>> _purchases = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    // Load purchases using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchases(context.read<AdminProvider>());
    });
  }

  Future<void> _loadPurchases(AdminProvider provider) async {
    final purchases = await provider.getMaterialPurchases(widget.siteId, forceRefresh: true);

    if (mounted) {
      double total = 0;
      for (var purchase in purchases) {
        total += double.tryParse(purchase['total_purchased']?.toString() ?? '0') ?? 0;
      }

      setState(() {
        _purchases = purchases;
        _totalAmount = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final isLoading = adminProvider.isLoading('materials_${widget.siteId}');

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material Purchases',
                  style: TextStyle(
                    color: const Color(0xFF1A1A2E),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.siteName,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadPurchases(adminProvider),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: Column(
            children: [
              // Total summary
              Container(
                margin: EdgeInsets.all(16.r),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Material Cost',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '₹${_formatAmount(_totalAmount)}',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Purchases list
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
                      )
                    : _purchases.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 80.sp,
                                  color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No material purchases found',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadPurchases(adminProvider),
                            color: const Color(0xFF1A1A2E),
                            child: ListView.builder(
                              physics: const SmoothScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                              itemCount: _purchases.length,
                              itemBuilder: (context, index) {
                                final purchase = _purchases[index];
                                return _buildPurchaseCard(purchase);
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final amount = double.tryParse(purchase['total_purchased']?.toString() ?? '0') ?? 0;
    final percentage = _totalAmount > 0 ? (amount / _totalAmount * 100) : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.inventory_2,
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
                      purchase['material_name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${purchase['purchase_count'] ?? 0} purchases',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${_formatAmount(amount)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: const Color(0xFFF8F9FA),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A1A2E)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }
}
