import 'package:flutter/material.dart';
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
            title: const Text(
              'Labour Count View',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Select Site',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedSiteId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a site to view labour count',
              style: TextStyle(
                fontSize: 16,
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
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No labour data available',
              style: TextStyle(
                fontSize: 16,
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
                              padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people,
              color: Color(0xFF4CAF50),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['report_date'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entered by: ${entry['entered_by'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${entry['labour_count']} Workers',
              style: const TextStyle(
                fontSize: 14,
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
