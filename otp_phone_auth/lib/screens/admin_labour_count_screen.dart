import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/smooth_animations.dart';

class AdminLabourCountScreen extends StatefulWidget {
  const AdminLabourCountScreen({super.key});

  @override
  State<AdminLabourCountScreen> createState() => _AdminLabourCountScreenState();
}

class _AdminLabourCountScreenState extends State<AdminLabourCountScreen> {
  String? _selectedSiteId;
  List<Map<String, dynamic>> _labourData = [];

  @override
  void initState() {
    super.initState();
    // Load sites using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  Future<void> _loadLabourData(AdminProvider provider, String siteId) async {
    final data = await provider.getLabourData(siteId, forceRefresh: true);
    if (mounted) {
      setState(() => _labourData = data);
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
              'Labour Count View',
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
                  onPressed: () => _loadLabourData(adminProvider, _selectedSiteId!),
                  tooltip: 'Refresh',
                ),
            ],
          ),
          body: Column(
            children: [
              // Site selector
              _buildSiteSelector(adminProvider),

              // Labour data list
              Expanded(
                child: _buildLabourList(adminProvider),
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
                  _loadLabourData(adminProvider, value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabourList(AdminProvider adminProvider) {
    final isLoadingLabour = adminProvider.isLoading('labour_${_selectedSiteId ?? ''}');

    if (adminProvider.isLoadingSites) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
      );
    }

    if (isLoadingLabour) {
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
              Icons.people_outline,
              size: 80.sp,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select a site to view labour count',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_labourData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80.sp,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No labour data available',
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
      onRefresh: () => _loadLabourData(adminProvider, _selectedSiteId!),
      color: const Color(0xFF1A1A2E),
      child: ListView.builder(
        physics: const SmoothScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        itemCount: _labourData.length,
        itemBuilder: (context, index) {
          final entry = _labourData[index];
          return _buildLabourCard(entry);
        },
      ),
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> entry) {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.people,
              color: const Color(0xFF4CAF50),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['report_date'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Entered by: ${entry['entered_by'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              '${entry['labour_count']} Workers',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
