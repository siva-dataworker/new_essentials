import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class AdminProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Cache for sites
  List<Map<String, dynamic>> _sites = [];
  bool _sitesLoaded = false;
  bool _isLoadingSites = false;
  
  // Cache for site-specific data
  final Map<String, List<Map<String, dynamic>>> _labourDataCache = {};
  final Map<String, List<Map<String, dynamic>>> _billsDataCache = {};
  final Map<String, Map<String, dynamic>> _profitLossCache = {};
  final Map<String, List<Map<String, dynamic>>> _materialPurchasesCache = {};
  final Map<String, Map<String, List<Map<String, dynamic>>>> _documentsCache = {};
  
  // Loading states
  final Map<String, bool> _loadingStates = {};
  
  // Getters
  List<Map<String, dynamic>> get sites => _sites;
  bool get sitesLoaded => _sitesLoaded;
  bool get isLoadingSites => _isLoadingSites;
  
  bool isLoading(String key) => _loadingStates[key] ?? false;
  
  // Get sites (cached)
  Future<void> loadSites({bool forceRefresh = false}) async {
    if (_sitesLoaded && !forceRefresh) return;
    
    _isLoadingSites = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _sites = List<Map<String, dynamic>>.from(data['sites']);
        _sitesLoaded = true;
      }
    } catch (e) {
      print('Error loading sites: $e');
    } finally {
      _isLoadingSites = false;
      notifyListeners();
    }
  }
  
  // Get labour data (cached)
  Future<List<Map<String, dynamic>>> getLabourData(String siteId, {bool forceRefresh = false}) async {
    if (_labourDataCache.containsKey(siteId) && !forceRefresh) {
      return _labourDataCache[siteId]!;
    }
    
    _loadingStates['labour_$siteId'] = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/labour-count/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _labourDataCache[siteId] = List<Map<String, dynamic>>.from(data['labour_data']);
        return _labourDataCache[siteId]!;
      }
    } catch (e) {
      print('Error loading labour data: $e');
    } finally {
      _loadingStates['labour_$siteId'] = false;
      notifyListeners();
    }
    
    return [];
  }
  
  // Get bills data (cached)
  Future<List<Map<String, dynamic>>> getBillsData(String siteId, {bool forceRefresh = false}) async {
    if (_billsDataCache.containsKey(siteId) && !forceRefresh) {
      return _billsDataCache[siteId]!;
    }
    
    _loadingStates['bills_$siteId'] = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/bills/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _billsDataCache[siteId] = List<Map<String, dynamic>>.from(data['bills']);
        return _billsDataCache[siteId]!;
      }
    } catch (e) {
      print('Error loading bills: $e');
    } finally {
      _loadingStates['bills_$siteId'] = false;
      notifyListeners();
    }
    
    return [];
  }
  
  // Get profit/loss data (cached)
  Future<Map<String, dynamic>?> getProfitLossData(String siteId, {bool forceRefresh = false}) async {
    if (_profitLossCache.containsKey(siteId) && !forceRefresh) {
      return _profitLossCache[siteId];
    }
    
    _loadingStates['pl_$siteId'] = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/profit-loss/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _profitLossCache[siteId] = data;
        return data;
      }
    } catch (e) {
      print('Error loading P/L data: $e');
    } finally {
      _loadingStates['pl_$siteId'] = false;
      notifyListeners();
    }
    
    return null;
  }
  
  // Get material purchases (cached)
  Future<List<Map<String, dynamic>>> getMaterialPurchases(String siteId, {bool forceRefresh = false}) async {
    if (_materialPurchasesCache.containsKey(siteId) && !forceRefresh) {
      return _materialPurchasesCache[siteId]!;
    }
    
    _loadingStates['materials_$siteId'] = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/material-purchases/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _materialPurchasesCache[siteId] = List<Map<String, dynamic>>.from(data['purchases']);
        return _materialPurchasesCache[siteId]!;
      }
    } catch (e) {
      print('Error loading material purchases: $e');
    } finally {
      _loadingStates['materials_$siteId'] = false;
      notifyListeners();
    }
    
    return [];
  }
  
  // Get site documents (cached)
  Future<Map<String, List<Map<String, dynamic>>>> getDocuments(String siteId, {bool forceRefresh = false}) async {
    if (_documentsCache.containsKey(siteId) && !forceRefresh) {
      return _documentsCache[siteId]!;
    }
    
    _loadingStates['docs_$siteId'] = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/sites/$siteId/documents/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _documentsCache[siteId] = {
          'PLAN': List<Map<String, dynamic>>.from(data['documents']['PLAN'] ?? []),
          'ELEVATION': List<Map<String, dynamic>>.from(data['documents']['ELEVATION'] ?? []),
          'STRUCTURE': List<Map<String, dynamic>>.from(data['documents']['STRUCTURE'] ?? []),
          'FINAL_OUTPUT': List<Map<String, dynamic>>.from(data['documents']['FINAL_OUTPUT'] ?? []),
        };
        return _documentsCache[siteId]!;
      }
    } catch (e) {
      print('Error loading documents: $e');
    } finally {
      _loadingStates['docs_$siteId'] = false;
      notifyListeners();
    }
    
    return {
      'PLAN': [],
      'ELEVATION': [],
      'STRUCTURE': [],
      'FINAL_OUTPUT': [],
    };
  }
  
  // Compare sites
  Future<Map<String, dynamic>?> compareSites(String site1Id, String site2Id) async {
    _loadingStates['comparison'] = true;
    notifyListeners();
    
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/admin/sites/compare/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({
          'site1_id': site1Id,
          'site2_id': site2Id,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error comparing sites: $e');
    } finally {
      _loadingStates['comparison'] = false;
      notifyListeners();
    }
    
    return null;
  }
  
  // Clear cache for a specific site
  void clearSiteCache(String siteId) {
    _labourDataCache.remove(siteId);
    _billsDataCache.remove(siteId);
    _profitLossCache.remove(siteId);
    _materialPurchasesCache.remove(siteId);
    _documentsCache.remove(siteId);
    notifyListeners();
  }
  
  // Clear all cache
  void clearAllCache() {
    _sites = [];
    _sitesLoaded = false;
    _labourDataCache.clear();
    _billsDataCache.clear();
    _profitLossCache.clear();
    _materialPurchasesCache.clear();
    _documentsCache.clear();
    _loadingStates.clear();
    notifyListeners();
  }
}
