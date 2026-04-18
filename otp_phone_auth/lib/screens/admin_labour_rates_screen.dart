import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/budget_management_service.dart';
import '../utils/app_colors.dart';
import '../utils/smooth_animations.dart';

class AdminLabourRatesScreen extends StatefulWidget {
  const AdminLabourRatesScreen({super.key});

  @override
  State<AdminLabourRatesScreen> createState() => _AdminLabourRatesScreenState();
}

class _AdminLabourRatesScreenState extends State<AdminLabourRatesScreen> {
  final _budgetService = BudgetManagementService();

  // Default labour types with default rates
  static const Map<String, double> _defaultRates = {
    'General': 600,
    'Mason': 800,
    'Helper': 500,
    'Carpenter': 750,
    'Plumber': 700,
    'Electrician': 750,
    'Painter': 650,
    'Tile Layer': 700,
    'Tile Layerhelper': 700,
    'Kambi Fitter': 900,
    'Concrete Kot': 950,
    'Pile Labour': 800,
  };

  // null = using canonical default (not admin-set), non-null = admin explicitly set
  Map<String, double?> _rates = {};
  // Effective rate shown in UI (admin-set OR canonical default)
  Map<String, double> _effectiveRates = {};
  Map<String, String?> _setByNames = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    final allRates = await _budgetService.getLabourRates('global');

    // API now returns all 12 types — admin-set rate or canonical default
    final Map<String, double?> merged = {};
    final Map<String, String?> names = {};

    final Map<String, double> effective = {};
    for (final r in allRates) {
      final type = r['labour_type'] as String?;
      final rate = (r['daily_rate'] as num?)?.toDouble();
      final isAdminSet = r['is_admin_set'] as bool? ?? false;
      final setBy = r['set_by'] as String?;
      if (type != null && rate != null) {
        effective[type] = rate;
        merged[type] = isAdminSet ? rate : null;
        if (isAdminSet && setBy != null) names[type] = setBy;
      }
    }

    if (mounted) {
      setState(() {
        _rates = merged;
        _effectiveRates = effective;
        _setByNames = names;
        _isLoading = false;
      });
    }
  }

  Future<void> _editRate(String labourType) async {
    final effectiveRate = _effectiveRates[labourType];
    final ctrl = TextEditingController(
        text: effectiveRate?.toStringAsFixed(0) ?? '');
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.currency_rupee,
                  color: const Color(0xFF1A1A2E), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set Daily Rate',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E))),
                  Text(labourType,
                      style: const TextStyle(
                          fontSize: 12, color: const Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Daily Rate (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee,
                      color: const Color(0xFF1A1A2E), size: 18),
                  helperText: effectiveRate != null
                      ? 'Current: ₹${effectiveRate.toStringAsFixed(0)}/day'
                      : null,
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: const Color(0xFF1A1A2E), width: 2),
                  ),
                ),
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Rate is required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: const Icon(Icons.note_outlined,
                      color: const Color(0xFF6B7280), size: 18),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: const Color(0xFF1A1A2E), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final result = await _budgetService.setLabourRate(
        siteId: 'global',
        labourType: labourType,
        dailyRate: double.parse(ctrl.text.trim()),
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
      if (mounted) {
        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Rate for $labourType updated to ₹${ctrl.text}/day'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          await _loadRates();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result?['error'] ?? 'Failed to update rate'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    ctrl.dispose();
    notesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Labour Rates',
            style: TextStyle(
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: const Color(0xFF1A1A2E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: const Color(0xFF1A1A2E)),
            onPressed: _loadRates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)))
          : RefreshIndicator(
              onRefresh: _loadRates,
              color: const Color(0xFF1A1A2E),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: const Color(0xFF1A1A2E), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tap any row to set an admin rate. Updated rates will be shown to supervisors and site engineers.',
                            style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF1A1A2E)
                                    .withValues(alpha: 0.9)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Labour type cards
                  ..._rates.entries.map((entry) =>
                      _buildRateRow(entry.key, entry.value)),

                  if (_isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: const Color(0xFF1A1A2E))),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRateRow(String labourType, double? adminRate) {
    final hasAdminRate = adminRate != null;
    final effectiveRate = _effectiveRates[labourType];
    final setBy = _setByNames[labourType];

    return GestureDetector(
      onTap: () => _editRate(labourType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasAdminRate
                ? const Color(0xFF1A1A2E).withValues(alpha: 0.3)
                : const Color(0xFF1A1A2E).withValues(alpha: 0.08),
            width: hasAdminRate ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasAdminRate
                    ? const Color(0xFF1A1A2E).withValues(alpha: 0.1)
                    : const Color(0xFF1A1A2E).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.engineering,
                color: hasAdminRate
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labourType,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 3),
                  if (hasAdminRate && setBy != null)
                    Text('Set by $setBy',
                        style: const TextStyle(
                            fontSize: 11, color: const Color(0xFF6B7280)))
                  else
                    const Text('Canonical default',
                        style: TextStyle(
                            fontSize: 11, color: const Color(0xFF6B7280))),
                ],
              ),
            ),

            // Rate badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasAdminRate
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    effectiveRate != null
                        ? '₹${effectiveRate.toStringAsFixed(0)}/day'
                        : '--',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hasAdminRate
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasAdminRate ? 'Admin set' : 'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: hasAdminRate
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined,
                size: 16, color: const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}
