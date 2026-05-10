import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/budget_management_service.dart';
import '../services/cache_service.dart';
import '../services/construction_service.dart';
import '../utils/smooth_animations.dart';
import 'site_engineer_material_screen.dart';

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
    with TickerProviderStateMixin {
  final _budgetService = BudgetManagementService();
  late TabController _tabController;
  
  // Background refresh timer
  Timer? _refreshTimer;

  // Budget allocation data
  Map<String, dynamic>? _budgetAllocation;
  bool _isLoadingBudget = false;

  // Utilization data
  Map<String, dynamic>? _utilization;
  bool _isLoadingUtilization = false;
  
  // Date filter for utilization
  DateTime? _selectedFilterDate;
  bool _isFilterActive = false;
  
  // Cost type filter for utilization
  String? _selectedCostFilter; // 'material', 'labour', 'other', or null for all

  // Client requirements data
  List<Map<String, dynamic>> _clientRequirements = [];
  bool _isLoadingRequirements = false;
  bool _requirementsExpanded = false;
  
  // Phase payments data
  Map<String, dynamic>? _phasePayments;
  bool _isLoadingPhases = false;
  
  // Cache flags to prevent redundant loading
  bool _budgetLoaded = false;
  bool _utilizationLoaded = false;
  bool _requirementsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Add listener to load utilization only on first access
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 1) {
          // Load utilization only if not already loaded
          if (!_utilizationLoaded) {
            _loadUtilization();
          }
        }
      }
    });
    _loadBudgetAllocation();
    _loadClientRequirements();
    _loadPhasePayments();
    _startBackgroundRefresh();
  }

  @override
  void dispose() {
    _stopBackgroundRefresh();
    _tabController.dispose();
    super.dispose();
  }
  
  void _startBackgroundRefresh() {
    // Refresh budget data every 90 seconds (only when not actively updating)
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (timer) {
        if (mounted && !_isLoadingBudget && !_isLoadingPhases) {
          // Silently refresh current tab data (don't force, use cache if available)
          if (_tabController.index == 0) {
            _loadBudgetAllocation();
            _loadClientRequirements();
            _loadPhasePayments();
          } else if (_tabController.index == 1) {
            _loadUtilization();
          }
          // Tab index 2 is Updates (photos) - no auto-refresh needed
        }
      },
    );
  }
  
  void _stopBackgroundRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> _loadBudgetAllocation({bool forceRefresh = false}) async {
    // If forcing refresh, clear cache FIRST before loading
    if (forceRefresh) {
      print('🗑️ [BUDGET] Clearing cache before refresh');
      await CacheService.clearBudgetAllocation(widget.siteId);
      _budgetLoaded = false;
    }
    
    // Load from persistent cache first (instant display)
    if (!forceRefresh && !_budgetLoaded) {
      final cached = await CacheService.loadBudgetAllocation(widget.siteId);
      if (cached != null && mounted) {
        setState(() {
          _budgetAllocation = cached;
          _budgetLoaded = true;
        });
        print('✅ [BUDGET] Loaded allocation from persistent cache');
      }
    }
    
    // Skip if already loaded and not forcing refresh
    if (_budgetLoaded && !forceRefresh) return;
    
    setState(() => _isLoadingBudget = true);
    final budget = await _budgetService.getBudgetAllocation(widget.siteId);
    
    if (budget != null) {
      // Save to persistent cache
      await CacheService.saveBudgetAllocation(widget.siteId, budget);
    }
    
    if (mounted) {
      setState(() {
        _budgetAllocation = budget;
        _isLoadingBudget = false;
        _budgetLoaded = true;
      });
      print('✅ [BUDGET] Loaded allocation from API and saved to cache');
    }
  }

  Future<void> _loadClientRequirements({bool forceRefresh = false}) async {
    // Skip if already loaded and not forcing refresh
    if (_requirementsLoaded && !forceRefresh) return;
    
    print('🔍 Loading client requirements for site: ${widget.siteId}');
    setState(() => _isLoadingRequirements = true);
    final requirements = await _budgetService.getClientRequirements(widget.siteId);
    print('📦 Received ${requirements.length} requirements');
    if (mounted) {
      setState(() {
        _clientRequirements = requirements;
        _isLoadingRequirements = false;
        _requirementsLoaded = true;
      });
    }
  }

  Future<void> _loadPhasePayments({bool forceRefresh = false}) async {
    print('🔄 [PHASES] Loading phase payments...');
    setState(() => _isLoadingPhases = true);
    final phases = await _budgetService.getPhasePayments(widget.siteId);
    print('📦 [PHASES] Received data: $phases');
    if (mounted) {
      setState(() {
        _phasePayments = phases;
        _isLoadingPhases = false;
      });
      print('✅ [PHASES] State updated, should rebuild now');
    }
  }

  Future<void> _loadUtilization({bool forceRefresh = false}) async {
    // If forcing refresh, clear cache FIRST before loading
    if (forceRefresh) {
      print('🗑️ [BUDGET] Clearing utilization cache before refresh');
      await CacheService.clearBudgetUtilization(widget.siteId);
      _utilizationLoaded = false;
    }
    
    // Load from persistent cache first (instant display)
    if (!forceRefresh && !_utilizationLoaded && !_isFilterActive && _selectedCostFilter == null) {
      final cached = await CacheService.loadBudgetUtilization(widget.siteId);
      if (cached != null && mounted) {
        setState(() {
          _utilization = cached;
          _utilizationLoaded = true;
        });
        print('✅ [BUDGET] Loaded utilization from persistent cache');
      }
    }
    
    // Skip if already loaded and not forcing refresh
    if (_utilizationLoaded && !forceRefresh && !_isFilterActive && _selectedCostFilter == null) return;
    
    setState(() => _isLoadingUtilization = true);
    
    // Format date for API if filter is active
    String? filterDate;
    if (_isFilterActive && _selectedFilterDate != null) {
      filterDate = '${_selectedFilterDate!.year}-${_selectedFilterDate!.month.toString().padLeft(2, '0')}-${_selectedFilterDate!.day.toString().padLeft(2, '0')}';
    }
    
    final utilization = await _budgetService.getBudgetUtilization(
      widget.siteId, 
      filterDate: filterDate,
      filterType: _selectedCostFilter,
    );
    
    if (utilization != null && !_isFilterActive && _selectedCostFilter == null) {
      // Save to persistent cache only if not filtering
      await CacheService.saveBudgetUtilization(widget.siteId, utilization);
    }
    
    if (mounted) {
      setState(() {
        _utilization = utilization;
        _isLoadingUtilization = false;
        if (!_isFilterActive && _selectedCostFilter == null) {
          _utilizationLoaded = true;
        }
      });
      print('✅ [BUDGET] Loaded utilization from API${_isFilterActive || _selectedCostFilter != null ? ' (filtered)' : ' and saved to cache'}');
    }
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Budget - ${widget.siteName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
          tabs: const [
            Tab(text: 'Allocation'),
            Tab(text: 'Utilization'),
            Tab(text: 'Updates'),
            Tab(text: 'Inventory'),
            Tab(text: 'Requirement'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllocationTab(),
          _buildUtilizationTab(),
          PhotoTabsSection(siteId: widget.siteId),
          _buildInventoryTab(),
          _buildRequirementTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showAddCostDialog,
              backgroundColor: const Color(0xFF1A1A2E),
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Add Cost',
            )
          : null,
    );
  }

  Widget _buildAllocationTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadBudgetAllocation(forceRefresh: true);
        await _loadPhasePayments(forceRefresh: true);
      },
      color: const Color(0xFF1A1A2E),
      child: _isLoadingBudget
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    // Client Balance Card
                    _buildBudgetCard(
                      'Client Balance',
                      _formatCurrency(_phasePayments?['client_balance'] ?? _budgetAllocation!['total_budget']),
                      Icons.account_balance,
                      Colors.green,
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
                      backgroundColor: const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Phase Payments Section
                  if (_budgetAllocation != null) _buildPhasePaymentsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPhasePaymentsSection() {
    if (_phasePayments == null || _isLoadingPhases) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    final phases = List<Map<String, dynamic>>.from(_phasePayments!['phases'] ?? []);
    final clientBalance = _phasePayments!['client_balance'] ?? 0;
    final totalReceived = _phasePayments!['total_received'] ?? 0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments, color: Color(0xFF1A1A2E)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Phase Payments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Received: ${_formatCurrency(totalReceived)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Show all 10 phases
            for (int i = 1; i <= 10; i++) ...[
              _buildPhaseRow(i, phases, clientBalance),
              if (i < 10) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseRow(int phaseNumber, List<Map<String, dynamic>> phases, double clientBalance) {
    final phase = phases.firstWhere(
      (p) => p['phase_number'] == phaseNumber,
      orElse: () => {},
    );
    
    final isPaid = phase.isNotEmpty;
    final amount = isPaid ? phase['phase_amount'] : 0.0;
    
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: isPaid ? Colors.green : Colors.grey[300],
          child: Text(
            '$phaseNumber',
            style: TextStyle(
              color: isPaid ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phase $phaseNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isPaid) ...[
                const SizedBox(height: 4),
                Text(
                  'Paid: ${_formatCurrency(amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (phase['payment_date'] != null)
                  Text(
                    'Date: ${phase['payment_date'].toString().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ] else
                Text(
                  'Not paid yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
        if (isPaid)
          const Icon(Icons.check_circle, color: Colors.green, size: 28)
        else
          ElevatedButton.icon(
            onPressed: () => _showRecordPhasePaymentDialog(phaseNumber, clientBalance),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
      ],
    );
  }

  void _showRecordPhasePaymentDialog(int phaseNumber, double clientBalance) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isSubmitting = false; // Track submission state

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Record Phase $phaseNumber Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Client Balance',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _formatCurrency(clientBalance),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                    hintText: 'Enter payment amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Add any notes about this payment',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                // Disable button immediately
                setState(() => isSubmitting = true);
                
                if (amountController.text.isEmpty) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter amount')),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                if (amount > clientBalance) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Amount exceeds client balance (${_formatCurrency(clientBalance)})'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Close dialog immediately
                if (context.mounted) {
                  Navigator.pop(context);
                }

                // Optimistically update UI immediately (before API call)
                if (mounted) {
                  setState(() {
                    // Update phase payments optimistically
                    if (_phasePayments != null) {
                      final phases = List<Map<String, dynamic>>.from(_phasePayments!['phases'] ?? []);
                      phases.add({
                        'phase_number': phaseNumber,
                        'phase_amount': amount,
                        'payment_date': '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      });
                      _phasePayments!['phases'] = phases;
                      
                      // Update client balance
                      final currentBalance = _phasePayments!['client_balance'] ?? 0.0;
                      _phasePayments!['client_balance'] = currentBalance - amount;
                      
                      // Update total received
                      final currentReceived = _phasePayments!['total_received'] ?? 0.0;
                      _phasePayments!['total_received'] = currentReceived + amount;
                    }
                  });
                }

                // Show brief loading message (500ms)
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recording payment...'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                }

                // Call API in background with 2-second timeout
                try {
                  final result = await _budgetService.recordPhasePayment(
                    siteId: widget.siteId,
                    phaseNumber: phaseNumber,
                    phaseAmount: amount,
                    paymentDate: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  ).timeout(
                    const Duration(seconds: 2),
                    onTimeout: () {
                      print('⚠️ [PAYMENT] API timeout after 2s, optimistic update shown');
                      // Return success on timeout - optimistic update already shown
                      return {'success': true, 'message': 'Payment queued'};
                    },
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    
                    if (result['success'] == true) {
                      // Success - refresh in background to sync with server
                      _loadPhasePayments(forceRefresh: true);
                      _loadBudgetAllocation(forceRefresh: true);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Payment recorded'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      // Failed - revert optimistic update
                      _loadPhasePayments(forceRefresh: true);
                      _loadBudgetAllocation(forceRefresh: true);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['error'] ?? 'Failed to record payment'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('❌ [PAYMENT] Error: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Network error, please check connection'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Revert optimistic update
                    _loadPhasePayments(forceRefresh: true);
                    _loadBudgetAllocation(forceRefresh: true);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
              child: isSubmitting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Record Payment'),
            ),
          ],
        ),
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
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                borderRadius: _requirementsExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(4))
                    : BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.update, color: const Color(0xFF1A1A2E), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recent Updates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _requirementsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF1A1A2E),
                  ),
                ],
              ),
            ),
          ),
          if (_requirementsExpanded) ...[
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _clientRequirements.length,
              itemBuilder: (context, index) {
                final req = _clientRequirements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              req['category'] ?? 'General',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            req['date'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        req['requirement'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
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
    return RefreshIndicator(
      onRefresh: () => _loadUtilization(forceRefresh: true),
      color: const Color(0xFF1A1A2E),
      child: _isLoadingUtilization
          ? const Center(child: CircularProgressIndicator())
          : _utilization == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No utilization data available', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date Filter Card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              // Date filter row
                              Row(
                                children: [
                                  Icon(
                                    _isFilterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
                                    color: _isFilterActive ? const Color(0xFF1A1A2E) : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _isFilterActive && _selectedFilterDate != null
                                          ? 'Date: ${_selectedFilterDate!.day}/${_selectedFilterDate!.month}/${_selectedFilterDate!.year}'
                                          : 'All Dates',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _isFilterActive ? const Color(0xFF1A1A2E) : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  if (_isFilterActive)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _isFilterActive = false;
                                          _selectedFilterDate = null;
                                        });
                                        _loadUtilization(forceRefresh: true);
                                      },
                                      tooltip: 'Clear date filter',
                                      color: Colors.red,
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.calendar_today, size: 20),
                                    onPressed: _showDateFilterPicker,
                                    tooltip: 'Filter by date',
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              // Cost type filter row
                              Row(
                                children: [
                                  const Icon(Icons.category, color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedCostFilter,
                                      hint: const Text('All Costs'),
                                      isExpanded: true,
                                      underline: Container(),
                                      items: const [
                                        DropdownMenuItem(value: null, child: Text('All Costs')),
                                        DropdownMenuItem(value: 'material', child: Text('Material Only')),
                                        DropdownMenuItem(value: 'labour', child: Text('Labour Only')),
                                        DropdownMenuItem(value: 'other', child: Text('Other Only')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCostFilter = value;
                                        });
                                        _loadUtilization(forceRefresh: true);
                                      },
                                    ),
                                  ),
                                  if (_selectedCostFilter != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _selectedCostFilter = null;
                                        });
                                        _loadUtilization(forceRefresh: true);
                                      },
                                      tooltip: 'Clear cost filter',
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Summary Card
                      Card(
                        color: _getStatusColor(_utilization!['summary']['status']),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                _formatCurrency(_utilization!['summary']['total_spent']),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _isFilterActive ? 'Spent on Selected Date' : 'Total Spent',
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: (_utilization!['summary']['utilization_percentage'] ?? 0) / 100,
                                backgroundColor: Colors.white30,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 10,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(_utilization!['summary']['utilization_percentage'] ?? 0).toStringAsFixed(1)}% Utilized',
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
                            child: _buildSmallCard('Total Budget', _formatCurrency(_utilization!['summary']['total_budget']), Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallCard('Remaining', _formatCurrency(_utilization!['summary']['remaining_budget']), Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallCard('Material', _formatCurrency(_utilization!['summary']['total_material_cost']), Colors.brown),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallCard('Labour', _formatCurrency(_utilization!['summary']['total_labour_cost']), const Color(0xFF1A1A2E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Material Breakdown
                      if ((List<Map<String, dynamic>>.from(_utilization!['material_breakdown'] ?? [])).isNotEmpty) ...[
                        const Text('Material Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...(List<Map<String, dynamic>>.from(_utilization!['material_breakdown'] ?? [])).map((m) => Card(
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
                      if ((List<Map<String, dynamic>>.from(_utilization!['labour_breakdown'] ?? [])).isNotEmpty) ...[
                        const Text('Labour Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...(List<Map<String, dynamic>>.from(_utilization!['labour_breakdown'] ?? [])).map((l) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.people, color: Color(0xFF1A1A2E)),
                                title: Text(l['labour_type'] ?? 'Unknown'),
                      subtitle: Text('${l['total_count']} workers × ${_formatCurrency(l['avg_rate'])}/day'),
                      trailing: Text(_formatCurrency(l['total_cost']), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
                        const SizedBox(height: 16),
            ],
            
                      // Other Costs Breakdown
                      if ((List<Map<String, dynamic>>.from(_utilization!['other_breakdown'] ?? [])).isNotEmpty) ...[
                        const Text('Other Costs Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...(List<Map<String, dynamic>>.from(_utilization!['other_breakdown'] ?? [])).map((o) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.attach_money, color: Colors.purple),
                                title: Text(o['service_type'] ?? 'Unknown'),
                                subtitle: Text(o['vendor_type'] ?? ''),
                                trailing: Text(_formatCurrency(o['total_cost']), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            )),
                      ],
          ],
        ),
      ),
    );
  }
  
  void _showDateFilterPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1A2E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
        _isFilterActive = true;
      });
      _loadUtilization(forceRefresh: true);
    }
  }
  
  Widget _buildInventoryTab() {
    // Reuse the Site Engineer Material Screen for inventory management
    return SiteEngineerMaterialScreen(
      siteId: widget.siteId,
      siteName: widget.siteName,
    );
  }

  Widget _buildRequirementTab() {
    return RefreshIndicator(
      onRefresh: () => _loadClientRequirements(forceRefresh: true),
      color: const Color(0xFF1A1A2E),
      child: _isLoadingRequirements
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A1A2E)))
          : _clientRequirements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 72,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'No requirements yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supervisor or Site Engineer can add\nclient requirements from their Reports tab.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clientRequirements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = _clientRequirements[index];
                    final description = req['description'] as String? ?? '';
                    final amount = req['amount'];
                    final status = req['status'] as String? ?? 'Pending';
                    final addedBy = req['added_by_name'] as String? ?? 'Unknown';
                    final addedDate = req['added_date'] as String? ?? '';
                    final formattedDate = addedDate.length >= 10
                        ? addedDate.substring(0, 10)
                        : addedDate;

                    final amountDouble = amount is num
                        ? amount.toDouble()
                        : double.tryParse(amount?.toString() ?? '0') ?? 0.0;

                    Color statusColor;
                    switch (status.toLowerCase()) {
                      case 'approved':
                        statusColor = Colors.green;
                        break;
                      case 'rejected':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.orange;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: statusColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A2E),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '₹${amountDouble >= 100000 ? '${(amountDouble / 100000).toStringAsFixed(2)} L' : amountDouble >= 1000 ? '${(amountDouble / 1000).toStringAsFixed(1)} K' : amountDouble.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A2E),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.person_outline,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  addedBy,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.calendar_today_outlined,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  
  void _showAddCostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.brown),
              title: const Text('Add Material Cost'),
              subtitle: const Text('Add material purchase cost'),
              onTap: () {
                Navigator.pop(context);
                _showAddMaterialCostDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.purple),
              title: const Text('Add Other Cost'),
              subtitle: const Text('Add transport, services, etc.'),
              onTap: () {
                Navigator.pop(context);
                _showAddOtherCostDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showAddMaterialCostDialog() async {
    try {
      // Show loading dialog first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Load materials from backend
      final materials = await _budgetService.getMaterials();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (!context.mounted) return;
      
      String? selectedMaterial = 'Other';
      final customMaterialController = TextEditingController();
      final quantityController = TextEditingController();
      String selectedUnit = 'bags';
      final unitCostController = TextEditingController();
      final totalCostController = TextEditingController();
      final notesController = TextEditingController();
      DateTime selectedDate = DateTime.now();
      bool showCustomInput = true; // Start with custom input shown since "Other" is default

      void calculateTotal() {
        final qty = double.tryParse(quantityController.text) ?? 0;
        final cost = double.tryParse(unitCostController.text) ?? 0;
        totalCostController.text = (qty * cost).toStringAsFixed(2);
      }

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Material Cost'),
            content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Material Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedMaterial,
                  decoration: const InputDecoration(
                    labelText: 'Material Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'Other', child: Text('Other (Custom)')),
                    ...materials.map((material) => DropdownMenuItem(
                      value: material['name'],
                      child: Text(material['name']),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMaterial = value;
                      showCustomInput = value == 'Other';
                      if (value != 'Other') {
                        customMaterialController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Custom Material Input (shown only when "Other" is selected)
                if (showCustomInput)
                  TextField(
                    controller: customMaterialController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Material Name *',
                      hintText: 'e.g., Cement, Steel, Bricks',
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (showCustomInput) const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => calculateTotal()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['bags', 'tons', 'cubic meters', 'pieces', 'kg', 'liters', 'sq ft', 'sq meters']
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedUnit = value ?? 'bags'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitCostController,
                  decoration: const InputDecoration(
                    labelText: 'Unit Cost *',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => calculateTotal()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalCostController,
                  decoration: const InputDecoration(
                    labelText: 'Total Cost',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
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
                // Determine final material type
                String finalMaterialType;
                if (selectedMaterial == 'Other') {
                  if (customMaterialController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter custom material name')),
                    );
                    return;
                  }
                  finalMaterialType = customMaterialController.text;
                } else {
                  finalMaterialType = selectedMaterial ?? '';
                }
                
                if (finalMaterialType.isEmpty ||
                    quantityController.text.isEmpty ||
                    unitCostController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final result = await _budgetService.addMaterialCost(
                  siteId: widget.siteId,
                  materialType: finalMaterialType,
                  quantity: double.parse(quantityController.text),
                  unit: selectedUnit,
                  unitCost: double.parse(unitCostController.text),
                  totalCost: double.parse(totalCostController.text),
                  entryDate: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Material cost added')),
                    );
                    _loadUtilization(forceRefresh: true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['error'] ?? 'Failed to add material cost')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    } catch (e) {
      // Close loading dialog if it's still open
      if (context.mounted) {
        Navigator.pop(context);
      }
      print('❌ Error in material dialog: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading materials: $e')),
        );
      }
    }
  }
  
  void _showAddOtherCostDialog() {
    String selectedCostType = 'Transport';
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Other Cost'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCostType,
                  decoration: const InputDecoration(
                    labelText: 'Cost Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Transport', 'Equipment Rental', 'Services', 'Utilities', 'Miscellaneous', 'Other']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCostType = value ?? 'Transport'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of the cost',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
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
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter amount')),
                  );
                  return;
                }

                final result = await _budgetService.addOtherCost(
                  siteId: widget.siteId,
                  costType: selectedCostType,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  amount: double.parse(amountController.text),
                  entryDate: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Other cost added')),
                    );
                    _loadUtilization(forceRefresh: true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['error'] ?? 'Failed to add other cost')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
              child: const Text('Add'),
            ),
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
    final clientBalanceController = TextEditingController(
      text: (_phasePayments?['client_balance'] ?? _budgetAllocation?['total_budget'])?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: _budgetAllocation?['notes']?.toString() ?? '',
    );
    bool isSubmitting = false; // Track submission state

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  hintText: 'Enter total project budget',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: clientBalanceController,
                decoration: const InputDecoration(
                  labelText: 'Client Balance *',
                  prefixText: '₹ ',
                  hintText: 'Enter current client balance',
                  border: OutlineInputBorder(),
                  helperText: 'Amount remaining from client',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add any notes about this budget',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isSubmitting ? null : () async {
              // Disable button immediately
              setState(() => isSubmitting = true);
              
              final total = double.tryParse(totalController.text);
              final clientBalance = double.tryParse(clientBalanceController.text);
              
              if (total == null || total <= 0) {
                setState(() => isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid total budget')),
                );
                return;
              }
              
              if (clientBalance == null || clientBalance < 0) {
                setState(() => isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid client balance')),
                );
                return;
              }
              
              if (clientBalance > total) {
                setState(() => isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client balance cannot exceed total budget')),
                );
                return;
              }

              // Close dialog immediately
              if (context.mounted) {
                Navigator.pop(context);
              }

              // Optimistically update UI immediately (before API call)
              if (mounted) {
                setState(() {
                  if (_budgetAllocation != null) {
                    _budgetAllocation!['total_budget'] = total;
                  }
                  if (_phasePayments != null) {
                    _phasePayments!['client_balance'] = clientBalance;
                  }
                });
              }

              // Show brief loading message (500ms)
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating...'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
              }

              // Call API in background with 2-second timeout
              try {
                final result = await _budgetService.allocateBudget(
                  siteId: widget.siteId,
                  totalBudget: total,
                  clientBalance: clientBalance,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                ).timeout(
                  const Duration(seconds: 2),
                  onTimeout: () {
                    print('⚠️ [BUDGET] API timeout after 2s, optimistic update shown');
                    // Return success on timeout - optimistic update already shown
                    return {'message': 'Update queued'};
                  },
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
                  if (result != null) {
                    // Success - refresh in background to sync with server
                    _loadBudgetAllocation(forceRefresh: true);
                    _loadPhasePayments(forceRefresh: true);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Budget updated'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    // Failed - revert optimistic update
                    _loadBudgetAllocation(forceRefresh: true);
                    _loadPhasePayments(forceRefresh: true);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Update failed, please try again'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('❌ [BUDGET] Error: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Network error, please check connection'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Revert optimistic update
                  _loadBudgetAllocation(forceRefresh: true);
                  _loadPhasePayments(forceRefresh: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
            child: isSubmitting 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
}

// Separate widget for photo tabs with its own TabController
class PhotoTabsSection extends StatefulWidget {
  final String siteId;

  const PhotoTabsSection({super.key, required this.siteId});

  @override
  State<PhotoTabsSection> createState() => _PhotoTabsSectionState();
}

class _PhotoTabsSectionState extends State<PhotoTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _constructionService = ConstructionService();
  
  List<Map<String, dynamic>> _supervisorPhotos = [];
  List<Map<String, dynamic>> _engineerPhotos = [];
  bool _isLoadingSupervisor = false;
  bool _isLoadingEngineer = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPhotos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoadingSupervisor = true;
      _isLoadingEngineer = true;
    });

    // Load all photos for this site
    final result = await _constructionService.getAccountantPhotos(
      siteId: widget.siteId,
    );

    if (result['photos'] != null) {
      final allPhotos = List<Map<String, dynamic>>.from(result['photos']);
      
      // Separate supervisor photos (from site_photos table) and engineer photos (from work_updates table)
      // Supervisor photos have 'supervisor_name' field
      // Engineer photos have 'uploaded_by_role' field
      
      setState(() {
        _supervisorPhotos = allPhotos.where((photo) {
          // Check if it's a supervisor photo (has supervisor_name or uploaded_by_role is Supervisor)
          return photo['uploaded_by_role'] == 'Supervisor' || photo.containsKey('supervisor_name');
        }).toList();
        
        _engineerPhotos = allPhotos.where((photo) {
          // Site engineer photos
          return photo['uploaded_by_role'] == 'Site Engineer';
        }).toList();
        
        _isLoadingSupervisor = false;
        _isLoadingEngineer = false;
      });
      
      print('📸 Loaded ${_supervisorPhotos.length} supervisor photos');
      print('📸 Loaded ${_engineerPhotos.length} engineer photos');
    } else {
      setState(() {
        _isLoadingSupervisor = false;
        _isLoadingEngineer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1A1A2E),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1A1A2E),
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.photo_camera, size: 20),
                text: 'Supervisor Photos (${_supervisorPhotos.length})',
              ),
              Tab(
                icon: const Icon(Icons.engineering, size: 20),
                text: 'Site Engineer Photos (${_engineerPhotos.length})',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSupervisorPhotosTab(),
              _buildSiteEngineerPhotosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorPhotosTab() {
    if (_isLoadingSupervisor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_supervisorPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No supervisor photos yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPhotos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _supervisorPhotos.length,
        itemBuilder: (context, index) {
          final photo = _supervisorPhotos[index];
          return _buildPhotoCard(photo, isSupervisor: true);
        },
      ),
    );
  }

  Widget _buildSiteEngineerPhotosTab() {
    if (_isLoadingEngineer) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_engineerPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No site engineer photos yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPhotos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _engineerPhotos.length,
        itemBuilder: (context, index) {
          final photo = _engineerPhotos[index];
          return _buildPhotoCard(photo, isSupervisor: false);
        },
      ),
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo, {required bool isSupervisor}) {
    final imageUrl = photo['image_url'] ?? '';
    final uploadDate = photo['upload_date'] ?? photo['update_date'] ?? '';
    final timeOfDay = photo['time_of_day'] ?? '';
    final updateType = photo['update_type'] ?? '';
    final description = photo['description'] ?? '';
    final uploadedBy = isSupervisor 
        ? (photo['supervisor_name'] ?? photo['uploaded_by'] ?? 'Unknown')
        : (photo['uploaded_by'] ?? 'Unknown');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openPhotoViewer(imageUrl, photo),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              // Photo details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Update type or time of day
                    if (updateType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getUpdateTypeColor(updateType),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          updateType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (timeOfDay.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: timeOfDay == 'MORNING' ? Colors.orange : Colors.indigo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          timeOfDay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Uploaded by
                    Text(
                      'Uploaded by $uploadedBy',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Text(
                      uploadDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Description
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Open icon
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                onPressed: () => _openPhotoViewer(imageUrl, photo),
                color: const Color(0xFF1A1A2E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUpdateTypeColor(String updateType) {
    switch (updateType.toUpperCase()) {
      case 'STARTED':
        return Colors.green;
      case 'FINISHED':
        return Colors.blue;
      case 'PROGRESS':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _openPhotoViewer(String imageUrl, Map<String, dynamic> photo) {
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 80, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
