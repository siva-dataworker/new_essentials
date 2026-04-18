import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/smooth_animations.dart';

class AdminSiteComparisonScreen extends StatefulWidget {
  const AdminSiteComparisonScreen({super.key});

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
            title: const Text(
              'Site Comparison',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Site 1',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _site1Id,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                hint: const Text('Select', style: TextStyle(fontSize: 13)),
                                items: adminProvider.sites.map((site) {
                                  return DropdownMenuItem<String>(
                                    value: site['id'].toString(),
                                    child: Text(
                                      site['site_name'] ?? 'Unnamed Site',
                                      style: const TextStyle(fontSize: 13),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.compare_arrows, color: Color(0xFF1A1A2E)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Site 2',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _site2Id,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                hint: const Text('Select', style: TextStyle(fontSize: 13)),
                                items: adminProvider.sites.map((site) {
                                  return DropdownMenuItem<String>(
                                    value: site['id'].toString(),
                                    child: Text(
                                      site['site_name'] ?? 'Unnamed Site',
                                      style: const TextStyle(fontSize: 13),
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _compareSites(adminProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 15,
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
                              size: 80,
                              color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select two sites to compare',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
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
                          padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
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
