import 'package:flutter/material.dart';
import '../services/budget_management_service.dart';
import '../utils/app_colors.dart';

class AdminBudgetManagementScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const AdminBudgetManagementScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<AdminBudgetManagementScreen> createState() => _AdminBudgetManagementScreenState();
}

class _AdminBudgetManagementScreenState extends State<AdminBudgetManagementScreen>
    with SingleTickerProviderStateMixin {
  final _budgetService = BudgetManagementService();
  late TabController _tabController;

  // Budget allocation data
  Map<String, dynamic>? _budgetAllocation;
  bool _isLoadingBudget = false;

  // Utilization data
  Map<String, dynamic>? _utilization;
  bool _isLoadingUtilization = false;

  // Client requirements data
  List<Map<String, dynamic>> _clientRequirements = [];
  bool _isLoadingRequirements = false;
  bool _requirementsExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadTabData(_tabController.index);
      }
    });
    _loadBudgetAllocation();
    _loadClientRequirements(); // Load requirements on init
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTabData(int index) {
    switch (index) {
      case 0:
        _loadBudgetAllocation();
        _loadClientRequirements();
        break;
      case 1:
        _loadUtilization();
        break;
    }
  }

  Future<void> _loadBudgetAllocation() async {
    setState(() => _isLoadingBudget = true);
    final budget = await _budgetService.getBudgetAllocation(widget.siteId);
    setState(() {
      _budgetAllocation = budget;
      _isLoadingBudget = false;
    });
  }

  Future<void> _loadClientRequirements() async {
    print('🔍 Loading client requirements for site: ${widget.siteId}');
    setState(() => _isLoadingRequirements = true);
    final requirements = await _budgetService.getClientRequirements(widget.siteId);
    print('📦 Received ${requirements.length} requirements');
    setState(() {
      _clientRequirements = requirements;
      _isLoadingRequirements = false;
    });
  }

  Future<void> _loadUtilization() async {
    setState(() => _isLoadingUtilization = true);
    final utilization = await _budgetService.getBudgetUtilization(widget.siteId);
    setState(() {
      _utilization = utilization;
      _isLoadingUtilization = false;
    });
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    double value = amount is String ? double.tryParse(amount) ?? 0 : amount.toDouble();

    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(2)} K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget - ${widget.siteName}'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Allocation'),
            Tab(text: 'Utilization'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllocationTab(),
          _buildUtilizationTab(),
        ],
      ),
    );
  }

  Widget _buildAllocationTab() {
    if (_isLoadingBudget) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_budgetAllocation != null) ...[
            _buildBudgetCard(
              'Total Budget',
              _formatCurrency(_budgetAllocation!['total_budget']),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            if (_budgetAllocation!['material_budget'] != null)
              _buildBudgetCard(
                'Material Budget',
                _formatCurrency(_budgetAllocation!['material_budget']),
                Icons.inventory_2,
                Colors.brown,
              ),
            const SizedBox(height: 12),
            if (_budgetAllocation!['labour_budget'] != null)
              _buildBudgetCard(
                'Labour Budget',
                _formatCurrency(_budgetAllocation!['labour_budget']),
                Icons.people,
                AppColors.safetyOrange,
              ),
            const SizedBox(height: 12),
            if (_budgetAllocation!['other_budget'] != null)
              _buildBudgetCard(
                'Other Budget',
                _formatCurrency(_budgetAllocation!['other_budget']),
                Icons.more_horiz,
                Colors.purple,
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Allocated By', _budgetAllocation!['allocated_by'] ?? 'N/A'),
                    _buildDetailRow('Date', _budgetAllocation!['allocated_date']?.substring(0, 10) ?? 'N/A'),
                    _buildDetailRow('Status', _budgetAllocation!['status'] ?? 'N/A'),
                    if (_budgetAllocation!['notes'] != null && _budgetAllocation!['notes'].toString().isNotEmpty)
                      _buildDetailRow('Notes', _budgetAllocation!['notes']),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No budget allocated yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAllocateBudgetDialog(),
            icon: const Icon(Icons.add),
            label: Text(_budgetAllocation == null ? 'Allocate Budget' : 'Update Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          // Recent Updates Dropdown
          _buildRecentUpdatesDropdown(),
        ],
      ),
    );
  }

  Widget _buildRecentUpdatesDropdown() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _requirementsExpanded = !_requirementsExpanded);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: _requirementsExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(4))
                    : BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.update, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recent Updates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (_clientRequirements.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_clientRequirements.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _requirementsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_requirementsExpanded) ...[
            if (_isLoadingRequirements)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_clientRequirements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No client requirements yet',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _clientRequirements.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final req = _clientRequirements[index];
                  final date = req['added_date'] as String?;
                  final formattedDate = date != null && date.length >= 10
                      ? date.substring(0, 10)
                      : 'N/A';
                  final amount = req['amount'];
                  final formattedAmount = amount != null
                      ? '₹${(amount is String ? double.tryParse(amount) ?? 0 : amount).toStringAsFixed(0)}'
                      : '₹0';
                  final siteName = req['full_site_name'] ?? req['site_name'] ?? 'Unknown Site';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.safetyOrange.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: AppColors.safetyOrange, size: 20),
                    ),
                    title: Text(
                      req['description'] ?? 'No description',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.deepNavy),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                siteName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.deepNavy,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Added by: ${req['added_by_name'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Date: $formattedDate',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.statusCompleted.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formattedAmount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusCompleted,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildUtilizationTab() {
    if (_isLoadingUtilization) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_utilization == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No utilization data available', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    final summary = _utilization!['summary'];
    final materialBreakdown = List<Map<String, dynamic>>.from(_utilization!['material_breakdown'] ?? []);
    final labourBreakdown = List<Map<String, dynamic>>.from(_utilization!['labour_breakdown'] ?? []);

    return RefreshIndicator(
      onRefresh: _loadUtilization,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Card(
              color: _getStatusColor(summary['status']),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _formatCurrency(summary['total_spent']),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Total Spent',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (summary['utilization_percentage'] ?? 0) / 100,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(summary['utilization_percentage'] ?? 0).toStringAsFixed(1)}% Utilized',
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Budget Overview
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard('Total Budget', _formatCurrency(summary['total_budget']), Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard('Remaining', _formatCurrency(summary['remaining_budget']), Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard('Material', _formatCurrency(summary['total_material_cost']), Colors.brown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard('Labour', _formatCurrency(summary['total_labour_cost']), AppColors.safetyOrange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Material Breakdown
            if (materialBreakdown.isNotEmpty) ...[
              const Text('Material Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...materialBreakdown.map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2, color: Colors.brown),
                      title: Text(m['material_type'] ?? 'Unknown'),
                      subtitle: Text('${m['total_quantity']} ${m['unit']}'),
                      trailing: Text(_formatCurrency(m['total_cost']), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Labour Breakdown
            if (labourBreakdown.isNotEmpty) ...[
              const Text('Labour Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...labourBreakdown.map((l) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.people, color: AppColors.safetyOrange),
                      title: Text(l['labour_type'] ?? 'Unknown'),
                      subtitle: Text('${l['total_count']} workers × ${_formatCurrency(l['avg_rate'])}/day'),
                      trailing: Text(_formatCurrency(l['total_cost']), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXCEEDED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showAllocateBudgetDialog() {
    final totalController = TextEditingController(
      text: _budgetAllocation?['total_budget']?.toString() ?? '',
    );
    final materialController = TextEditingController(
      text: _budgetAllocation?['material_budget']?.toString() ?? '',
    );
    final labourController = TextEditingController(
      text: _budgetAllocation?['labour_budget']?.toString() ?? '',
    );
    final otherController = TextEditingController(
      text: _budgetAllocation?['other_budget']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: _budgetAllocation?['notes']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_budgetAllocation == null ? 'Allocate Budget' : 'Update Budget'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: totalController,
                decoration: const InputDecoration(
                  labelText: 'Total Budget *',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: materialController,
                decoration: const InputDecoration(
                  labelText: 'Material Budget',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labourController,
                decoration: const InputDecoration(
                  labelText: 'Labour Budget',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otherController,
                decoration: const InputDecoration(
                  labelText: 'Other Budget',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final total = double.tryParse(totalController.text);
              if (total == null || total <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid total budget')),
                );
                return;
              }

              final result = await _budgetService.allocateBudget(
                siteId: widget.siteId,
                totalBudget: total,
                materialBudget: double.tryParse(materialController.text),
                labourBudget: double.tryParse(labourController.text),
                otherBudget: double.tryParse(otherController.text),
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget allocated successfully')),
                  );
                  _loadBudgetAllocation();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to allocate budget')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
