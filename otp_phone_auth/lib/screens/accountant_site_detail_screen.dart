import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/construction_provider.dart';
import '../providers/change_request_provider.dart';
import '../utils/app_colors.dart';
import 'site_photo_gallery_screen.dart';

class AccountantSiteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;

  const AccountantSiteDetailScreen({super.key, required this.site});

  @override
  State<AccountantSiteDetailScreen> createState() => _AccountantSiteDetailScreenState();
}

class _AccountantSiteDetailScreenState extends State<AccountantSiteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRole; // null = All, 'Supervisor', 'Site Engineer'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed to 4 tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConstructionProvider>().loadAccountantData();
      context.read<ChangeRequestProvider>().loadPendingChangeRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterByRole(List<Map<String, dynamic>> entries) {
    if (_selectedRole == null) return entries;
    return entries.where((entry) {
      final submittedByRole = entry['submitted_by_role'] ?? entry['user_role'] ?? 'Supervisor';
      return submittedByRole == _selectedRole;
    }).toList();
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  String _formatDateHeader(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);

      if (entryDate == today) {
        return 'Today';
      } else if (entryDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConstructionProvider, ChangeRequestProvider>(
      builder: (context, provider, changeRequestProvider, child) {
        final siteId = widget.site['id'];
        final labourEntries = _filterByRole(
          provider.accountantLabourEntries
              .where((entry) => entry['site_id'] == siteId || entry['site_name'] == widget.site['site_name'])
              .toList()
        );
        final materialEntries = _filterByRole(
          provider.accountantMaterialEntries
              .where((entry) => entry['site_id'] == siteId || entry['site_name'] == widget.site['site_name'])
              .toList()
        );
        
        // Filter change requests for this site
        final siteChangeRequests = changeRequestProvider.pendingChangeRequests
            .where((req) => req['site_id'] == siteId)
            .toList();
        
        final isLoading = provider.isLoadingAccountantData;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            title: Text(
              widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site Details',
              style: const TextStyle(
                color: AppColors.deepNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.deepNavy),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.deepNavy,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.deepNavy,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                const Tab(text: 'Labour'),
                const Tab(text: 'Material'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Requests'),
                      if (siteChangeRequests.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.statusOverdue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${siteChangeRequests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Photos'),
              ],
            ),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.deepNavy),
                )
              : Column(
                  children: [
                    _buildRoleFilter(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await provider.loadAccountantData(forceRefresh: true);
                          await changeRequestProvider.loadPendingChangeRequests(forceRefresh: true);
                        },
                        color: AppColors.deepNavy,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLabourTab(labourEntries),
                            _buildMaterialTab(materialEntries),
                            _buildChangeRequestsTab(siteChangeRequests, changeRequestProvider),
                            _buildPhotosTab(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Filter by Role:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Supervisor', 'Supervisor'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Site Engineer', 'Site Engineer'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? role) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRole = role;
        });
      },
      selectedColor: AppColors.deepNavy,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.deepNavy,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.deepNavy : AppColors.deepNavy.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildLabourTab(List<Map<String, dynamic>> labourEntries) {
    if (labourEntries.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Labour Entries',
        subtitle: 'Labour entries for this site will appear here',
      );
    }

    final groupedEntries = <String, List<Map<String, dynamic>>>{};
    for (var entry in labourEntries) {
      final date = _formatDateHeader(entry['entry_date']);
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final date = groupedEntries.keys.elementAt(index);
        final entries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            ...entries.map((entry) => _buildLabourCard(entry)),
          ],
        );
      },
    );
  }

  Widget _buildMaterialTab(List<Map<String, dynamic>> materialEntries) {
    if (materialEntries.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Material Entries',
        subtitle: 'Material entries for this site will appear here',
      );
    }

    final groupedEntries = <String, List<Map<String, dynamic>>>{};
    for (var entry in materialEntries) {
      final date = _formatDateHeader(entry['entry_date']);
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final date = groupedEntries.keys.elementAt(index);
        final entries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            ...entries.map((entry) => _buildMaterialCard(entry)),
          ],
        );
      },
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> entry) {
    final extraCost = entry['extra_cost'] != null ? double.tryParse(entry['extra_cost'].toString()) ?? 0 : 0;
    final hasExtraCost = extraCost > 0;
    final submittedByRole = entry['submitted_by_role'] ?? entry['user_role'] ?? 'Supervisor';
    final roleColor = submittedByRole == 'Site Engineer' ? Color(0xFF1A1A2E) : AppColors.deepNavy;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person, size: 18, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['supervisor_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              submittedByRole,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(entry['entry_time'] ?? entry['entry_date']),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.engineering,
                    entry['labour_type'] ?? 'General',
                    AppColors.deepNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.groups,
                    '${entry['labour_count'] ?? 0} Workers',
                    AppColors.statusCompleted,
                  ),
                ),
              ],
            ),
            if (hasExtraCost) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF1A1A2E).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Color(0xFF1A1A2E)),
                        const SizedBox(width: 4),
                        Text(
                          'Extra Cost: ₹${extraCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    if (entry['extra_cost_notes'] != null && entry['extra_cost_notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry['extra_cost_notes'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> entry) {
    final extraCost = entry['extra_cost'] != null ? double.tryParse(entry['extra_cost'].toString()) ?? 0 : 0;
    final hasExtraCost = extraCost > 0;
    final submittedByRole = entry['submitted_by_role'] ?? entry['user_role'] ?? 'Supervisor';
    final roleColor = submittedByRole == 'Site Engineer' ? Color(0xFF1A1A2E) : AppColors.deepNavy;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person, size: 18, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['supervisor_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              submittedByRole,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(entry['updated_at'] ?? entry['entry_date']),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.inventory_2,
                    entry['material_type'] ?? 'Unknown',
                    AppColors.deepNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.straighten,
                    '${entry['quantity'] ?? 0} ${entry['unit'] ?? ''}',
                    AppColors.statusCompleted,
                  ),
                ),
              ],
            ),
            if (hasExtraCost) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF1A1A2E).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Color(0xFF1A1A2E)),
                        const SizedBox(width: 4),
                        Text(
                          'Extra Cost: ₹${extraCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    if (entry['extra_cost_notes'] != null && entry['extra_cost_notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry['extra_cost_notes'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRequestsTab(List<Map<String, dynamic>> changeRequests, ChangeRequestProvider provider) {
    if (changeRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No Pending Requests',
        subtitle: 'Change requests for this site will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: changeRequests.length,
      itemBuilder: (context, index) {
        final request = changeRequests[index];
        return _buildChangeRequestCard(request, provider);
      },
    );
  }

  Widget _buildChangeRequestCard(Map<String, dynamic> request, ChangeRequestProvider provider) {
    final entryDetails = request['entry_details'] as Map<String, dynamic>?;
    final entryType = request['entry_type'] as String?;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusOverdue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
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
            // Request badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pending_actions, size: 14, color: AppColors.statusOverdue),
                  SizedBox(width: 4),
                  Text(
                    'PENDING REQUEST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusOverdue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Requested by
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, size: 18, color: AppColors.deepNavy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requested by',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        request['requested_by_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Entry details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entryType == 'LABOUR' ? 'Labour Entry' : 'Material Entry',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entryType == 'LABOUR'
                        ? '${entryDetails?['labour_type']}: ${entryDetails?['labour_count']} workers'
                        : '${entryDetails?['material_type']}: ${entryDetails?['quantity']} ${entryDetails?['unit']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Request message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusOverdue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.message, size: 16, color: AppColors.statusOverdue),
                      SizedBox(width: 6),
                      Text(
                        'Request Message',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusOverdue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request['request_message'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Handle button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleRequest(request, provider),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Handle Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequest(Map<String, dynamic> request, ChangeRequestProvider provider) async {
    final newValueController = TextEditingController();
    final responseController = TextEditingController();
    
    final entryDetails = request['entry_details'] as Map<String, dynamic>?;
    final entryType = request['entry_type'] as String?;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Handle Change Request',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: AppColors.deepNavy),
                        const SizedBox(width: 6),
                        Text(
                          request['requested_by_name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request['request_message'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Current value
              Text(
                'Current Value:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entryType == 'LABOUR'
                    ? '${entryDetails?['labour_type']}: ${entryDetails?['labour_count']} workers'
                    : '${entryDetails?['material_type']}: ${entryDetails?['quantity']} ${entryDetails?['unit']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 16),
              // New value input
              TextField(
                controller: newValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'New Value',
                  hintText: 'Enter new count/quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Response message
              TextField(
                controller: responseController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Response Message',
                  hintText: 'Explain the change...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (newValueController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter new value')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Apply Change',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == true && newValueController.text.trim().isNotEmpty) {
      final response = await provider.handleChangeRequest(
        requestId: request['id'].toString(),
        newValue: int.tryParse(newValueController.text.trim()) ?? 0,
        responseMessage: responseController.text.trim(),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change applied successfully'),
            backgroundColor: const Color(0xFF1A1A2E),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to apply change'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return SitePhotoGalleryScreen(site: widget.site);
  }
}
