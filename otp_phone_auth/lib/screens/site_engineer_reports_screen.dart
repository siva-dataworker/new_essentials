import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/construction_provider.dart';
import '../utils/app_colors.dart';

class SiteEngineerReportsScreen extends StatefulWidget {
  const SiteEngineerReportsScreen({super.key});

  @override
  State<SiteEngineerReportsScreen> createState() =>
      _SiteEngineerReportsScreenState();
}

class _SiteEngineerReportsScreenState
    extends State<SiteEngineerReportsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConstructionProvider>();
      if (provider.sites.isEmpty) {
        provider.loadSites();
      }
    });
  }

  void _showClientRequirementDialog(Map<String, dynamic> site) {
    final provider = Provider.of<ConstructionProvider>(context, listen: false);
    final siteId = site['id'] as String? ?? site['site_id'] as String? ?? '';
    final siteName =
        '${site['customer_name'] ?? ''} ${site['site_name'] ?? ''}'.trim();

    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Client Extra Requirement',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: AppColors.deepNavy.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppColors.deepNavy, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        siteName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter requirement description',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.description, color: AppColors.deepNavy),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.currency_rupee, color: AppColors.deepNavy),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final description = descriptionController.text.trim();
              final amountText = amountController.text.trim();

              if (description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter description')),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid amount')),
                );
                return;
              }

              final success = await provider.addClientRequirement(
                  siteId, description, amount);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Client requirement added successfully'
                        : 'Failed to add requirement'),
                    backgroundColor:
                        success ? AppColors.statusCompleted : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConstructionProvider>(
      builder: (context, provider, _) {
        final sites = provider.sites;
        final isLoading = sites.isEmpty && provider.error == null;

        return Scaffold(
          backgroundColor: AppColors.lightSlate,
          appBar: AppBar(
            title: Text(
              'Reports',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.cleanWhite,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.deepNavy),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.deepNavy),
                onPressed: () =>
                    provider.loadSites(forceRefresh: true),
              ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.deepNavy))
              : sites.isEmpty
                  ? _buildEmpty()
                  : _buildSiteList(sites),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off,
              size: 72.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          Text(
            'No sites available',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy),
          ),
          SizedBox(height: 8.h),
          Text(
            'Contact your accountant to assign sites.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteList(List<Map<String, dynamic>> sites) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<ConstructionProvider>().loadSites(forceRefresh: true),
      color: AppColors.deepNavy,
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              '${sites.length} site${sites.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...sites.map((site) => _buildSiteCard(site)),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    final customerName = site['customer_name'] as String? ?? '';
    final siteName = site['site_name'] as String? ?? 'Unknown Site';
    final area = site['area'] as String? ?? '';
    final street = site['street'] as String? ?? '';
    final location = [area, street].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.location_city,
                  color: AppColors.deepNavy, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName.isNotEmpty
                        ? '$customerName - $siteName'
                        : siteName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.place,
                            size: 13.sp,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.7)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),
            ElevatedButton(
              onPressed: () => _showClientRequirementDialog(site),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Add\nRequirement',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
