import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/admin_provider.dart';
import 'package:shimmer/shimmer.dart';

class AdminLabourCountScreen extends StatefulWidget {
  const AdminLabourCountScreen({Key? key}) : super(key: key);

  @override
  State<AdminLabourCountScreen> createState() => _AdminLabourCountScreenState();
}

class _AdminLabourCountScreenState extends State<AdminLabourCountScreen> with AutomaticKeepAliveClientMixin {
  String? _selectedSiteId;
  String? _selectedSiteName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load sites immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  Future<void> _onSiteSelected(String siteId, String siteName) async {
    setState(() {
      _selectedSiteId = siteId;
      _selectedSiteName = siteName;
    });
    await context.read<AdminProvider>().loadLabourData(siteId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text(
          'Labour Count View',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        actions: [
          if (_selectedSiteId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AdminProvider>().loadLabourData(_selectedSiteId!, forceRefresh: true);
              },
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Site selector with improved UI
              _buildSiteSelector(provider),
              
              // Labour data list
              Expanded(
                child: _buildLabourList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSiteSelector(AdminProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: AppColors.statusCompleted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Site',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          provider.isLoadingSites
              ? _buildShimmerDropdown()
              : DropdownButtonFormField<String>(
                  value: _selectedSiteId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.statusCompleted.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.statusCompleted.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.statusCompleted, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.lightSlate,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(Icons.business, color: AppColors.statusCompleted),
                  ),
                  hint: const Text('Choose a site'),
                  items: provider.sites.map((site) {
                    return DropdownMenuItem<String>(
                      value: site['id'].toString(),
                      child: Text(
                        site['site_name'] ?? 'Unnamed Site',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final site = provider.sites.firstWhere((s) => s['id'].toString() == value);
                      _onSiteSelected(value, site['site_name'] ?? 'Unnamed Site');
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildLabourList(AdminProvider provider) {
    if (provider.isLoadingData && _selectedSiteId != null) {
      return _buildShimmerList();
    }
    
    if (_selectedSiteId == null) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'Select a Site',
        subtitle: 'Choose a site from the dropdown to view labour count data',
      );
    }
    
    final labourData = provider._labourDataCache[_selectedSiteId] ?? [];
    
    if (labourData.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Labour Data',
        subtitle: 'No labour count entries found for this site',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.loadLabourData(_selectedSiteId!, forceRefresh: true),
      color: AppColors.statusCompleted,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: labourData.length,
        itemBuilder: (context, index) {
          final entry = labourData[index];
          return _buildLabourCard(entry, index);
        },
      ),
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> entry, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) 
