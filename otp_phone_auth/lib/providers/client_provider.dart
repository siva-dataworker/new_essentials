import 'dart:async';
import 'package:flutter/material.dart';
import '../services/construction_service.dart';

class ClientProvider extends ChangeNotifier {
  final ConstructionService _service = ConstructionService();
  
  // State
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  
  // Data
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _progress = [];
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> _photos = [];
  List<Map<String, dynamic>> _complaints = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get sites => _sites;
  List<Map<String, dynamic>> get progress => _progress;
  List<Map<String, dynamic>> get materials => _materials;
  List<Map<String, dynamic>> get photos => _photos;
  List<Map<String, dynamic>> get complaints => _complaints;
  
  // Initialize with auto-refresh
  Future<void> initialize({bool enableAutoRefresh = true}) async {
    await loadClientData();
    
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
    await loadClientData();
  }
  
  // Load all client data
  Future<void> loadClientData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load all data in parallel for better performance
      await Future.wait([
        _loadSites(),
        _loadProgress(),
        _loadMaterials(),
        _loadPhotos(),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadSites() async {
    try {
      _sites = await _service.getSites();
    } catch (e) {
      // Silent fail for individual loads
    }
  }
  
  Future<void> _loadProgress() async {
    try {
      // Implement client progress API call
      _progress = [];
    } catch (e) {
      // Silent fail
    }
  }
  
  Future<void> _loadMaterials() async {
    try {
      _materials = await _service.getMaterials();
    } catch (e) {
      // Silent fail
    }
  }
  
  Future<void> _loadPhotos() async {
    try {
      final result = await _service.getAccountantPhotos();
      _photos = List<Map<String, dynamic>>.from(result['photos'] ?? []);
    } catch (e) {
      // Silent fail
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
