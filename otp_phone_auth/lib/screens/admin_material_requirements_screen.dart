import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../utils/black_white_theme.dart';

class AdminMaterialRequirementsScreen extends StatefulWidget {
  const AdminMaterialRequirementsScreen({super.key});

  @override
  State<AdminMaterialRequirementsScreen> createState() => _AdminMaterialRequirementsScreenState();
}

class _AdminMaterialRequirementsScreenState extends State<AdminMaterialRequirementsScreen> {
  final _constructionService = ConstructionService();
  List<Map<String, dynamic>> _requirements = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  Future<void> _loadRequirements() async {
    setState(() => _isLoading = true);
    try {
      final result = await _constructionService.getMaterialRequirements();
      if (result['success']) {
        setState(() {
          _requirements = List<Map<String, dynamic>>.from(result['requirements'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading material requirements: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredRequirements {
    if (_filterStatus == 'all') return _requirements;
    return _requirements.where((req) => req['status'] == _filterStatus).toList();
  }

  Future<void> _updateStatus(String requirementId, String newStatus) async {
    final result = await _constructionService.updateMaterialRequirementStatus(
      requirementId: requirementId,
      status: newStatus,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Status updated'),
          backgroundColor: Colors.green,
        ),
      );
      _loadRequirements();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BWColors.background,
      appBar: AppBar(
        title: const Text('Material Requirements'),
        backgroundColor: BWColors.card,
        foregroundColor: BWColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: BWColors.card,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', _requirements.length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending',
                      _requirements.where((r) => r['status'] == 'pending').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approved', 'approved',
                      _requirements.where((r) => r['status'] == 'approved').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ordered', 'ordered',
                      _requirements.where((r) => r['status'] == 'ordered').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delivered', 'delivered',
                      _requirements.where((r) => r['status'] == 'delivered').length),
                ],
              ),
            ),
          ),

          // Requirements List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRequirements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: BWColors.secondaryText),
                            const SizedBox(height: 16),
                            Text(
                              'No material requirements',
                              style: TextStyle(
                                fontSize: 16,
                                color: BWColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRequirements,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRequirements.length,
                          itemBuilder: (context, index) {
                            final req = _filteredRequirements[index];
                            return _buildRequirementCard(req);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: BWColors.surface,
      selectedColor: BWColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? BWColors.primary : BWColors.secondaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRequirementCard(Map<String, dynamic> req) {
    final priority = req['priority'] ?? 'normal';
    final status = req['status'] ?? 'pending';

    Color priorityColor = BWColors.muted;
    IconData priorityIcon = Icons.circle;
    if (priority == 'urgent') {
      priorityColor = Colors.red;
      priorityIcon = Icons.error;
    } else if (priority == 'normal') {
      priorityColor = Colors.orange;
      priorityIcon = Icons.warning;
    } else {
      priorityColor = Colors.green;
      priorityIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(priorityIcon, color: priorityColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    req['material_name'] ?? 'Unknown Material',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BWColors.primary,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),

            // Quantity
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 16, color: BWColors.muted),
                const SizedBox(width: 8),
                Text(
                  '${req['quantity']} ${req['unit']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Site Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BWColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, size: 14, color: BWColors.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          req['site_name'] ?? 'Unknown Site',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_city, size: 14, color: BWColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        '${req['area']} - ${req['street']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BWColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  if (req['supervisor_name'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: BWColors.muted),
                        const SizedBox(width: 6),
                        Text(
                          req['supervisor_name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: BWColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Notes
            if (req['notes'] != null && req['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BWColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: BWColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16, color: BWColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req['notes'],
                        style: TextStyle(
                          fontSize: 13,
                          color: BWColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Date
            const SizedBox(height: 12),
            Text(
              'Requested: ${req['created_at']}',
              style: TextStyle(
                fontSize: 12,
                color: BWColors.secondaryText,
              ),
            ),

            // Action Buttons
            const SizedBox(height: 12),
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(req['id'], 'approved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (status == 'approved') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(req['id'], 'ordered'),
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: const Text('Mark Ordered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (status == 'ordered') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(req['id'], 'delivered'),
                      icon: const Icon(Icons.local_shipping, size: 18),
                      label: const Text('Mark Delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'ordered':
        color = Colors.blue;
        label = 'Ordered';
        break;
      case 'delivered':
        color = Colors.purple;
        label = 'Delivered';
        break;
      default:
        color = BWColors.muted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
