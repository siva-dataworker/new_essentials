import 'dart:async';
import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../services/accountant_bills_service.dart';

class AccountantProvider extends ChangeNotifier {
  final ConstructionService _constructionService = ConstructionService();
  final AccountantBillsService _billsService = AccountantBillsService();
  
  // State
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  
  // Data
  List<String> _areas = [];
  List<String> _streets = [];
  List<Map<String, dynamic>> _sites = [];
  Map<String, dynamic> _entries = {};
  Map<String, dynamic> _photos = {};
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _agreements = [];
  
  // Filters
  String? _selectedArea;
  String? _selectedStreet;
  String? _selectedSite;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get areas => _areas;
  List<String> get streets => _streets;
  List<Map<String, dynamic>> get sites => _sites;
  Map<String, dynamic> get entries => _entries;
  Map<String, dynamic> get photos => _photos;
  List<Map<String, dynamic>> get bills => _bills;
  List<Map<String, dynamic>> get agreements => _agreements;
  String? get selectedSite => _selectedSite;
  
  // Initialize
  Future<void> initialize({bool enableAutoRefresh = true}) async {
    await Future.wait([
      loadAreas(),
      loadAllEntries(),
      loadAllPhotos(),
    ]);
    
    if (enableAutoRefresh) {
      startAutoRefresh();
    }
  }
  
  // Auto-refresh
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
    await Future.wait([
      loadAllEntries(),
      loadAllPhotos(),
      if (_selectedSite != null) loadBillsForSite(_selectedSite!),
    ]);
  }
  
  // Load areas
  Future<void> loadAreas() async {
    try {
      _areas = await _constructionService.getAreas();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load streets
  Future<void> loadStreets(String area) async {
    try {
      _streets = await _constructionService.getStreets(area);
      _selectedArea = area;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load sites
  Future<void> loadSites({String? area, String? street}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _sites = await _constructionService.getSites(area: area, street: street);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load all entries
  Future<void> loadAllEntries() async {
    try {
      _entries = await _constructionService.getAccountantEntries();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load all photos
  Future<void> loadAllPhotos({
    String? siteId,
    String? updateType,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      _photos = await _constructionService.getAccountantPhotos(
        siteId: siteId,
        updateType: updateType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load bills for site
  Future<void> loadBillsForSite(String siteId) async {
    try {
      // TODO: Fix this - getBillsForSite method doesn't exist
      // final result = await _billsService.getBillsForSite(siteId);
      // if (result['success']) {
      //   _bills = List<Map<String, dynamic>>.from(result['bills'] ?? []);
      //   notifyListeners();
      // }
      _error = 'Method not implemented';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Upload bill
  Future<bool> uploadBill({
    required String siteId,
    required String materialType,
    required double quantity,
    required double totalAmount,
    String? unit,
    double? pricePerUnit,
    String? billNumber,
    String? billUrl,
    String? vendorName,
    String? billDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _constructionService.uploadMaterialBill(
        siteId: siteId,
        materialType: materialType,
        quantity: quantity,
        totalAmount: totalAmount,
        unit: unit,
        pricePerUnit: pricePerUnit,
        billNumber: billNumber,
        billUrl: billUrl,
        vendorName: vendorName,
        billDate: billDate,
      );
      
      _isLoading = false;
      
      if (result['success']) {
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
    loadBillsForSite(siteId);
    notifyListeners();
  }
  
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
