import 'package:flutter/foundation.dart';
import '../services/material_service.dart';

class MaterialProvider with ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  // Loading states
  bool _isLoadingBalance = false;
  bool _isLoadingHistory = false;
  bool _isLoadingAlerts = false;
  bool _isSubmitting = false;

  // Data
  List<Map<String, dynamic>> _materialBalance = [];
  List<Map<String, dynamic>> _usageHistory = [];
  List<Map<String, dynamic>> _lowStockAlerts = [];
  List<String> _materialTypes = [];

  // Error
  String? _error;

  // Getters
  bool get isLoadingBalance => _isLoadingBalance;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingAlerts => _isLoadingAlerts;
  bool get isSubmitting => _isSubmitting;
  List<Map<String, dynamic>> get materialBalance => _materialBalance;
  List<Map<String, dynamic>> get usageHistory => _usageHistory;
  List<Map<String, dynamic>> get lowStockAlerts => _lowStockAlerts;
  List<String> get materialTypes => _materialTypes;
  String? get error => _error;

  // Load material balance for a site
  Future<void> loadMaterialBalance(String siteId, {bool forceRefresh = false}) async {
    _isLoadingBalance = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _materialService.getMaterialBalance(siteId);
      
      if (result['success'] == true) {
        _materialBalance = List<Map<String, dynamic>>.from(result['balance'] ?? []);
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingBalance = false;
      notifyListeners();
    }
  }

  // Load usage history
  Future<void> loadUsageHistory(String siteId, {String? materialType}) async {
    _isLoadingHistory = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _materialService.getMaterialUsageHistory(
        siteId: siteId,
        materialType: materialType,
      );
      
      if (result['success'] == true) {
        _usageHistory = List<Map<String, dynamic>>.from(result['usage_history'] ?? []);
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Load low stock alerts
  Future<void> loadLowStockAlerts() async {
    _isLoadingAlerts = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _materialService.getLowStockAlerts();
      
      if (result['success'] == true) {
        _lowStockAlerts = List<Map<String, dynamic>>.from(result['alerts'] ?? []);
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAlerts = false;
      notifyListeners();
    }
  }

  // Load material types
  Future<void> loadMaterialTypes() async {
    try {
      final result = await _materialService.getMaterialTypes();
      
      if (result['success'] == true) {
        _materialTypes = List<String>.from(result['material_types'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Record material usage
  Future<Map<String, dynamic>> recordMaterialUsage({
    required String siteId,
    required String materialType,
    required double quantityUsed,
    required String unit,
    String? notes,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _materialService.recordMaterialUsage(
        siteId: siteId,
        materialType: materialType,
        quantityUsed: quantityUsed,
        unit: unit,
        notes: notes,
      );

      if (result['success'] == true) {
        // Reload balance after successful submission
        await loadMaterialBalance(siteId, forceRefresh: true);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Add material stock
  Future<Map<String, dynamic>> addMaterialStock({
    required String siteId,
    required String materialType,
    required double quantity,
    required String unit,
    String? notes,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _materialService.addMaterialStock(
        siteId: siteId,
        materialType: materialType,
        quantity: quantity,
        unit: unit,
        notes: notes,
      );

      if (result['success'] == true) {
        // Reload balance after successful submission
        await loadMaterialBalance(siteId, forceRefresh: true);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _materialBalance = [];
    _usageHistory = [];
    _lowStockAlerts = [];
    _materialTypes = [];
    _error = null;
    notifyListeners();
  }
}
