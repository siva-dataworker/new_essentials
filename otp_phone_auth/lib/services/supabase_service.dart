import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Phone Authentication
  Future<void> signInWithOTP(String phoneNumber) async {
    await client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  Future<AuthResponse> verifyOTP({
    required String phoneNumber,
    required String token,
  }) async {
    return await client.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );
  }

  // User Management
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String phoneNumber,
    required String role,
    String? email,
    String? userUid,
    String? siteId,
  }) async {
    // Map role string to role_id
    final roleMap = {
      'admin': 1,
      'supervisor': 2,
      'site_engineer': 3,
      'accountant': 4,
    };
    
    final roleId = roleMap[role.toLowerCase()] ?? 2; // Default to supervisor
    
    final data = {
      'full_name': name,
      'email': email ?? '',
      'phone': phoneNumber,
      'role_id': roleId,
      'is_active': true,
    };
    
    // Add user_uid if provided (Firebase UID)
    if (userUid != null && userUid.isNotEmpty) {
      data['user_uid'] = userUid;
    }
    
    await client.from('users').insert(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    // Since user_id is auto-increment, we need to search by email or phone
    // For Google Sign-In, we'll use email
    final response = await client
        .from('users')
        .select()
        .eq('email', userId) // Assuming userId is actually the email for Google Sign-In
        .maybeSingle();
    return response;
  }
  
  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    final response = await client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();
    return response;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    // Update by email since we don't have the auto-increment user_id
    await client.from('users').update(data).eq('email', userId);
  }

  // Sites
  Future<List<Map<String, dynamic>>> getSites() async {
    final response = await client.from('sites').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getSite(String siteId) async {
    final response = await client
        .from('sites')
        .select()
        .eq('id', siteId)
        .maybeSingle();
    return response;
  }

  // Daily Entries
  Future<void> createDailyEntry(Map<String, dynamic> entry) async {
    await client.from('daily_entries').insert(entry);
  }

  Future<List<Map<String, dynamic>>> getDailyEntries({
    String? siteId,
    DateTime? date,
  }) async {
    var query = client.from('daily_entries').select();
    
    if (siteId != null) {
      query = query.eq('site_id', siteId);
    }
    
    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      query = query.eq('date', dateStr);
    }
    
    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Material Balance
  Future<void> createMaterialEntry(Map<String, dynamic> entry) async {
    await client.from('material_entries').insert(entry);
  }

  Future<List<Map<String, dynamic>>> getMaterialEntries(String siteId) async {
    final response = await client
        .from('material_entries')
        .select()
        .eq('site_id', siteId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Labor Count
  Future<void> createLaborEntry(Map<String, dynamic> entry) async {
    await client.from('labor_entries').insert(entry);
  }

  Future<List<Map<String, dynamic>>> getLaborEntries(String siteId) async {
    final response = await client
        .from('labor_entries')
        .select()
        .eq('site_id', siteId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Photo Upload
  Future<String> uploadPhoto({
    required String bucket,
    required String path,
    required List<int> fileBytes,
  }) async {
    final bytes = Uint8List.fromList(fileBytes);
    await client.storage.from(bucket).uploadBinary(path, bytes);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  Future<List<Map<String, dynamic>>> getPhotos(String siteId) async {
    final response = await client
        .from('photos')
        .select()
        .eq('site_id', siteId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Auth State
  User? get currentUser => client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
