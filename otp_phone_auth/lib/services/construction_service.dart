import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ConstructionService {
  static final ConstructionService _instance = ConstructionService._internal();
  factory ConstructionService() => _instance;
  ConstructionService._internal();

  final _authService = AuthService();
  static const String baseUrl = 'http://localhost:8000/api';
  static const String mediaBaseUrl = 'http://localhost:8000'; // For media files

  // Helper method to convert relative image URLs to full URLs
  static String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    
    // If already a full URL, return as is
    if (relativeUrl.startsWith('http')) return relativeUrl;
    
    // If relative URL starts with /media/, prepend the media base URL
    if (relativeUrl.startsWith('/media/')) {
      return '$mediaBaseUrl$relativeUrl';
    }
    
    // If it doesn't start with /, add it
    if (!relativeUrl.startsWith('/')) {
      return '$mediaBaseUrl/media/$relativeUrl';
    }
    
    return '$mediaBaseUrl$relativeUrl';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ============================================
  // PROFILE UPDATE
  // ============================================

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) body['full_name'] = fullName;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile/update/'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Profile updated'};
      }
      return {'success': false, 'error': data['error'] ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // COMMON APIS
  // ============================================

  Future<List<String>> getAreas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/areas/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['areas']);
      }
      return [];
    } catch (e) {
      print('Error getting areas: $e');
      return [];
    }
  }

  Future<List<String>> getStreets(String area) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/streets/$area/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['streets']);
      }
      return [];
    } catch (e) {
      print('Error getting streets: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSites({String? area, String? street}) async {
    try {
      var url = '$baseUrl/construction/sites/';
      final params = <String>[];
      if (area != null) params.add('area=$area');
      if (street != null) params.add('street=$street');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['sites']);
      }
      return [];
    } catch (e) {
      print('Error getting sites: $e');
      return [];
    }
  }

  // ============================================
  // MATERIALS APIS
  // ============================================

  Future<List<Map<String, dynamic>>> getMaterials() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/materials/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [MATERIALS] Fetched ${(data['materials'] as List).length} materials');
        return List<Map<String, dynamic>>.from(data['materials']);
      }
      print('❌ [MATERIALS] Error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ [MATERIALS] Exception: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addMaterial(String materialName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/construction/materials/add/'),
        headers: await _getHeaders(),
        body: json.encode({'material_name': materialName}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ [MATERIALS] Added: $materialName');
        return {'success': true, 'data': data};
      }
      
      final error = json.decode(response.body);
      print('❌ [MATERIALS] Error adding: ${error['error']}');
      return {'success': false, 'error': error['error']};
    } catch (e) {
      print('❌ [MATERIALS] Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // SUPERVISOR APIS
  // ============================================

  Future<Map<String, dynamic>> submitLabourCount({
    required String siteId,
    required int labourCount,
    String? labourType,
    String? notes,
    double? extraCost,
    String? extraCostNotes,
    DateTime? customDateTime, // Add custom date/time parameter
  }) async {
    print('🔍 [SUBMIT] Submitting labour: $labourType = $labourCount');
    print('🔍 [SUBMIT] Site ID: $siteId');
    print('🔍 [SUBMIT] Custom DateTime: $customDateTime');
    try {
      final headers = await _getHeaders();
      final body = {
        'site_id': siteId,
        'labour_count': labourCount,
        'labour_type': labourType ?? 'General',
        'notes': notes ?? '',
      };
      
      // Add custom date/time if provided
      if (customDateTime != null) {
        body['custom_date'] = customDateTime.toIso8601String().split('T')[0]; // YYYY-MM-DD
        body['custom_time'] = customDateTime.toIso8601String().split('T')[1].split('.')[0]; // HH:MM:SS
        body['custom_datetime'] = customDateTime.toIso8601String(); // Full ISO string
      }
      
      // Add extra cost fields if provided
      if (extraCost != null && extraCost > 0) {
        body['extra_cost'] = extraCost;
        if (extraCostNotes != null && extraCostNotes.isNotEmpty) {
          body['extra_cost_notes'] = extraCostNotes;
        }
      }
      
      print('🔍 [SUBMIT] Request body: $body');
      
      final response = await http.post(
        Uri.parse('$baseUrl/construction/labour/'),
        headers: headers,
        body: json.encode(body),
      );

      print('📊 [SUBMIT] Response status: ${response.statusCode}');
      print('📊 [SUBMIT] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        print('✅ [SUBMIT] Labour submitted successfully!');
        return {'success': true, 'message': data['message']};
      } else {
        print('❌ [SUBMIT] Failed: ${data['error']}');
        return {'success': false, 'error': data['error'] ?? 'Failed to submit'};
      }
    } catch (e) {
      print('❌ [SUBMIT] Exception: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitMaterialBalance({
    required String siteId,
    required List<Map<String, dynamic>> materials,
    double? extraCost,
    String? extraCostNotes,
    DateTime? customDateTime, // Add custom date/time parameter
  }) async {
    try {
      final body = {
        'site_id': siteId,
        'materials': materials,
      };
      
      // Add custom date/time if provided
      if (customDateTime != null) {
        body['custom_date'] = customDateTime.toIso8601String().split('T')[0]; // YYYY-MM-DD
        body['custom_time'] = customDateTime.toIso8601String().split('T')[1].split('.')[0]; // HH:MM:SS
        body['custom_datetime'] = customDateTime.toIso8601String(); // Full ISO string
      }
      
      // Add extra cost fields if provided
      if (extraCost != null && extraCost > 0) {
        body['extra_cost'] = extraCost;
        if (extraCostNotes != null && extraCostNotes.isNotEmpty) {
          body['extra_cost_notes'] = extraCostNotes;
        }
      }
      
      print('🔍 [MATERIAL] Request body: $body');
      
      final response = await http.post(
        Uri.parse('$baseUrl/construction/material-balance/'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to submit'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadSiteImages({
    required String siteId,
    required List<String> imageUrls,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/supervisor/upload-images/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'image_urls': imageUrls,
          'description': description ?? '',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>?> getTodayEntries(String siteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/today-entries/?site_id=$siteId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting today entries: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEntriesByDate(String siteId, DateTime date) async {
    try {
      // Format date as YYYY-MM-DD
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/entries-by-date/?site_id=$siteId&date=$dateStr'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'labour_entries': [], 'material_entries': []};
    } catch (e) {
      print('Error getting entries by date: $e');
      return {'labour_entries': [], 'material_entries': []};
    }
  }

  // ============================================
  // SITE ENGINEER APIS
  // ============================================

  Future<Map<String, dynamic>> uploadWorkStarted({
    required String siteId,
    required String imageUrl,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/engineer/work-started/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'image_url': imageUrl,
          'description': description ?? '',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadWorkFinished({
    required String siteId,
    required List<String> imageUrls,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/engineer/work-finished/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'image_urls': imageUrls,
          'description': description ?? '',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getMyComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/engineer/complaints/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['complaints']);
      }
      return [];
    } catch (e) {
      print('Error getting complaints: $e');
      return [];
    }
  }

  // ============================================
  // ACCOUNTANT APIS
  // ============================================

  Future<List<Map<String, dynamic>>> getLabourEntriesForVerification(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accountant/labour-entries/?date=$date'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['entries']);
      }
      return [];
    } catch (e) {
      print('Error getting labour entries: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> modifyLabourCount({
    required String entryId,
    required int labourCount,
    required String reason,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/accountant/modify-labour/$entryId/'),
        headers: await _getHeaders(),
        body: json.encode({
          'labour_count': labourCount,
          'reason': reason,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to modify'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadMaterialBill({
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
      final response = await http.post(
        Uri.parse('$baseUrl/accountant/upload-bill/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'material_type': materialType,
          'quantity': quantity,
          'total_amount': totalAmount,
          'unit': unit,
          'price_per_unit': pricePerUnit,
          'bill_number': billNumber,
          'bill_url': billUrl,
          'vendor_name': vendorName,
          'bill_date': billDate,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadExtraWork({
    required String siteId,
    required String description,
    required double amount,
    String? billUrl,
    String? dueDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accountant/extra-work/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'description': description,
          'amount': amount,
          'bill_url': billUrl,
          'due_date': dueDate,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // ============================================
  // HISTORY APIS
  // ============================================

  Future<Map<String, dynamic>> getSupervisorHistory({String? siteId}) async {
    print('🔍 [HISTORY] Calling supervisor history API... (siteId: $siteId)');
    try {
      final headers = await _getHeaders();
      print('🔍 [HISTORY] Headers: ${headers.keys}');
      
      // Build URL with optional site filter
      String url = '$baseUrl/construction/supervisor/history/';
      if (siteId != null && siteId.isNotEmpty) {
        url += '?site_id=$siteId';
      }
      
      print('🔍 [HISTORY] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 [HISTORY] Response status: ${response.statusCode}');
      print('📊 [HISTORY] Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final labourCount = (data['labour_entries'] as List?)?.length ?? 0;
        final materialCount = (data['material_entries'] as List?)?.length ?? 0;
        print('✅ [HISTORY] Labour entries: $labourCount');
        print('✅ [HISTORY] Material entries: $materialCount');
        print('🏗️ [HISTORY] Site filter: ${data['site_filter'] ?? 'None'}');
        
        if (labourCount > 0) {
          print('📝 [HISTORY] First labour entry: ${data['labour_entries'][0]}');
          
          // Debug: Check for Jan 26 entries specifically
          final jan26Labour = (data['labour_entries'] as List).where((entry) => 
            entry['entry_date']?.toString().contains('2026-01-26') == true).toList();
          print('📅 [HISTORY] Jan 26 labour entries found: ${jan26Labour.length}');
          
          if (jan26Labour.isNotEmpty) {
            print('📝 [HISTORY] Jan 26 labour sample: ${jan26Labour[0]}');
          }
        }
        
        if (materialCount > 0) {
          print('📦 [HISTORY] First material entry: ${data['material_entries'][0]}');
          
          // Debug: Check for Jan 26 entries specifically
          final jan26Material = (data['material_entries'] as List).where((entry) => 
            entry['entry_date']?.toString().contains('2026-01-26') == true).toList();
          print('📅 [HISTORY] Jan 26 material entries found: ${jan26Material.length}');
          
          if (jan26Material.isNotEmpty) {
            print('📦 [HISTORY] Jan 26 material sample: ${jan26Material[0]}');
          }
        }
        
        return data;
      } else {
        print('❌ [HISTORY] Error response: ${response.body}');
      }
      return {'labour_entries': [], 'material_entries': []};
    } catch (e) {
      print('❌ [HISTORY] Exception: $e');
      return {'labour_entries': [], 'material_entries': []};
    }
  }

  Future<Map<String, dynamic>> getTodayEntriesForSupervisor({String? siteId}) async {
    print('🔍 [TODAY] Calling aggregated today entries API...');
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/construction/aggregated-today-entries/';
      
      if (siteId != null) {
        url += '?site_id=$siteId';
      }
      
      print('🔍 [TODAY] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 [TODAY] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [TODAY] Data received: ${data.keys}');
        if (data['entries'] != null) {
          print('✅ [TODAY] Entries count: ${(data['entries'] as List).length}');
          if ((data['entries'] as List).isNotEmpty) {
            print('✅ [TODAY] First entry: ${data['entries'][0]}');
          }
        }
        return data;
      } else {
        print('❌ [TODAY] Error response: ${response.body}');
        throw Exception('Failed to load today\'s entries: ${response.body}');
      }
    } catch (e) {
      print('❌ [TODAY] Exception: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getHistoryByDay({required String siteId}) async {
    print('🔍 [HISTORY_BY_DAY] Calling history-by-day API for site: $siteId');
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/construction/history-by-day/?site_id=$siteId';
      
      print('🔍 [HISTORY_BY_DAY] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 [HISTORY_BY_DAY] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [HISTORY_BY_DAY] Data received successfully');
        return {'success': true, 'data': data};
      } else {
        print('❌ [HISTORY_BY_DAY] Error response: ${response.body}');
        return {'success': false, 'error': 'Failed to load history'};
      }
    } catch (e) {
      print('❌ [HISTORY_BY_DAY] Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAccountantEntries() async {
    print('🔍 [ACCOUNTANT] Calling accountant entries API...');
    try {
      final headers = await _getHeaders();
      print('🔍 [ACCOUNTANT] URL: $baseUrl/construction/accountant/all-entries/');
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/accountant/all-entries/'),
        headers: headers,
      );

      print('📊 [ACCOUNTANT] Response status: ${response.statusCode}');
      print('📊 [ACCOUNTANT] Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final labourCount = (data['labour_entries'] as List?)?.length ?? 0;
        final materialCount = (data['material_entries'] as List?)?.length ?? 0;
        print('✅ [ACCOUNTANT] Labour entries: $labourCount');
        print('✅ [ACCOUNTANT] Material entries: $materialCount');
        
        if (labourCount > 0) {
          print('📝 [ACCOUNTANT] First labour entry: ${data['labour_entries'][0]}');
        }
        
        return data;
      } else {
        print('❌ [ACCOUNTANT] Error response: ${response.body}');
      }
      return {'labour_entries': [], 'material_entries': []};
    } catch (e) {
      print('❌ [ACCOUNTANT] Exception: $e');
      return {'labour_entries': [], 'material_entries': []};
    }
  }

  Future<Map<String, dynamic>> getAccountantPhotos({
    String? siteId,
    String? updateType,
    String? dateFrom,
    String? dateTo,
  }) async {
    print('🔍 [ACCOUNTANT PHOTOS] Calling accountant photos API...');
    try {
      final headers = await _getHeaders();
      
      // Build URL with optional filters
      String url = '$baseUrl/construction/accountant/all-photos/';
      List<String> queryParams = [];
      
      if (siteId != null && siteId.isNotEmpty) {
        queryParams.add('site_id=$siteId');
      }
      if (updateType != null && updateType.isNotEmpty) {
        queryParams.add('update_type=$updateType');
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams.add('date_from=$dateFrom');
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams.add('date_to=$dateTo');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      print('🔍 [ACCOUNTANT PHOTOS] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 [ACCOUNTANT PHOTOS] Response status: ${response.statusCode}');
      print('📊 [ACCOUNTANT PHOTOS] Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photosCount = (data['photos'] as List?)?.length ?? 0;
        print('✅ [ACCOUNTANT PHOTOS] Photos found: $photosCount');
        
        if (photosCount > 0) {
          print('📸 [ACCOUNTANT PHOTOS] First photo: ${data['photos'][0]['full_site_name']} - ${data['photos'][0]['update_type']}');
        }
        
        return data;
      } else {
        print('❌ [ACCOUNTANT PHOTOS] Error response: ${response.body}');
      }
      return {'photos': [], 'total_photos': 0};
    } catch (e) {
      print('❌ [ACCOUNTANT PHOTOS] Exception: $e');
      return {'photos': [], 'total_photos': 0};
    }
  }

  // ============================================
  // ARCHITECT APIS
  // ============================================

  Future<Map<String, dynamic>> uploadArchitectDocument({
    required String siteId,
    required String documentType,
    required String title,
    String? description,
    required String filePath,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Let http handle multipart content type
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/construction/upload-architect-document/'),
      );
      
      request.headers.addAll(headers);
      request.fields['site_id'] = siteId;
      request.fields['document_type'] = documentType;
      request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message'], 'document_id': data['document_id']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload document'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadArchitectComplaint({
    required String siteId,
    required String title,
    required String description,
    String priority = 'MEDIUM',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/construction/upload-architect-complaint/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'title': title,
          'description': description,
          'priority': priority,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message'], 'complaint_id': data['complaint_id']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to submit complaint'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getArchitectDocuments({
    String? siteId,
    String? documentType,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      // Build URL with optional filters
      String url = '$baseUrl/construction/architect-documents/';
      List<String> queryParams = [];
      
      if (siteId != null && siteId.isNotEmpty) {
        queryParams.add('site_id=$siteId');
      }
      if (documentType != null && documentType.isNotEmpty) {
        queryParams.add('document_type=$documentType');
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams.add('date_from=$dateFrom');
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams.add('date_to=$dateTo');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'documents': data['documents'],
          'total_documents': data['total_documents'],
        };
      } else {
        return {'success': false, 'error': 'Failed to load documents'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getArchitectComplaints({
    String? siteId,
    String? status,
    String? priority,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      // Build URL with optional filters
      String url = '$baseUrl/construction/architect-complaints/';
      List<String> queryParams = [];
      
      if (siteId != null && siteId.isNotEmpty) {
        queryParams.add('site_id=$siteId');
      }
      if (status != null && status.isNotEmpty) {
        queryParams.add('status=$status');
      }
      if (priority != null && priority.isNotEmpty) {
        queryParams.add('priority=$priority');
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams.add('date_from=$dateFrom');
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams.add('date_to=$dateTo');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'complaints': data['complaints'],
          'total_complaints': data['total_complaints'],
        };
      } else {
        return {'success': false, 'error': 'Failed to load complaints'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getArchitectHistory({String? siteId}) async {
    print('🔍 [ARCHITECT HISTORY] Calling architect history API... (siteId: $siteId)');
    try {
      final headers = await _getHeaders();
      
      // Build URL with optional site filter
      String url = '$baseUrl/construction/architect-history/';
      if (siteId != null && siteId.isNotEmpty) {
        url += '?site_id=$siteId';
      }
      
      print('🔍 [ARCHITECT HISTORY] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 [ARCHITECT HISTORY] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documentsCount = (data['documents'] as List?)?.length ?? 0;
        final complaintsCount = (data['complaints'] as List?)?.length ?? 0;
        print('✅ [ARCHITECT HISTORY] Documents: $documentsCount');
        print('✅ [ARCHITECT HISTORY] Complaints: $complaintsCount');
        
        return data;
      } else {
        print('❌ [ARCHITECT HISTORY] Error response: ${response.body}');
      }
      return {'documents': [], 'complaints': []};
    } catch (e) {
      print('❌ [ARCHITECT HISTORY] Exception: $e');
      return {'documents': [], 'complaints': []};
    }
  }

  // ============================================
  // CHANGE REQUEST SYSTEM
  // ============================================

  Future<Map<String, dynamic>> requestChange({
    required String entryId,
    required String entryType,
    required String requestMessage,
    Map<String, dynamic>? proposedChanges,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'entry_id': entryId,
        'entry_type': entryType,
        'request_message': requestMessage,
      };
      
      // Add proposed changes if provided
      if (proposedChanges != null && proposedChanges.isNotEmpty) {
        requestBody['proposed_changes'] = proposedChanges;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/construction/request-change/'),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'request_id': data['request_id']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to request change'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyChangeRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/my-change-requests/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'change_requests': data['change_requests'],
        };
      } else {
        return {'success': false, 'error': 'Failed to load change requests'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPendingChangeRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/pending-change-requests/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'change_requests': data['change_requests'],
        };
      } else {
        return {'success': false, 'error': 'Failed to load pending requests'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> handleChangeRequest({
    required String requestId,
    required dynamic newValue,
    String? responseMessage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/construction/handle-change-request/$requestId/'),
        headers: await _getHeaders(),
        body: json.encode({
          'new_value': newValue,
          'response_message': responseMessage ?? '',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to handle request'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getModifiedEntries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/modified-entries/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'labour_entries': data['labour_entries'],
          'material_entries': data['material_entries'],
        };
      } else {
        return {'success': false, 'error': 'Failed to load modified entries'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // ============================================
  // SUPERVISOR: UPLOAD PHOTOS
  // ============================================
  
  Future<Map<String, dynamic>> uploadSupervisorPhotos({
    required String siteId,
    required List<dynamic> photos, // List of XFile
    required String timeOfDay, // 'morning' or 'evening'
  }) async {
    try {
      final token = await _authService.getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/construction/supervisor-upload-photos/'),
      );
      
      // Add headers
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';
      
      // Add fields
      request.fields['site_id'] = siteId;
      request.fields['time_of_day'] = timeOfDay;
      
      // Add photos
      for (var photo in photos) {
        final file = await http.MultipartFile.fromPath(
          'photos',
          photo.path,
        );
        request.files.add(file);
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Photos uploaded successfully',
          'photo_count': data['photo_count'] ?? photos.length,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Failed to upload photos',
        };
      }
    } catch (e) {
      print('Error uploading photos: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================
  // GET SUPERVISOR UPLOADED PHOTOS
  // ============================================
  
  Future<Map<String, dynamic>> getSupervisorUploadedPhotos({
    required String siteId,
  }) async {
    try {
      final token = await _authService.getToken();
      
      print('🖼️ [PHOTOS] Fetching uploaded photos for site: $siteId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/supervisor-photos/?site_id=$siteId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      print('🖼️ [PHOTOS] Response status: ${response.statusCode}');
      print('🖼️ [PHOTOS] Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final photos = List<Map<String, dynamic>>.from(data['photos'] ?? []);
        print('🖼️ [PHOTOS] Loaded ${photos.length} photos');
        return {
          'success': true,
          'photos': photos,
        };
      } else {
        print('🖼️ [PHOTOS] Error: ${data['error']}');
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to load photos',
        };
      }
    } catch (e) {
      print('🖼️ [PHOTOS] Exception: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================
  // WORKING SITES (Accountant assigns to Supervisor)
  // ============================================
  
  Future<Map<String, dynamic>> getAllSites() async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/all-sites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'sites': List<Map<String, dynamic>>.from(data['sites'] ?? []),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to load sites',
        };
      }
    } catch (e) {
      print('Error loading sites: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> getSupervisorsList() async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/supervisors-list/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'supervisors': List<Map<String, dynamic>>.from(data['supervisors'] ?? []),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to load supervisors',
        };
      }
    } catch (e) {
      print('Error loading supervisors: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> assignWorkingSites({
    required List<Map<String, dynamic>> sites,
  }) async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/construction/assign-working-sites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({
          'sites': sites,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'assigned_count': data['assigned_count'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to assign sites',
        };
      }
    } catch (e) {
      print('Error assigning sites: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getWorkingSites() async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/working-sites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'sites': List<Map<String, dynamic>>.from(data['sites'] ?? []),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to load working sites',
        };
      }
    } catch (e) {
      print('Error loading working sites: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getTodaySitesWithEntries() async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/today-sites-with-data/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'sites': List<Map<String, dynamic>>.from(data['sites'] ?? []),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to load today sites with data',
        };
      }
    } catch (e) {
      print('Error loading today sites with data: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getTotalCounts() async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/construction/total-counts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'total_areas': data['total_areas'] ?? 0,
          'total_streets': data['total_streets'] ?? 0,
          'total_sites': data['total_sites'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to load total counts',
        };
      }
    } catch (e) {
      print('Error loading total counts: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Add client requirement
  Future<bool> addClientRequirement(String siteId, String description, double amount) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/accountant/add-client-requirement/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'site_id': siteId,
          'description': description,
          'amount': amount,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to add client requirement: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error adding client requirement: $e');
      return false;
    }
  }

  // ============================================
  // CLIENT APIS
  // ============================================

  Future<Map<String, dynamic>> getClientSiteDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/site-details/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [CLIENT] Site details loaded');
        return data;
      }
      
      print('❌ [CLIENT] Error: ${response.statusCode}');
      return {'sites': []};
    } catch (e) {
      print('❌ [CLIENT] Exception: $e');
      return {'sites': []};
    }
  }

  Future<Map<String, dynamic>> getClientMaterials(String siteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/materials/?site_id=$siteId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [CLIENT] Materials loaded: ${data['count']} items');
        return data;
      }
      
      print('❌ [CLIENT MATERIALS] Error: ${response.statusCode}');
      return {'materials': []};
    } catch (e) {
      print('❌ [CLIENT MATERIALS] Exception: $e');
      return {'materials': []};
    }
  }

  Future<Map<String, dynamic>> getClientPhotosByDate({
    required String siteId,
    String? filterDate,
  }) async {
    try {
      String url = '$baseUrl/client/photos-by-date/?site_id=$siteId';
      if (filterDate != null && filterDate.isNotEmpty) {
        url += '&date=$filterDate';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [CLIENT PHOTOS] Loaded: ${data['total_photos']} photos');
        print('   Supervisor: ${data['supervisor_photos']}, Engineer: ${data['engineer_photos']}');
        if (filterDate != null) {
          print('   Filtered by date: $filterDate');
        }
        return data;
      }
      
      print('❌ [CLIENT PHOTOS] Error: ${response.statusCode}');
      return {'photos_by_date': {}, 'dates': [], 'total_photos': 0};
    } catch (e) {
      print('❌ [CLIENT PHOTOS] Exception: $e');
      return {'photos_by_date': {}, 'dates': [], 'total_photos': 0};
    }
  }

  Future<Map<String, dynamic>?> getClientBudgetAllocation(String siteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/budget/allocation/$siteId/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [CLIENT BUDGET] Budget allocation loaded for site: $siteId');
        return data;
      } else if (response.statusCode == 404) {
        print('ℹ️ [CLIENT BUDGET] No budget allocation found for site: $siteId');
        return null;
      }
      
      print('❌ [CLIENT BUDGET] Error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ [CLIENT BUDGET] Exception: $e');
      return null;
    }
  }

  // ============================================
  // CLIENT COMPLAINTS APIs
  // ============================================

  Future<Map<String, dynamic>> getClientComplaints({String? siteId}) async {
    try {
      String url = '$baseUrl/client/complaints/';
      if (siteId != null && siteId.isNotEmpty) {
        url += '?site_id=$siteId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [CLIENT] Complaints loaded: ${data['total_count']} items');
        return data;
      }
      
      print('❌ [CLIENT COMPLAINTS] Error: ${response.statusCode}');
      return {'complaints': [], 'total_count': 0};
    } catch (e) {
      print('❌ [CLIENT COMPLAINTS] Exception: $e');
      return {'complaints': [], 'total_count': 0};
    }
  }

  Future<Map<String, dynamic>> createClientComplaint({
    required String siteId,
    required String title,
    String? description,
    String priority = 'MEDIUM',
    String? proofImageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/client/complaints/create/'),
        headers: await _getHeaders(),
        body: json.encode({
          'site_id': siteId,
          'title': title,
          'description': description ?? '',
          'priority': priority,
          'proof_image_url': proofImageUrl ?? '',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ [CLIENT] Complaint created: ${data['complaint']['id']}');
        return data;
      }
      
      print('❌ [CLIENT CREATE COMPLAINT] Error: ${response.statusCode}');
      print('Response: ${response.body}');
      return {
        'success': false,
        'error': 'Failed to create complaint'
      };
    } catch (e) {
      print('❌ [CLIENT CREATE COMPLAINT] Exception: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> getComplaintMessages(String complaintId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/complaints/$complaintId/messages/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [CLIENT] Messages loaded: ${data['total_count']} items');
        return data;
      }
      
      print('❌ [CLIENT MESSAGES] Error: ${response.statusCode}');
      return {'messages': [], 'total_count': 0};
    } catch (e) {
      print('❌ [CLIENT MESSAGES] Exception: $e');
      return {'messages': [], 'total_count': 0};
    }
  }

  Future<Map<String, dynamic>> sendComplaintMessage({
    required String complaintId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/client/complaints/$complaintId/messages/send/'),
        headers: await _getHeaders(),
        body: json.encode({
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ [CLIENT] Message sent');
        return data;
      }
      
      print('❌ [CLIENT SEND MESSAGE] Error: ${response.statusCode}');
      return {
        'success': false,
        'error': 'Failed to send message'
      };
    } catch (e) {
      print('❌ [CLIENT SEND MESSAGE] Exception: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ============================================
  // ARCHITECT CLIENT COMPLAINTS APIs
  // ============================================

  Future<Map<String, dynamic>> getClientComplaintsForArchitect({
    String? siteId,
    String? status,
  }) async {
    try {
      String url = '$baseUrl/construction/client-complaints/';
      List<String> params = [];
      
      if (siteId != null && siteId.isNotEmpty) {
        params.add('site_id=$siteId');
      }
      if (status != null && status.isNotEmpty) {
        params.add('status=$status');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [ARCHITECT] Client complaints loaded: ${data['total_count']} items');
        return data;
      }
      
      print('❌ [ARCHITECT CLIENT COMPLAINTS] Error: ${response.statusCode}');
      return {'complaints': [], 'total_count': 0};
    } catch (e) {
      print('❌ [ARCHITECT CLIENT COMPLAINTS] Exception: $e');
      return {'complaints': [], 'total_count': 0};
    }
  }

  Future<Map<String, dynamic>> getComplaintMessagesArchitect(String complaintId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/construction/complaints/$complaintId/messages/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [ARCHITECT] Messages loaded: ${data['total_count']} items');
        return data;
      }
      
      print('❌ [ARCHITECT MESSAGES] Error: ${response.statusCode}');
      return {'messages': [], 'total_count': 0};
    } catch (e) {
      print('❌ [ARCHITECT MESSAGES] Exception: $e');
      return {'messages': [], 'total_count': 0};
    }
  }

  Future<Map<String, dynamic>> sendComplaintMessageArchitect({
    required String complaintId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/construction/complaints/$complaintId/messages/send/'),
        headers: await _getHeaders(),
        body: json.encode({
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ [ARCHITECT] Message sent');
        return data;
      }
      
      print('❌ [ARCHITECT SEND MESSAGE] Error: ${response.statusCode}');
      return {
        'success': false,
        'error': 'Failed to send message'
      };
    } catch (e) {
      print('❌ [ARCHITECT SEND MESSAGE] Exception: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
}
