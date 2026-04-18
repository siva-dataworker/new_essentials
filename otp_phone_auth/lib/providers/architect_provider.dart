import 'dart:async';
import 'package:flutter/material.dart';
import '../services/construction_service.dart';

class ArchitectProvider extends ChangeNotifier {
  final ConstructionService _service = ConstructionService();
  
  // State
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  
  // Data
  List<String> _areas = [];
  List<String> _streets = [];
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _complaints = [];
  Map<String, dynamic> _photos = {};
  
  // Filters
  String? _selectedSite;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get areas => _areas;
  List<String> get streets => _streets;
  List<Map<String, dynamic>> get sites => _sites;
  List<Map<String, dynamic>> get documents => _documents;
  List<Map<String, dynamic>> get complaints => _complaints;
  Map<String, dynamic> get photos => _photos;
  String? get selectedSite => _selectedSite;
  
  // Initialize
  Future<void> initialize({bool enableAutoRefresh = true}) async {
    await Future.wait([
      loadAreas(),
      loadDocuments(),
      loadComplaints(),
      loadPhotos(),
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
  
  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([
      loadDocuments(),
      loadComplaints(),
      loadPhotos(),
    ]);
  }
  
  // Load areas
  Future<void> loadAreas() async {
    try {
      _areas = await _service.getAreas();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load streets
  Future<void> loadStreets(String area) async {
    try {
      _streets = await _service.getStreets(area);
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
      
      _sites = await _service.getSites(area: area, street: street);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load documents
  Future<void> loadDocuments({
    String? siteId,
    String? documentType,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final result = await _service.getArchitectDocuments(
        siteId: siteId,
        documentType: documentType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      
      if (result['success']) {
        _documents = List<Map<String, dynamic>>.from(result['documents'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load complaints
  Future<void> loadComplaints({
    String? siteId,
    String? status,
    String? priority,
  }) async {
    try {
      final result = await _service.getArchitectComplaints(
        siteId: siteId,
        status: status,
        priority: priority,
      );
      
      if (result['success']) {
        _complaints = List<Map<String, dynamic>>.from(result['complaints'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load photos
  Future<void> loadPhotos({
    String? siteId,
    String? updateType,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      _photos = await _service.getAccountantPhotos(
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
  
  // Upload document
  Future<bool> uploadDocument({
    required String siteId,
    required String documentType,
    required String title,
    String? description,
    required String filePath,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _service.uploadArchitectDocument(
        siteId: siteId,
        documentType: documentType,
        title: title,
        description: description,
        filePath: filePath,
      );
      
      _isLoading = false;
      
      if (result['success']) {
        await loadDocuments();
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
  
  // Submit complaint
  Future<bool> submitComplaint({
    required String siteId,
    required String title,
    required String description,
    String priority = 'MEDIUM',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _service.uploadArchitectComplaint(
        siteId: siteId,
        title: title,
        description: description,
        priority: priority,
      );
      
      _isLoading = false;
      
      if (result['success']) {
        await loadComplaints();
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
  
  void setSelectedSite(String siteId) {
    _selectedSite = siteId;
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
