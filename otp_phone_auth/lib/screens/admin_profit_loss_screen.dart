import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'admin_site_comparison_screen.dart';
import 'admin_site_documents_screen.dart';
import 'admin_material_purchases_screen.dart';
import '../utils/smooth_animations.dart';

class AdminProfitLossScreen extends StatefulWidget {
  const AdminProfitLossScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfitLossScreen> createState() => _AdminProfitLossScreenState();
}

class _AdminProfitLossScreenState extends State<AdminProfitLossScreen> {
  final _authService = AuthService();
  
  List<Map<String, dynamic>> _sites = [];
  String? _selectedSiteId;
  String? _selectedSiteName;
  Map<String, dynamic>? _profitLossData;
  bool _isLoadingSites = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoadingSites = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sites = List<Map<String, dynamic>>.from(data['sites']);
        });
      }
    } catch (e) {
      print('Error loading sites: $e');
    } finally {
      setState(() => _isLoadingSites = false);
    }
  }

  Future<void> _loadProfitLossData(String siteId) async {
    setState(() => _isLoadingData = true);

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/profit-loss/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _profitLossData = data;
        });
      }
    } catch (e) {
      print('Error loading P/L data: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Complete Accounts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: AdminSiteComparisonScreen(sites: _sites),
                ),
              );
            },
            tooltip: 'Compare Sites',
          ),
        ],
      ),
      body: Column(
        children: [
          // Site selector
          Container(
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
                    items: _sites.map((site) {
                      return DropdownMenuItem<String>(
                        value: site['id'],
                        child: Text(site['site_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final site = _sites.firstWhere((s) => s['id'] == value);
                        setState(() {
                          _selectedSiteId = value;
                          _selectedSiteName = site['site_name'];
                        });
                        _loadProfitLossData(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // P/L Data
          Expanded(
            child: _isLoadingData
                ? const Center(
                    child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)),
                  )
                : _profitLossData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              size: 80,
                              color: const Color(0xFF6B7280).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a site to view accounts',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMetricsCard(),
                            const SizedBox(height: 16),
                            _buildCostBreakdown(),
                            const SizedBox(height: 16),
                            _buildQuickActions(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard() {
    final profitLoss = double.tryParse(_profitLossData?['profit_loss']?.toString() ?? '0') ?? 0;
    final isProfit = profitLoss >= 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isProfit
            ? const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? const Color(0xFF1A1A2E) : Colors.red).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _profitLossData?['site_name'] ?? 'N/A',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                'Built-up Area',
                '${_profitLossData?['built_up_area'] ?? '0'} sq ft',
                Icons.square_foot,
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildMetricItem(
                'Project Value',
                '₹${_formatAmount(_profitLossData?['project_value'])}',
                Icons.account_balance_wallet,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  isProfit ? 'PROFIT' : 'LOSS',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_formatAmount(_profitLossData?['profit_loss'])}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildCostRow(
            'Labour Cost',
            _profitLossData?['labour_cost'],
            Icons.people,
            const Color(0xFF4CAF50),
          ),
          const Divider(height: 24),
          _buildCostRow(
            'Material Cost',
            _profitLossData?['material_cost'],
            Icons.inventory_2,
            const Color(0xFF1A1A2E),
          ),
          const Divider(height: 24),
          _buildCostRow(
            'Total Cost',
            _profitLossData?['total_cost'],
            Icons.account_balance,
            const Color(0xFF1A1A2E),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, dynamic amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
        Text(
          '₹${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    if (_selectedSiteId == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        _buildActionButton(
          'View Material Purchases',
          Icons.shopping_cart,
          const Color(0xFF1A1A2E),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminMaterialPurchasesScreen(
                  siteId: _selectedSiteId!,
                  siteName: _selectedSiteName!,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'View Site Documents',
          Icons.folder,
          const Color(0xFF1A1A2E),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminSiteDocumentsScreen(
                  siteId: _selectedSiteId!,
                  siteName: _selectedSiteName!,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
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
