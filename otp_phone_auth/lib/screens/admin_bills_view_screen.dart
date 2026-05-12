import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/smooth_animations.dart';

class AdminBillsViewScreen extends StatefulWidget {
  const AdminBillsViewScreen({super.key});

  @override
  State<AdminBillsViewScreen> createState() => _AdminBillsViewScreenState();
}

class _AdminBillsViewScreenState extends State<AdminBillsViewScreen> {
  String? _selectedSiteId;
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    // Load sites using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  Future<void> _loadBills(AdminProvider provider, String siteId) async {
    final bills = await provider.getBillsData(siteId, forceRefresh: true);
    if (mounted) {
      setState(() => _bills = bills);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              'Bills Viewing',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (_selectedSiteId != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _loadBills(adminProvider, _selectedSiteId!),
                  tooltip: 'Refresh',
                ),
            ],
          ),
          body: Column(
            children: [
              // Site selector
              _buildSiteSelector(adminProvider),

              // Bills list
              Expanded(
                child: _buildBillsList(adminProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSiteSelector(AdminProvider adminProvider) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Site',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedSiteId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              hint: const Text('Choose a site'),
              items: adminProvider.sites.map((site) {
                return DropdownMenuItem<String>(
                  value: site['id'].toString(),
                  child: Text(site['site_name'] ?? 'Unnamed Site'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSiteId = value);
                  _loadBills(adminProvider, value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList(AdminProvider adminProvider) {
    final isLoadingBills = adminProvider.isLoading('bills_${_selectedSiteId ?? ''}');

    if (adminProvider.isLoadingSites) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
      );
    }

    if (isLoadingBills) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
      );
    }

    if (_selectedSiteId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80.sp,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select a site to view bills',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80.sp,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No bills available',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBills(adminProvider, _selectedSiteId!),
      color: const Color(0xFF1A1A2E),
      child: ListView.builder(
        physics: const SmoothScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        itemCount: _bills.length,
        itemBuilder: (context, index) {
          final bill = _bills[index];
          return _buildBillCard(bill);
        },
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    final isVerified = bill['verified'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.receipt,
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
                      bill['material_name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      bill['report_date'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.pending,
                      size: 14.sp,
                      color: isVerified ? const Color(0xFF4CAF50) : const Color(0xFF1A1A2E),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isVerified ? const Color(0xFF4CAF50) : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '₹${bill['bill_amount'] ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Uploaded by',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    bill['uploaded_by'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
