# Comprehensive Admin Optimization Plan

**Date:** April 16, 2026  
**Goal:** Cache + Background Refresh for all admin pages

---

## ✅ Already Optimized

### 1. Sites Page (Admin Dashboard - Sites Tab)
**Status:** ✅ Cache implemented
- Areas cached
- Streets cached by area
- Sites cached by area+street
- Instant display on revisit

### 2. Notifications Tab
**Status:** ✅ Cache implemented
- Notifications cached with flag
- Force refresh available
- Pull-to-refresh implemented
- IndexedStack keeps state alive

### 3. Issues Page (Client Complaints)
**Status:** ✅ Cache + State Persistence
- Complaints cached per filter status
- AutomaticKeepAliveClientMixin added
- IndexedStack keeps state alive
- Pull-to-refresh implemented

### 4. Budget Management (Allocation & Utilization)
**Status:** ✅ Cache implemented
- Budget allocation cached
- Utilization cached
- Requirements cached
- Tab switching doesn't reload
- Pull-to-refresh on both tabs

---

## 🔄 Needs Background Refresh

### What is Background Refresh?
Automatically refresh data in the background at intervals (e.g., every 30 seconds) without user interaction.

### Pages to Add Background Refresh:

1. **Sites Page** - Refresh areas/streets/sites periodically
2. **Labour Rates** - Refresh rates data
3. **Notifications** - Refresh to show new notifications
4. **Issues** - Refresh to show new complaints
5. **Budget Allocation** - Refresh budget data
6. **Budget Utilization** - Refresh utilization data

---

## 📋 Implementation Plan

### Phase 1: Add Background Refresh Infrastructure
- Create a timer-based refresh mechanism
- Add refresh intervals (configurable)
- Implement silent background refresh (no loading indicators)
- Add pause/resume on app lifecycle changes

### Phase 2: Apply to Each Page
- Sites Page: Refresh every 60 seconds
- Labour Rates: Refresh every 120 seconds
- Notifications: Refresh every 30 seconds
- Issues: Refresh every 60 seconds
- Budget tabs: Refresh every 90 seconds

### Phase 3: Optimization
- Only refresh when tab is visible
- Pause refresh when app is in background
- Cancel timers on dispose
- Smart refresh (only if data changed)

---

## 🎯 Benefits

### With Cache Only (Current):
- ✅ Instant display on revisit
- ✅ Reduced API calls
- ❌ Data may be stale
- ❌ User must manually refresh

### With Cache + Background Refresh:
- ✅ Instant display on revisit
- ✅ Reduced API calls
- ✅ Always fresh data
- ✅ No manual refresh needed
- ✅ Real-time updates

---

## 🚀 Next Steps

1. Implement background refresh for Sites page
2. Implement background refresh for Labour Rates
3. Implement background refresh for Notifications
4. Implement background refresh for Issues
5. Implement background refresh for Budget tabs

---

**Status:** Ready to implement  
**Estimated Time:** 30-45 minutes for all pages

