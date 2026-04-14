# Complete Provider Migration Plan

## Current Status

### ✅ Already Migrated (Using Cached Data)
1. **Login Screen** - Uses `AuthProvider`
2. **Supervisor History Screen** - Uses `ConstructionProvider` and `ChangeRequestProvider`
3. **Accountant Dashboard** - Uses `ConstructionProvider`
4. **Accountant Change Requests Screen** - Uses `ChangeRequestProvider`

### 🔄 Screens to Migrate

#### High Priority (Load Data Repeatedly)
1. **Supervisor Dashboard Feed** - Loads sites every time
2. **Accountant Reports Screen** - Loads all entries every time
3. **Supervisor Changes Screen** - Loads modified entries every time

#### Medium Priority (Load Data on Entry)
4. **Site Detail Screen** - Loads today's entries (can cache per site)

## Implementation Strategy

### Phase 1: Add Missing Provider Methods

Add to `ConstructionProvider`:
- `loadReportsData()` - For accountant reports (same as accountant data but with role filtering)
- `loadModifiedEntries()` - For supervisor changes screen

### Phase 2: Migrate Screens

#### 1. Supervisor Dashboard Feed
**Current**: Loads sites on every visit
**Target**: Load sites once, cache them
**Changes**:
- Wrap with `Consumer<ConstructionProvider>`
- Use `provider.sites` instead of `_sites`
- Use `provider.loadSites()` in initState
- Use `provider.loadSites(forceRefresh: true)` for refresh

#### 2. Accountant Reports Screen
**Current**: Loads all entries on every visit
**Target**: Use cached accountant data from provider
**Changes**:
- Wrap with `Consumer<ConstructionProvider>`
- Use `provider.accountantLabourEntries` and `provider.accountantMaterialEntries`
- Remove local `_loadData()` method
- Filter data locally by role (no need to reload)

#### 3. Supervisor Changes Screen
**Current**: Loads modified entries on every visit
**Target**: Load once, cache them
**Changes**:
- Wrap with `Consumer<ChangeRequestProvider>`
- Use `provider.modifiedLabourEntries` and `provider.modifiedMaterialEntries`
- Use `provider.loadModifiedEntries()` in initState
- Use `provider.loadModifiedEntries(forceRefresh: true)` for refresh

#### 4. Site Detail Screen
**Current**: Loads today's entries for each site
**Target**: Keep as-is (site-specific data, not worth caching)
**Reason**: Each site has different data, caching would be complex

## Benefits After Migration

1. **No Repeated Loading**: Data loads once per session
2. **Instant Navigation**: Cached data displays immediately
3. **Better UX**: No loading spinners on every navigation
4. **Consistent State**: All screens see same data
5. **Automatic Updates**: After mutations, data refreshes automatically
6. **Reduced Backend Load**: Fewer API calls

## Testing Checklist

After migration, test:
- [ ] First visit shows loading
- [ ] Data displays correctly
- [ ] Navigate away and back - no loading (uses cache)
- [ ] Pull-to-refresh works
- [ ] Multiple navigations use cached data
- [ ] Logout clears cache
- [ ] Login shows fresh data

## Files to Modify

1. `otp_phone_auth/lib/providers/construction_provider.dart` - Add methods if needed
2. `otp_phone_auth/lib/providers/change_request_provider.dart` - Already has loadModifiedEntries
3. `otp_phone_auth/lib/screens/supervisor_dashboard_feed.dart`
4. `otp_phone_auth/lib/screens/accountant_reports_screen.dart`
5. `otp_phone_auth/lib/screens/supervisor_changes_screen.dart`
