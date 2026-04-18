import 'dart:async';
import 'package:flutter/material.dart';
import '../services/construction_service.dart';

class SupervisorProvider extends ChangeNotifier {
  final ConstructionService _service = ConstructionService();
  
  // State
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  bool _isInitialized = false;
  
  // Data
  List<String> _areas = [];
  List<String> _streets = [];
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _materials = [];
  Map<String, dynamic>? _todayEntries;
  Map<String, dynamic> _historyData = {};
  
  // Filters
  String? _selectedArea;
  String? _selectedStreet;
  String? _selectedSite;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get streets => _streets;
  List<Map<String, dynamic>> get sites => _sites;
  List<Map<String, dynamic>> get materials => _materials;
  Map<String, dynamic>? get todayEntries => _todayEntries;
  Map<String, dynamic> get historyData => _historyData;
  String? get selectedArea => _selectedArea;
  String? get selectedStreet => _selectedStreet;
  String? get selectedSite => _selectedSite;
  
  // Auto-initialize when first accessed
  void _ensureInitialized() {
    if (!_isInitialized) {
      _isInitialized = true;
      initialize(enableAutoRefresh: true);
    }
  }
  
  // Override getter to trigger initialization
  @override
  List<String> get areas {
    _ensureInitialized();
    return _areas;
  }
  
  // Initialize with auto-refresh
  Future<void> initialize({bool enableAutoRefresh = true}) async {
    await loadAreas();
    await loadMaterials();
    
    if (enableAutoRefresh) {
      startAutoRefresh();
    }
  }
  
  // Auto-refresh every 30 seconds
  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) {
      refreshData();
    });
  }
  
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    if (_selectedSite != null) {
      await Future.wait([
        loadTodayEntries(_selectedSite!),
        loadHistory(_selectedSite!),
      ]);
    }
  }
  
  // Load areas
  Future<void> loadAreas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _areas = await _service.getAreas();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load streets
  Future<void> loadStreets(String area) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _streets = await _service.getStreets(area);
      _selectedArea = area;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load sites
  Future<void> loadSites({String? area, String? street}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _sites = await _service.getSites(area: area, street: street);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load materials
  Future<void> loadMaterials() async {
    try {
      _materials = await _service.getMaterials();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load today's entries
  Future<void> loadTodayEntries(String siteId) async {
    try {
      _todayEntries = await _service.getTodayEntries(siteId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load history
  Future<void> loadHistory(String siteId) async {
    try {
      _historyData = await _service.getSupervisorHistory(siteId: siteId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Submit labour
  Future<bool> submitLabour({
    required String siteId,
    required int labourCount,
    String? labourType,
    String? notes,
    double? extraCost,
    String? extraCostNotes,
    DateTime? customDateTime,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _service.submitLabourCount(
        siteId: siteId,
        labourCount: labourCount,
        labourType: labourType,
        notes: notes,
        extraCost: extraCost,
        extraCostNotes: extraCostNotes,
        customDateTime: customDateTime,
      );
      
      _isLoading = false;
      
      if (result['success']) {
        // Auto-refresh data
        await refreshData();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Submit material balance
  Future<bool> submitMaterialBalance({
    required String siteId,
    required List<Map<String, dynamic>> materials,
    double? extraCost,
    String? extraCostNotes,
    DateTime? customDateTime,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _service.submitMaterialBalance(
        siteId: siteId,
        materials: materials,
        extraCost: extraCost,
        extraCostNotes: extraCostNotes,
        customDateTime: customDateTime,
      );
      
      _isLoading = false;
      
      if (result['success']) {
        // Auto-refresh data
        await refreshData();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Set selected site
  void setSelectedSite(String siteId) {
    _selectedSite = siteId;
    loadTodayEntries(siteId);
    loadHistory(siteId);
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
