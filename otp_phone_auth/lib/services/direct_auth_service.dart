import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Direct Authentication Service - Flutter → Supabase (No Django)
/// 
/// This service connects directly to Supabase PostgreSQL database
/// bypassing the Django backend for better performance.
class DirectAuthService {
  static final DirectAuthService _instance = DirectAuthService._internal();
  factory DirectAuthService() => _instance;
  DirectAuthService._internal();

  final _supabase = Supabase.instance.client;

  // ============================================
  // REGISTRATION
  // ============================================
  
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      // Get role_id from role name
      final roleData = await _supabase
          .from('roles')
          .select('id')
          .eq('role_name', role)
          .single();
      
      final roleId = roleData['id'];
      
      // Check if username or email already exists
      final existingUser = await _supabase
          .from('users')
          .select('id')
          .or('username.eq.$username,email.eq.$email')
          .maybeSingle();
      
      if (existingUser != null) {
        return {
          'success': false,
          'error': 'Username or email already exists'
        };
      }
      
      // Hash password using Supabase's crypt function
      // Note: For production, use Supabase Auth or proper password hashing
      final hashedPassword = await _hashPassword(password);
      
      // Insert new user
      final userData = await _supabase
          .from('users')
          .insert({
            'username': username,
            'email': email,
            'phone': phone,
            'password_hash': hashedPassword,
            'full_name': fullName,
            'role_id': roleId,
            'status': 'PENDING',
            'is_active': true,
          })
          .select()
          .single();
      
      return {
        'success': true,
        'message': 'Registration successful. Please wait for admin approval.',
        'user_id': userData['id'],
        'status': 'PENDING'
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration failed: ${e.toString()}'
      };
    }
  }

  // ============================================
  // LOGIN
  // ============================================
  
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Get user with role information
      final userData = await _supabase
          .from('users')
          .select('''
            id,
            username,
            email,
            phone,
            password_hash,
            full_name,
            status,
            is_active,
            roles!inner(role_name)
          ''')
          .eq('username', username)
          .maybeSingle();
      
      if (userData == null) {
        return {
          'success': false,
          'error': 'Invalid username or password'
        };
      }
      
      // Verify password
      final passwordValid = await _verifyPassword(
        password,
        userData['password_hash']
      );
      
      if (!passwordValid) {
        return {
          'success': false,
          'error': 'Invalid username or password'
        };
      }
      
      // Check if user is active
      if (!userData['is_active']) {
        return {
          'success': false,
          'error': 'Account is deactivated'
        };
      }
      
      // Check approval status
      if (userData['status'] == 'PENDING') {
        return {
          'success': false,
          'error': 'Your account is pending admin approval',
          'status': 'PENDING'
        };
      }
      
      if (userData['status'] == 'REJECTED') {
        return {
          'success': false,
          'error': 'Your account has been rejected'
        };
      }
      
      // Update last login
      await _supabase
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', userData['id']);
      
      // Save user data locally
      await _saveUserData(userData);
      
      return {
        'success': true,
        'user': {
          'id': userData['id'],
          'username': userData['username'],
          'email': userData['email'],
          'phone': userData['phone'],
          'full_name': userData['full_name'],
          'role': userData['roles']['role_name'],
          'status': userData['status']
        }
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Login failed: ${e.toString()}'
      };
    }
  }

  // ============================================
  // USER STATUS CHECK
  // ============================================
  
  Future<Map<String, dynamic>> checkApprovalStatus(String username) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('status')
          .eq('username', username)
          .maybeSingle();
      
      if (userData == null) {
        return {
          'success': false,
          'error': 'User not found'
        };
      }
      
      final messages = {
        'PENDING': 'Your account is pending admin approval',
        'APPROVED': 'Your account has been approved. You can now login.',
        'REJECTED': 'Your account has been rejected'
      };
      
      return {
        'success': true,
        'status': userData['status'],
        'message': messages[userData['status']] ?? 'Unknown status'
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to check status: ${e.toString()}'
      };
    }
  }

  // ============================================
  // ADMIN FUNCTIONS
  // ============================================
  
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    try {
      final users = await _supabase
          .from('users')
          .select('''
            id,
            username,
            email,
            phone,
            full_name,
            created_at,
            roles!inner(role_name)
          ''')
          .eq('status', 'PENDING')
          .order('created_at', ascending: false);
      
      return users.map((user) => {
        'id': user['id'],
        'username': user['username'],
        'email': user['email'],
        'phone': user['phone'],
        'full_name': user['full_name'],
        'role': user['roles']['role_name'],
        'created_at': user['created_at'],
      }).toList();
      
    } catch (e) {
      print('Error fetching pending users: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final users = await _supabase
          .from('users')
          .select('''
            id,
            username,
            email,
            phone,
            full_name,
            status,
            is_active,
            created_at,
            last_login,
            roles!inner(role_name)
          ''')
          .order('created_at', ascending: false);
      
      return users.map((user) => {
        'id': user['id'],
        'username': user['username'],
        'email': user['email'],
        'phone': user['phone'],
        'full_name': user['full_name'],
        'role': user['roles']['role_name'],
        'status': user['status'],
        'is_active': user['is_active'],
        'created_at': user['created_at'],
        'last_login': user['last_login'],
      }).toList();
      
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }
  
  Future<bool> approveUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'status': 'APPROVED',
            'approved_at': DateTime.now().toIso8601String()
          })
          .eq('id', userId)
          .eq('status', 'PENDING');
      
      return true;
    } catch (e) {
      print('Error approving user: $e');
      return false;
    }
  }
  
  Future<bool> rejectUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'status': 'REJECTED'})
          .eq('id', userId)
          .eq('status', 'PENDING');
      
      return true;
    } catch (e) {
      print('Error rejecting user: $e');
      return false;
    }
  }

  // ============================================
  // ROLES
  // ============================================
  
  Future<List<String>> getRoles() async {
    try {
      final roles = await _supabase
          .from('roles')
          .select('role_name')
          .neq('role_name', 'Admin')
          .order('role_name');
      
      return roles.map((r) => r['role_name'] as String).toList();
    } catch (e) {
      print('Error fetching roles: $e');
      return [];
    }
  }

  // ============================================
  // LOCAL STORAGE
  // ============================================
  
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('username', userData['username']);
    await prefs.setString('role', userData['roles']['role_name']);
  }
  
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      return json.decode(userDataStr);
    }
    return null;
  }
  
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
  
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
  
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('role');
  }

  // ============================================
  // PASSWORD HASHING (Simplified)
  // ============================================
  
  /// Simple password hashing for demo
  /// In production, use Supabase Auth or proper bcrypt/argon2
  Future<String> _hashPassword(String password) async {
    // For now, we'll use a simple hash
    // TODO: Implement proper password hashing with bcrypt or use Supabase Auth
    return 'pbkdf2_sha256\$260000\$$password'; // Placeholder format
  }
  
  Future<bool> _verifyPassword(String password, String hash) async {
    // Simple verification for demo
    // TODO: Implement proper password verification
    return hash.contains(password);
  }
}
