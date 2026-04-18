import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persistent caching across app restarts
class CacheService {
  static const String _notificationsKey = 'admin_notifications_cache';
  static const String _notificationsTimestampKey = 'admin_notifications_timestamp';
  static const String _sitesKey = 'admin_sites_cache';
  static const String _sitesTimestampKey = 'admin_sites_timestamp';
  static const String _complaintsKey = 'admin_complaints_cache';
  static const String _complaintsTimestampKey = 'admin_complaints_timestamp';
  static const String _budgetAllocationKey = 'admin_budget_allocation_';
  static const String _budgetUtilizationKey = 'admin_budget_utilization_';
  static const String _budgetTimestampKey = 'admin_budget_timestamp_';
  static const String _pendingUsersKey = 'admin_pending_users_cache';
  static const String _pendingUsersTimestampKey = 'admin_pending_users_timestamp';
  static const String _allUsersKey = 'admin_all_users_cache';
  static const String _allUsersTimestampKey = 'admin_all_users_timestamp';
  
  // Cache expiry time (24 hours)
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  /// Save notifications to cache
  static Future<void> saveNotifications(List<Map<String, dynamic>> notifications, int unreadCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'notifications': notifications,
        'unread_count': unreadCount,
      };
      await prefs.setString(_notificationsKey, json.encode(data));
      await prefs.setInt(_notificationsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving notifications cache: $e');
    }
  }
  
  /// Load notifications from cache
  static Future<Map<String, dynamic>?> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_notificationsTimestampKey);
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          // Cache expired, clear it
          await clearNotifications();
          return null;
        }
      }
      
      final cached = prefs.getString(_notificationsKey);
      if (cached != null) {
        final data = json.decode(cached);
        return {
          'notifications': List<Map<String, dynamic>>.from(data['notifications'] ?? []),
          'unread_count': data['unread_count'] ?? 0,
        };
      }
    } catch (e) {
      print('Error loading notifications cache: $e');
    }
    return null;
  }
  
  /// Clear notifications cache
  static Future<void> clearNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await prefs.remove(_notificationsTimestampKey);
    } catch (e) {
      print('Error clearing notifications cache: $e');
    }
  }
  
  /// Save sites data to cache
  static Future<void> saveSites(List<Map<String, dynamic>> sites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sitesKey, json.encode(sites));
      await prefs.setInt(_sitesTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving sites cache: $e');
    }
  }
  
  /// Load sites from cache
  static Future<List<Map<String, dynamic>>?> loadSites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_sitesTimestampKey);
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearSites();
          return null;
        }
      }
      
      final cached = prefs.getString(_sitesKey);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading sites cache: $e');
    }
    return null;
  }
  
  /// Clear sites cache
  static Future<void> clearSites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sitesKey);
      await prefs.remove(_sitesTimestampKey);
    } catch (e) {
      print('Error clearing sites cache: $e');
    }
  }
  
  /// Save complaints to cache
  static Future<void> saveComplaints(List<dynamic> complaints, String? status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_complaintsKey${status ?? 'all'}';
      await prefs.setString(key, json.encode(complaints));
      await prefs.setInt(_complaintsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving complaints cache: $e');
    }
  }
  
  /// Load complaints from cache
  static Future<List<dynamic>?> loadComplaints(String? status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_complaintsTimestampKey);
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearComplaints();
          return null;
        }
      }
      
      final key = '$_complaintsKey${status ?? 'all'}';
      final cached = prefs.getString(key);
      if (cached != null) {
        return json.decode(cached) as List<dynamic>;
      }
    } catch (e) {
      print('Error loading complaints cache: $e');
    }
    return null;
  }
  
  /// Clear complaints cache
  static Future<void> clearComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_complaintsKey));
      for (final key in keys) {
        await prefs.remove(key);
      }
      await prefs.remove(_complaintsTimestampKey);
    } catch (e) {
      print('Error clearing complaints cache: $e');
    }
  }
  
  /// Save budget allocation to cache
  static Future<void> saveBudgetAllocation(String siteId, Map<String, dynamic> budget) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_budgetAllocationKey$siteId', json.encode(budget));
      await prefs.setInt('$_budgetTimestampKey$siteId', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving budget allocation cache: $e');
    }
  }
  
  /// Load budget allocation from cache
  static Future<Map<String, dynamic>?> loadBudgetAllocation(String siteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('$_budgetTimestampKey$siteId');
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearBudgetAllocation(siteId);
          return null;
        }
      }
      
      final cached = prefs.getString('$_budgetAllocationKey$siteId');
      if (cached != null) {
        return json.decode(cached) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading budget allocation cache: $e');
    }
    return null;
  }
  
  /// Clear budget allocation cache
  static Future<void> clearBudgetAllocation(String siteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_budgetAllocationKey$siteId');
      await prefs.remove('$_budgetTimestampKey$siteId');
    } catch (e) {
      print('Error clearing budget allocation cache: $e');
    }
  }
  
  /// Save budget utilization to cache
  static Future<void> saveBudgetUtilization(String siteId, Map<String, dynamic> utilization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_budgetUtilizationKey$siteId', json.encode(utilization));
    } catch (e) {
      print('Error saving budget utilization cache: $e');
    }
  }
  
  /// Load budget utilization from cache
  static Future<Map<String, dynamic>?> loadBudgetUtilization(String siteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('$_budgetTimestampKey$siteId');
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearBudgetUtilization(siteId);
          return null;
        }
      }
      
      final cached = prefs.getString('$_budgetUtilizationKey$siteId');
      if (cached != null) {
        return json.decode(cached) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading budget utilization cache: $e');
    }
    return null;
  }
  
  /// Clear budget utilization cache
  static Future<void> clearBudgetUtilization(String siteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_budgetUtilizationKey$siteId');
    } catch (e) {
      print('Error clearing budget utilization cache: $e');
    }
  }
  
  /// Clear all admin caches
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('admin_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }
  
  /// Save pending users to cache
  static Future<void> savePendingUsers(List<Map<String, dynamic>> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingUsersKey, json.encode(users));
      await prefs.setInt(_pendingUsersTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving pending users cache: $e');
    }
  }
  
  /// Load pending users from cache
  static Future<List<Map<String, dynamic>>?> loadPendingUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_pendingUsersTimestampKey);
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearPendingUsers();
          return null;
        }
      }
      
      final cached = prefs.getString(_pendingUsersKey);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading pending users cache: $e');
    }
    return null;
  }
  
  /// Clear pending users cache
  static Future<void> clearPendingUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingUsersKey);
      await prefs.remove(_pendingUsersTimestampKey);
    } catch (e) {
      print('Error clearing pending users cache: $e');
    }
  }
  
  /// Save all users to cache
  static Future<void> saveAllUsers(List<Map<String, dynamic>> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_allUsersKey, json.encode(users));
      await prefs.setInt(_allUsersTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving all users cache: $e');
    }
  }
  
  /// Load all users from cache
  static Future<List<Map<String, dynamic>>?> loadAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_allUsersTimestampKey);
      
      // Check if cache is expired
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearAllUsers();
          return null;
        }
      }
      
      final cached = prefs.getString(_allUsersKey);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading all users cache: $e');
    }
    return null;
  }
  
  /// Clear all users cache
  static Future<void> clearAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_allUsersKey);
      await prefs.remove(_allUsersTimestampKey);
    } catch (e) {
      print('Error clearing all users cache: $e');
    }
  }
  
  // ============================================
  // ACCOUNTANT CACHE METHODS
  // ============================================
  
  static const String _accountantLabourKey = 'accountant_labour_cache';
  static const String _accountantLabourTimestampKey = 'accountant_labour_timestamp';
  static const String _accountantMaterialKey = 'accountant_material_cache';
  static const String _accountantMaterialTimestampKey = 'accountant_material_timestamp';
  static const String _accountantDashboardKey = 'accountant_dashboard_cache';
  static const String _accountantDashboardTimestampKey = 'accountant_dashboard_timestamp';
  static const String _accountantReportsKey = 'accountant_reports_cache';
  static const String _accountantReportsTimestampKey = 'accountant_reports_timestamp';
  
  /// Save accountant labour entries to cache
  static Future<void> saveAccountantLabour(List<Map<String, dynamic>> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountantLabourKey, json.encode(entries));
      await prefs.setInt(_accountantLabourTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving accountant labour cache: $e');
    }
  }
  
  /// Load accountant labour entries from cache
  static Future<List<Map<String, dynamic>>?> loadAccountantLabour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_accountantLabourTimestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearAccountantLabour();
          return null;
        }
      }
      
      final cached = prefs.getString(_accountantLabourKey);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading accountant labour cache: $e');
    }
    return null;
  }
  
  /// Clear accountant labour cache
  static Future<void> clearAccountantLabour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accountantLabourKey);
      await prefs.remove(_accountantLabourTimestampKey);
    } catch (e) {
      print('Error clearing accountant labour cache: $e');
    }
  }
  
  /// Save accountant material entries to cache
  static Future<void> saveAccountantMaterial(List<Map<String, dynamic>> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountantMaterialKey, json.encode(entries));
      await prefs.setInt(_accountantMaterialTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving accountant material cache: $e');
    }
  }
  
  /// Load accountant material entries from cache
  static Future<List<Map<String, dynamic>>?> loadAccountantMaterial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_accountantMaterialTimestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearAccountantMaterial();
          return null;
        }
      }
      
      final cached = prefs.getString(_accountantMaterialKey);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading accountant material cache: $e');
    }
    return null;
  }
  
  /// Clear accountant material cache
  static Future<void> clearAccountantMaterial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accountantMaterialKey);
      await prefs.remove(_accountantMaterialTimestampKey);
    } catch (e) {
      print('Error clearing accountant material cache: $e');
    }
  }
  
  /// Save accountant dashboard data to cache
  static Future<void> saveAccountantDashboard(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountantDashboardKey, json.encode(data));
      await prefs.setInt(_accountantDashboardTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving accountant dashboard cache: $e');
    }
  }
  
  /// Load accountant dashboard data from cache
  static Future<Map<String, dynamic>?> loadAccountantDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_accountantDashboardTimestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearAccountantDashboard();
          return null;
        }
      }
      
      final cached = prefs.getString(_accountantDashboardKey);
      if (cached != null) {
        return Map<String, dynamic>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading accountant dashboard cache: $e');
    }
    return null;
  }
  
  /// Clear accountant dashboard cache
  static Future<void> clearAccountantDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accountantDashboardKey);
      await prefs.remove(_accountantDashboardTimestampKey);
    } catch (e) {
      print('Error clearing accountant dashboard cache: $e');
    }
  }
  
  // ============================================
  // DROPDOWN CACHE METHODS (Areas/Streets/Sites)
  // ============================================
  
  static const String _areasKey = 'dropdown_areas_cache';
  static const String _areasTimestampKey = 'dropdown_areas_timestamp';
  static const String _streetsKey = 'dropdown_streets_cache_';
  static const String _streetsTimestampKey = 'dropdown_streets_timestamp_';
  static const String _dropdownSitesKey = 'dropdown_sites_cache_';
  static const String _dropdownSitesTimestampKey = 'dropdown_sites_timestamp_';
  
  /// Save areas to cache
  static Future<void> saveAreas(List<String> areas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_areasKey, json.encode(areas));
      await prefs.setInt(_areasTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving areas cache: $e');
    }
  }
  
  /// Load areas from cache
  static Future<List<String>?> loadAreas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_areasTimestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearAreas();
          return null;
        }
      }
      
      final cached = prefs.getString(_areasKey);
      if (cached != null) {
        return List<String>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading areas cache: $e');
    }
    return null;
  }
  
  /// Clear areas cache
  static Future<void> clearAreas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_areasKey);
      await prefs.remove(_areasTimestampKey);
    } catch (e) {
      print('Error clearing areas cache: $e');
    }
  }
  
  /// Save streets for an area to cache
  static Future<void> saveStreets(String area, List<String> streets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_streetsKey$area';
      final timestampKey = '$_streetsTimestampKey$area';
      await prefs.setString(key, json.encode(streets));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving streets cache: $e');
    }
  }
  
  /// Load streets for an area from cache
  static Future<List<String>?> loadStreets(String area) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_streetsKey$area';
      final timestampKey = '$_streetsTimestampKey$area';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearStreets(area);
          return null;
        }
      }
      
      final cached = prefs.getString(key);
      if (cached != null) {
        return List<String>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading streets cache: $e');
    }
    return null;
  }
  
  /// Clear streets cache for an area
  static Future<void> clearStreets(String area) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_streetsKey$area';
      final timestampKey = '$_streetsTimestampKey$area';
      await prefs.remove(key);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Error clearing streets cache: $e');
    }
  }
  
  /// Save sites for an area+street to cache
  static Future<void> saveDropdownSites(String area, String street, List<Map<String, dynamic>> sites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_dropdownSitesKey${area}_$street';
      final timestampKey = '$_dropdownSitesTimestampKey${area}_$street';
      await prefs.setString(key, json.encode(sites));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving sites cache: $e');
    }
  }
  
  /// Load sites for an area+street from cache
  static Future<List<Map<String, dynamic>>?> loadDropdownSites(String area, String street) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_dropdownSitesKey${area}_$street';
      final timestampKey = '$_dropdownSitesTimestampKey${area}_$street';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearDropdownSites(area, street);
          return null;
        }
      }
      
      final cached = prefs.getString(key);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading sites cache: $e');
    }
    return null;
  }
  
  /// Clear sites cache for an area+street
  static Future<void> clearDropdownSites(String area, String street) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_dropdownSitesKey${area}_$street';
      final timestampKey = '$_dropdownSitesTimestampKey${area}_$street';
      await prefs.remove(key);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Error clearing sites cache: $e');
    }
  }
  
  // ============================================
  // SITE-SPECIFIC DATA CACHE (Supervisor/Site Engineer/Architect)
  // ============================================
  
  /// Save site-specific labour data
  static Future<void> saveSiteLabourData(String siteId, String role, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_labour_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_labour_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.setString(key, json.encode(data));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving site labour data: $e');
    }
  }
  
  /// Load site-specific labour data
  static Future<List<Map<String, dynamic>>?> loadSiteLabourData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_labour_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_labour_timestamp_${siteId}_${role.toLowerCase()}';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearSiteLabourData(siteId, role);
          return null;
        }
      }
      
      final cached = prefs.getString(key);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading site labour data: $e');
    }
    return null;
  }
  
  /// Clear site-specific labour data
  static Future<void> clearSiteLabourData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_labour_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_labour_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.remove(key);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Error clearing site labour data: $e');
    }
  }
  
  /// Save site-specific materials data
  static Future<void> saveSiteMaterialsData(String siteId, String role, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_materials_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_materials_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.setString(key, json.encode(data));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving site materials data: $e');
    }
  }
  
  /// Load site-specific materials data
  static Future<List<Map<String, dynamic>>?> loadSiteMaterialsData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_materials_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_materials_timestamp_${siteId}_${role.toLowerCase()}';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearSiteMaterialsData(siteId, role);
          return null;
        }
      }
      
      final cached = prefs.getString(key);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading site materials data: $e');
    }
    return null;
  }
  
  /// Clear site-specific materials data
  static Future<void> clearSiteMaterialsData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_materials_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_materials_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.remove(key);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Error clearing site materials data: $e');
    }
  }
  
  /// Save site-specific requests data
  static Future<void> saveSiteRequestsData(String siteId, String role, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_requests_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_requests_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.setString(key, json.encode(data));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving site requests data: $e');
    }
  }
  
  /// Load site-specific requests data
  static Future<List<Map<String, dynamic>>?> loadSiteRequestsData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_requests_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_requests_timestamp_${siteId}_${role.toLowerCase()}';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearSiteRequestsData(siteId, role);
          return null;
        }
      }
      
      final cached = prefs.getString(key);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading site requests data: $e');
    }
    return null;
  }
  
  /// Clear site-specific requests data
  static Future<void> clearSiteRequestsData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_requests_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_requests_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.remove(key);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Error clearing site requests data: $e');
    }
  }
  
  /// Save site-specific photos data
  static Future<void> saveSitePhotosData(String siteId, String role, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_photos_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_photos_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.setString(key, json.encode(data));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving site photos data: $e');
    }
  }
  
  /// Load site-specific photos data
  static Future<List<Map<String, dynamic>>?> loadSitePhotosData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_photos_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_photos_timestamp_${siteId}_${role.toLowerCase()}';
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await clearSitePhotosData(siteId, role);
          return null;
        }
      }
      
      final cached = prefs.getString(key);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(json.decode(cached));
      }
    } catch (e) {
      print('Error loading site photos data: $e');
    }
    return null;
  }
  
  /// Clear site-specific photos data
  static Future<void> clearSitePhotosData(String siteId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'site_photos_${siteId}_${role.toLowerCase()}';
      final timestampKey = 'site_photos_timestamp_${siteId}_${role.toLowerCase()}';
      await prefs.remove(key);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Error clearing site photos data: $e');
    }
  }
}
