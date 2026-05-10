import 'package:flutter/material.dart';
import '../services/budget_management_service.dart';
import '../services/construction_service.dart';

class AdminLocalLabourRatesScreen extends StatefulWidget {
  const AdminLocalLabourRatesScreen({super.key});

  @override
  State<AdminLocalLabourRatesScreen> createState() => _AdminLocalLabourRatesScreenState();
}

class _AdminLocalLabourRatesScreenState extends State<AdminLocalLabourRatesScreen> {
  final _budgetService = BudgetManagementService();
  final _constructionService = ConstructionService();
  
  bool _isLoading = true;
  List<String> _areas = [];
  String? _selectedArea;
  List<Map<String, dynamic>> _localRates = [];
  List<String> _allLabourTypes = []; // All labour types from global rates

  @override
  void initState() {
    super.initState();
    _loadAreas();
    _loadAllLabourTypes();
  }

  Future<void> _loadAllLabourTypes() async {
    try {
      // Load all labour types from global rates
      final globalRates = await _budgetService.getLabourRates('global');
      final types = globalRates
          .map((r) => r['labour_type'] as String?)
          .where((t) => t != null)
          .cast<String>()
          .toList();
      
      if (mounted) {
        setState(() {
          _allLabourTypes = types;
        });
      }
    } catch (e) {
      print('Error loading labour types: $e');
    }
  }

  Future<void> _loadAreas() async {
    setState(() => _isLoading = true);
    
    try {
      final areas = await _constructionService.getAreas();
      
      if (mounted) {
        setState(() {
          _areas = areas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading areas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadLocalRates(String area) async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _budgetService.getLocalLabourRates(area);
      
      if (mounted) {
        setState(() {
          _localRates = result['rates'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading local rates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSetRateDialog(String labourType) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Local Rate for $_selectedArea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labourType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Daily Rate (₹)',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final rate = double.tryParse(controller.text);
              if (rate == null || rate <= 0) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid rate'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              if (!context.mounted) return;
              Navigator.pop(context);
              await _setLocalRate(labourType, rate);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
            ),
            child: const Text('Set Rate'),
          ),
        ],
      ),
    );
  }

  Future<void> _setLocalRate(String labourType, double rate) async {
    try {
      final result = await _budgetService.setLocalLabourRate(
        area: _selectedArea!,
        labourType: labourType,
        rate: rate,
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Local rate set for $_selectedArea'),
            backgroundColor: Colors.green,
          ),
        );
        _loadLocalRates(_selectedArea!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to set rate'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Local Labour Rates',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: Column(
        children: [
          // Area Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Area',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedArea,
                  decoration: InputDecoration(
                    hintText: 'Choose an area',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _areas.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text(area),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedArea = value);
                      _loadLocalRates(value);
                    }
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Rates List
          Expanded(
            child: _selectedArea == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Select an Area',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose an area to set local labour rates',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A2E),
                        ),
                      )
                    : _buildRatesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesList() {
    // Use all labour types from global rates
    final labourTypes = _allLabourTypes;
    
    // If no labour types loaded yet, show loading or empty state
    if (labourTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.engineering,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Labour Types',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add labour types from the global rates screen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF1A1A2E),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Setting local rates for: $_selectedArea',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Labour Type Cards
        ...labourTypes.map((labourType) {
          final localRate = _localRates.firstWhere(
            (rate) => rate['labour_type'] == labourType,
            orElse: () => {},
          );
          
          final hasLocalRate = localRate.isNotEmpty;
          final rate = hasLocalRate ? localRate['daily_rate'] : null;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasLocalRate
                      ? const Color(0xFF059669).withValues(alpha: 0.1)
                      : const Color(0xFF6B7280).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person,
                  color: hasLocalRate
                      ? const Color(0xFF059669)
                      : const Color(0xFF6B7280),
                  size: 24,
                ),
              ),
              title: Text(
                labourType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              subtitle: Text(
                hasLocalRate
                    ? 'Local rate set for $_selectedArea'
                    : 'Using global rate',
                style: TextStyle(
                  fontSize: 12,
                  color: hasLocalRate
                      ? const Color(0xFF059669)
                      : const Color(0xFF6B7280),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasLocalRate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${rate?.toStringAsFixed(0)}/day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      hasLocalRate ? Icons.edit : Icons.add,
                      color: const Color(0xFF1A1A2E),
                    ),
                    onPressed: () => _showSetRateDialog(labourType),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
