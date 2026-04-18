import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class BudgetManagementService {
  static final BudgetManagementService _instance = BudgetManagementService._internal();
  factory BudgetManagementService() => _instance;
  BudgetManagementService._internal();

  final _authService = AuthService();
  static const String baseUrl = 'https://new-essentials.onrender.com/api';

  // Cache for global labour rates — loaded once, cleared when admin updates a rate
  static List<Map<String, dynamic>>? _globalRatesCache;

  /// Allocate budget for a site
  Future<Map<String, dynamic>?> allocateBudget({
    required String siteId,
    required double totalBudget,
    double? materialBudget,
    double? labourBudget,
    double? otherBudget,
    String? notes,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/budget/allocate/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'site_id': siteId,
          'total_budget': totalBudget,
          if (materialBudget != null) 'material_budget': materialBudget,
          if (labourBudget != null) 'labour_budget': labourBudget,
          if (otherBudget != null) 'other_budget': otherBudget,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get budget allocation for a site
  Future<Map<String, dynamic>?> getBudgetAllocation(String siteId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/budget/allocation/$siteId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['budget'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Set labour rate for a site
  Future<Map<String, dynamic>?> setLabourRate({
    required String siteId,
    required String labourType,
    required double dailyRate,
    String? effectiveFrom,
    String? notes,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/budget/labour-rate/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'site_id': siteId,
          'labour_type': labourType,
          'daily_rate': dailyRate,
          if (effectiveFrom != null) 'effective_from': effectiveFrom,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        clearRatesCache(); // Force fresh fetch next time rates are needed
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get labour rates. For 'global', returns cached result after first load.
  Future<List<Map<String, dynamic>>> getLabourRates(String siteId) async {
    // Return cache for global rates — avoids repeated API calls on every sheet open
    if (siteId == 'global' && _globalRatesCache != null) {
      return _globalRatesCache!;
    }
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/budget/labour-rates/$siteId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = List<Map<String, dynamic>>.from(data['rates'] ?? []);
        if (siteId == 'global') _globalRatesCache = rates;
        return rates;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Clears the global rates cache — call after admin updates a rate
  static void clearRatesCache() => _globalRatesCache = null;

  /// Get budget utilization for a site
  Future<Map<String, dynamic>?> getBudgetUtilization(String siteId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/budget/utilization/$siteId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get labour cost details for a site
  Future<List<Map<String, dynamic>>> getLabourCostDetails(String siteId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/budget/labour-costs/$siteId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['costs'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get client requirements for a site
  Future<List<Map<String, dynamic>>> getClientRequirements(String siteId) async {
    try {
      print('🔍 Fetching client requirements for site: $siteId');
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ No auth token available');
        return [];
      }

      final url = '$baseUrl/admin/client-requirements/?site_id=$siteId';
      print('🌐 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final requirements = List<Map<String, dynamic>>.from(data['requirements'] ?? []);
        print('✅ Found ${requirements.length} requirements');
        return requirements;
      }
      print('❌ Failed with status: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching client requirements: $e');
      return [];
    }
  }
}
