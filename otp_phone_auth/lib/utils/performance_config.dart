import 'package:flutter/material.dart';
import 'dart:async';

/// Performance optimization configuration
class PerformanceConfig {
  // Cache durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(minutes: 15);
  static const Duration longCacheDuration = Duration(hours: 1);
  
  // Network timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration uploadTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Image optimization
  static const double thumbnailQuality = 0.6;
  static const int thumbnailMaxWidth = 800;
  static const int thumbnailMaxHeight = 800;
  
  // Debounce delays
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration autoSaveDebounce = Duration(seconds: 2);
  
  // UI optimization
  static const bool enableAnimations = true;
  static const Duration animationDuration = Duration(milliseconds: 200);
  
  // Lazy loading thresholds
  static const double lazyLoadThreshold = 0.8; // Load more when 80% scrolled
  
  // Cache keys
  static const String sitesCache = 'sites_cache';
  static const String areasCache = 'areas_cache';
  static const String streetsCache = 'streets_cache';
  static const String userCache = 'user_cache';
  static const String materialBalanceCache = 'material_balance_cache';
}

/// Simple in-memory cache
class SimpleCache {
  static final SimpleCache _instance = SimpleCache._internal();
  factory SimpleCache() => _instance;
  SimpleCache._internal();
  
  final Map<String, CacheEntry> _cache = {};
  
  void set(String key, dynamic value, {Duration? duration}) {
    _cache[key] = CacheEntry(
      value: value,
      expiry: DateTime.now().add(duration ?? PerformanceConfig.mediumCacheDuration),
    );
  }
  
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value as T?;
  }
  
  void remove(String key) {
    _cache.remove(key);
  }
  
  void clear() {
    _cache.clear();
  }
  
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiry));
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime expiry;
  
  CacheEntry({required this.value, required this.expiry});
}

/// Loading state manager
class LoadingStateManager extends ChangeNotifier {
  final Map<String, bool> _loadingStates = {};
  
  bool isLoading(String key) => _loadingStates[key] ?? false;
  
  void setLoading(String key, bool loading) {
    _loadingStates[key] = loading;
    notifyListeners();
  }
  
  void clearAll() {
    _loadingStates.clear();
    notifyListeners();
  }
}

/// Debouncer for search and auto-save
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({required this.delay});
  
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
