import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/admin_theme.dart';
import 'admin_site_comparison_screen.dart';
import 'admin_site_documents_screen.dart';
import 'admin_material_purchases_screen.dart';

class AdminProfitLossImproved extends StatefulWidget {
  const AdminProfitLossImproved({Key? key}) : super(key: key);

  @override
  State<AdminProfitLossImproved> createState() => _AdminProfitLossImprovedState();
}

class _AdminProfitLossImprovedState extends State<AdminProfitLossImproved> with SingleTickerProviderStateMixin {
  String? _selectedSiteId;
  String? _selectedSiteName;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Load sites on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSites();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSiteSelected(String siteId, String siteName) {
    setState(() {
      _selectedSiteId = siteId;
      _selectedSiteName = siteName;
    });
    
    // Load P/L data
    context.read<AdminProvider>().getProfitLossData(siteId);
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.lightGray,
      appBar: AppBar(
        title: const Text(
          'Complete Accounts',
          style: AdminTheme.heading2,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows, color: AdminTheme.primaryBlue),
            onPressed: () async {
              final provider = context.read<AdminProvider>();
              if (provider.sites.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminSiteComparisonScreen(sites: provider.sites),
                  ),
                );
              }
            },
            tooltip: 'Compare Sites',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Site selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Site', style: AdminTheme.bodySmall),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSiteId,
                      decoration: AdminTheme.inputDecoration(
                        hint: 'Choose a site',
                        prefixIcon: Icons.location_city,
                      ),
                      items: provider.sites.map((site) {
                        return DropdownMenuItem<String>(
                          value: site['id'].toString(),
                          child: Text(site['site_name'] ?? 'Unnamed Site'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final site = provider.sites.firstWhere(
                            (s) => s['id'].toString() == value,
                          );
                          _onSiteSelected(value, site['site_name'] ?? 'Site');
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _selectedSiteId == null
                    ? _buildEmptyState()
                    : provider.isLoading('pl_$_selectedSiteId')
                        ? _buildLoadingState()
                        : _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AdminTheme.blueGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a site to view accounts',
            style: AdminTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from the dropdown above',
            style: AdminTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AdminTheme.shimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AdminTheme.shimmerLoading(
                  width: double.infinity,
                  height: 120,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminTheme.shimmerLoading(
                  width: double.infinity,
                  height: 120,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminProvider provider) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: provider.getProfitLossData(_selectedSiteId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }

        final data = snapshot.data!;
        final profitLoss = double.tryParse(data['profit_loss']?.toString() ?? '0') ?? 0;
        final isProfit = profitLoss >= 0;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfitLossCard(data, isProfit),
                const SizedBox(height: 16),
                _buildMetricsGrid(data),
                const SizedBox(height: 16),
                _buildCostBreakdown(data),
                const SizedBox(height: 16),
                _buildQuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfitLossCard(Map<String, dynamic> data, bool isProfit) {
    final profitLoss = double.tryParse(data['profit_loss']?.toString() ?? '0') ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AdminTheme.gradientCard(
        isProfit ? AdminTheme.greenGradient : AdminTheme.pinkGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedSiteName ?? 'Site',
                      style: AdminTheme.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isProfit ? 'PROFIT' : 'LOSS',
                      style: AdminTheme.caption.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isProfit ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '₹${_formatAmount(profitLoss)}',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: AdminTheme.metricCard(
            label: 'Built-up Area',
            value: '${data['built_up_area'] ?? '0'} sq ft',
            icon: Icons.square_foot,
            color: AdminTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AdminTheme.metricCard(
            label: 'Project Value',
            value: '₹${_formatAmount(data['project_value'])}',
            icon: Icons.account_balance_wallet,
            color: AdminTheme.accentPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdown(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cost Breakdown', style: AdminTheme.heading3),
          const SizedBox(height: 20),
          _buildCostRow(
            'Labour Cost',
            data['labour_cost'],
            Icons.people,
            AdminTheme.successGreen,
          ),
          const SizedBox(height: 16),
          _buildCostRow(
            'Material Cost',
            data['material_cost'],
            Icons.inventory_2,
            AdminTheme.warningAmber,
          ),
          const Divider(height: 32),
          _buildCostRow(
            'Total Cost',
            data['total_cost'],
            Icons.account_balance,
            AdminTheme.darkGray,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, dynamic amount, IconData icon, Color color, {bool isTotal = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: isTotal ? AdminTheme.heading3 : AdminTheme.bodyLarge,
          ),
        ),
        Text(
          '₹${_formatAmount(amount)}',
          style: (isTotal ? AdminTheme.heading2 : AdminTheme.heading3).copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Quick Actions', style: AdminTheme.heading3),
        const SizedBox(height: 12),
        _buildActionButton(
          'Material Purchases',
          Icons.shopping_cart,
          AdminTheme.warningAmber,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminMaterialPurchasesScreen(
                  siteId: int.parse(_selectedSiteId!),
                  siteName: _selectedSiteName!,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Site Documents',
          Icons.folder,
          AdminTheme.primaryBlue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminSiteDocumentsScreen(
                  siteId: int.parse(_selectedSiteId!),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AdminTheme.modernCard(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
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
