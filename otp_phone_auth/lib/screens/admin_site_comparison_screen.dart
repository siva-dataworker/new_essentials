import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/smooth_animations.dart';

class AdminSiteComparisonScreen extends StatefulWidget {
  const AdminSiteComparisonScreen({super.key, required List<Map<String, dynamic>> sites});

  @override
  State<AdminSiteComparisonScreen> createState() => _AdminSiteComparisonScreenState();
}

class _AdminSiteComparisonScreenState extends State<AdminSiteComparisonScreen> {
  String? _site1Id;
  String? _site2Id;
  Map<String, dynamic>? _comparisonData;

  @override
  void initState() {
    super.initState();
    // Load sites using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  Future<void> _compareSites(AdminProvider provider) async {
    if (_site1Id == null || _site2Id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both sites')),
        );
      }
      return;
    }

    if (_site1Id == _site2Id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select different sites')),
        );
      }
      return;
    }

    final data = await provider.compareSites(_site1Id!, _site2Id!);
    if (mounted) {
      if (data != null) {
        setState(() => _comparisonData = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error comparing sites')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final isLoading = adminProvider.isLoading('comparison');

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              'Site Comparison',
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
              if (_site1Id != null && _site2Id != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _compareSites(adminProvider),
                  tooltip: 'Refresh',
                ),
            ],
          ),
          body: Column(
            children: [
              // Site selectors
              Container(
                padding: EdgeInsets.all(16.r),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Site 1',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              DropdownButtonFormField<String>(
                                value: _site1Id,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                ),
                                hint: Text('Select', style: TextStyle(fontSize: 13.sp)),
                                items: adminProvider.sites.map((site) {
                                  return DropdownMenuItem<String>(
                                    value: site['id'].toString(),
                                    child: Text(
                                      site['site_name'] ?? 'Unnamed Site',
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _site1Id = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: const Icon(Icons.compare_arrows, color: Color(0xFF1A1A2E)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Site 2',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              DropdownButtonFormField<String>(
                                value: _site2Id,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                ),
                                hint: Text('Select', style: TextStyle(fontSize: 13.sp)),
                                items: adminProvider.sites.map((site) {
                                  return DropdownMenuItem<String>(
                                    value: site['id'].toString(),
                                    child: Text(
                                      site['site_name'] ?? 'Unnamed Site',
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _site2Id = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _compareSites(adminProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 32.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // Comparison results
              Expanded(
                child: _comparisonData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.compare_arrows,
                              size: 80.sp,
                              color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Select two sites to compare',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _compareSites(adminProvider),
                        color: const Color(0xFF1A1A2E),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            children: [
                              _buildComparisonCard(
                                'Built-up Area',
                                '${_comparisonData!['site1']['built_up_area'] ?? '0'} sq ft',
                                '${_comparisonData!['site2']['built_up_area'] ?? '0'} sq ft',
                                Icons.square_foot,
                              ),
                              _buildComparisonCard(
                                'Project Value',
                                '₹${_formatAmount(_comparisonData!['site1']['project_value'])}',
                                '₹${_formatAmount(_comparisonData!['site2']['project_value'])}',
                                Icons.account_balance_wallet,
                              ),
                              _buildComparisonCard(
                                'Total Cost',
                                '₹${_formatAmount(_comparisonData!['site1']['total_cost'])}',
                                '₹${_formatAmount(_comparisonData!['site2']['total_cost'])}',
                                Icons.account_balance,
                              ),
                              _buildComparisonCard(
                                'Profit/Loss',
                                '₹${_formatAmount(_comparisonData!['site1']['profit_loss'])}',
                                '₹${_formatAmount(_comparisonData!['site2']['profit_loss'])}',
                                Icons.trending_up,
                              ),
                              _buildComparisonCard(
                                'Total Labour',
                                '${_comparisonData!['site1']['total_labour_count'] ?? '0'}',
                                '${_comparisonData!['site2']['total_labour_count'] ?? '0'}',
                                Icons.people,
                              ),
                              _buildComparisonCard(
                                'Material Cost',
                                '₹${_formatAmount(_comparisonData!['site1']['total_material_cost'])}',
                                '₹${_formatAmount(_comparisonData!['site2']['total_material_cost'])}',
                                Icons.inventory_2,
                              ),
                            ],
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

  Widget _buildComparisonCard(String label, String value1, String value2, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A1A2E), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    value1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    value2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final value = double.tryParse(amount.toString()) ?? 0;
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }
}
