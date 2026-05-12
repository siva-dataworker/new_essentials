import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/admin_theme.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminSitesTestScreen extends StatefulWidget {
  const AdminSitesTestScreen({Key? key}) : super(key: key);

  @override
  State<AdminSitesTestScreen> createState() => _AdminSitesTestScreenState();
}

class _AdminSitesTestScreenState extends State<AdminSitesTestScreen> {
  @override
  void initState() {
    super.initState();
    // Load sites using provider on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AdminTheme.lightGray,
          appBar: AppBar(
            title: const Text('Sites Test', style: AdminTheme.heading2),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AdminTheme.primaryBlue),
                onPressed: () => provider.loadSites(forceRefresh: true),
              ),
            ],
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.isLoadingSites) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AdminTheme.primaryBlue),
            SizedBox(height: 16.h),
            const Text('Loading sites...', style: AdminTheme.bodyMedium),
          ],
        ),
      );
    }

    if (provider.sites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city_outlined, size: 64.sp, color: AdminTheme.neutralGray),
            SizedBox(height: 16.h),
            const Text('No sites found', style: AdminTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: provider.sites.length,
      itemBuilder: (context, index) {
        final site = provider.sites[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: AdminTheme.modernCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AdminTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: AdminTheme.primaryBlue,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site['site_name'] ?? 'Unnamed Site',
                          style: AdminTheme.heading3,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          site['location'] ?? 'No location',
                          style: AdminTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AdminTheme.lightGray,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'ID: ${site['id']}',
                  style: AdminTheme.caption,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
