import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class AdminSiteComparisonScreen extends StatefulWidget {
  final List<Map<String, dynamic>> sites;
  
  const AdminSiteComparisonScreen({Key? key, required this.sites}) : super(key: key);

  @override
  State<AdminSiteComparisonScreen> createState() => _AdminSiteComparisonScreenState();
}

class _AdminSiteComparisonScreenState extends State<AdminSiteComparisonScreen> {
  final _authService = AuthService();
  
  String? _site1Id;
  String? _site2Id;
  Map<String, dynamic>? _comparisonData;
  bool _isLoading = false;

  Future<void> _compareSites() async {
    if (_site1Id == null || _site2Id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both sites')),
      );
      return;
    }

    if (_site1Id == _site2Id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select different sites')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/admin/sites/compare/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({
          'site1_id': _site1Id,
          'site2_id': _site2Id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _comparisonData = data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSlate,
      appBar: AppBar(
        title: const Text(
          'Site Comparison',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cleanWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
      ),
      body: Column(
        children: [
          // Site selectors
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cleanWhite,
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
                              color: AppColors.deepNavy,
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
                              fillColor: AppColors.lightSlate,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Select', style: TextStyle(fontSize: 13)),
                            items: widget.sites.map((site) {
                              return DropdownMenuItem<String>(
                                value: site['id'],
                                child: Text(
                                  site['site_name'],
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
                      child: Icon(Icons.compare_arrows, color: AppColors.safetyOrange),
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
                              color: AppColors.deepNavy,
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
                              fillColor: AppColors.lightSlate,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Select', style: TextStyle(fontSize: 13)),
                            items: widget.sites.map((site) {
                              return DropdownMenuItem<String>(
                                value: site['id'],
                                child: Text(
                                  site['site_name'],
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
                  onPressed: _isLoading ? null : _compareSites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safetyOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select two sites to compare',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
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
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String label, String value1, String value2, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.safetyOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
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
                    color: AppColors.lightSlate,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightSlate,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
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
