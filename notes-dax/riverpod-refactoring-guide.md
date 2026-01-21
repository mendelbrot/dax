# Riverpod Refactoring Guide: Flutter Data Management Migration

## Overview

This document outlines the comprehensive refactoring plan to migrate the Flutter app from Provider-based state management to Riverpod with codegen, and convert manual model classes to Freezed with JSON serialization. The primary goal is to implement automatic data refresh when vaults/entries are created, edited, or deleted.

**Created:** 2025-01-XX  
**Status:** Planning Phase

---

## Current State Analysis

### Current Architecture

**State Management:**
- Using `provider` package (version 6.1.1)
- Only `AuthProvider` uses Provider pattern
- Pages use `StatefulWidget` with manual state management

**Models:**
- Manual Dart classes: `Entry` and `Vault`
- Custom `fromMap`/`toMap` methods for JSON conversion
- Manual `copyWith` implementations
- Located in `/client-flutter/lib/models/`

**Data Layer:**
- Static `Data` service class with nested `VaultService` and `EntryService`
- Direct Supabase client access via `SupabaseService.client`
- No caching or state management at data layer
- Located in `/client-flutter/lib/services/data_service.dart`

**UI Layer:**
- Pages manually fetch data using `FutureBuilder` or `setState`
- Manual refresh patterns:
  - `HomePage`: Uses `_refreshKey` to force `FutureBuilder` rebuild
  - `VaultPage`: Calls `_loadData()` manually after mutations
  - `EntryPage`: No refresh needed (single entry view)
- No automatic refresh after create/update/delete operations

### Current Issues

1. **No Automatic Refresh**: Data doesn't refresh automatically after create/update/delete operations
2. **Scattered State Management**: Each page manages its own loading/error state
3. **No Centralized Cache**: No shared state between pages viewing the same data
4. **Manual Refresh Patterns**: Inconsistent refresh mechanisms across pages
5. **No Real-time Updates**: No Supabase Realtime subscriptions
6. **Type Safety**: Manual JSON conversion is error-prone

### Current File Structure

```
client-flutter/lib/
├── main.dart                    # Uses Provider for AuthProvider
├── models/
│   ├── entry.dart              # Manual Entry class
│   └── vault.dart              # Manual Vault class
├── services/
│   ├── auth_provider.dart      # ChangeNotifier-based auth
│   ├── data_service.dart       # Static Data service
│   ├── supabase_service.dart   # Supabase client singleton
│   └── app_router.dart         # GoRouter configuration
└── pages/
    ├── home_page.dart          # Vault list with manual refresh
    ├── vault_page.dart         # Entry list with manual refresh
    ├── entry_page.dart         # Single entry editor
    ├── vault_settings_page.dart # Vault settings
    └── sign_in_page.dart       # Auth UI
```

---

## Refactoring Strategy

### Phase 1: Setup & Dependencies (Foundation)

**Objective:** Add all necessary dependencies and configure build tools.

**Tasks:**

1. **Update `pubspec.yaml` dependencies:**
   ```yaml
   dependencies:
     flutter_riverpod: ^2.5.1
     riverpod_annotation: ^2.3.5
     freezed_annotation: ^2.4.1
     json_annotation: ^4.8.1
   
   dev_dependencies:
     riverpod_generator: ^2.3.11
     freezed: ^2.4.7
     json_serializable: ^6.7.1
     build_runner: ^2.4.8
   ```

2. **Create `build.yaml` configuration:**
   ```yaml
   targets:
     $default:
       builders:
         riverpod_generator:
           generate_for:
             - lib/**
         json_serializable:
           options:
             any_map: false
             checked: false
   ```

3. **Update `analysis_options.yaml`:**
   - Add rules for Riverpod and Freezed
   - Configure linter for generated code

4. **Set up ProviderScope in `main.dart`:**
   - Wrap app with `ProviderScope`
   - Keep existing Provider temporarily for AuthProvider

**Deliverables:**
- Updated `pubspec.yaml`
- `build.yaml` configuration file
- Updated `main.dart` with ProviderScope
- Dependencies installed and verified

**Risk Level:** Low  
**Estimated Time:** 1-2 hours

---

### Phase 2: Convert Models to Freezed (Low Risk)

**Objective:** Convert `Entry` and `Vault` models to Freezed with JSON serialization.

**Tasks:**

1. **Convert `Entry` model:**
   - Add Freezed annotations
   - Add JSON serialization annotations
   - Use `@JsonSerializable(fieldRename: FieldRename.snake)` for snake_case
   - Generate `fromJson`/`toJson` methods
   - Handle nullable fields appropriately

2. **Convert `Vault` model:**
   - Same approach as Entry
   - Ensure `ownerId` maps correctly to `owner_id`

3. **Update `data_service.dart`:**
   - Replace `fromMap` calls with `fromJson`
   - Replace `toMap` calls with `toJson`
   - Update all usages

4. **Run code generation:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Update all imports:**
   - Update model imports across codebase
   - Verify all usages work correctly

**Example Entry Model Structure:**
```dart
@freezed
class Entry with _$Entry {
  const factory Entry({
    String? id,
    String? heading,
    String? body,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vaultId,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}
```

**Deliverables:**
- Freezed `Entry` model with JSON serialization
- Freezed `Vault` model with JSON serialization
- Updated `data_service.dart` using new models
- All existing functionality preserved

**Risk Level:** Low  
**Estimated Time:** 2-3 hours  
**Testing:** Verify all CRUD operations still work

---

### Phase 3: Create Riverpod Providers (Core Logic)

**Objective:** Create Riverpod providers for data fetching and mutations with automatic invalidation.

**Tasks:**

1. **Create provider structure:**
   ```
   lib/providers/
   ├── supabase_provider.dart    # Supabase client provider
   ├── vault_providers.dart      # Vault-related providers
   └── entry_providers.dart      # Entry-related providers
   ```

2. **Create Supabase client provider:**
   ```dart
   @riverpod
   SupabaseClient supabaseClient(SupabaseClientRef ref) {
     return SupabaseService.client;
   }
   ```

3. **Create vault providers:**
   - `vaultsProvider` - AsyncNotifierProvider for vault list
   - `vaultProvider(String vaultId)` - FutureProvider for single vault
   - `createVaultProvider` - Provider for create mutation
   - `updateVaultProvider` - Provider for update mutation
   - `deleteVaultProvider` - Provider for delete mutation

4. **Create entry providers:**
   - `entriesProvider(String vaultId)` - AsyncNotifierProvider for entries list
   - `entryProvider(String entryId)` - FutureProvider for single entry
   - `createEntryProvider` - Provider for create mutation
   - `updateEntryProvider` - Provider for update mutation
   - `deleteEntryProvider` - Provider for delete mutation

5. **Implement invalidation logic:**
   - When vault created: invalidate `vaultsProvider`
   - When vault updated: invalidate `vaultsProvider` and `vaultProvider(vaultId)`
   - When vault deleted: invalidate `vaultsProvider` and related `entriesProvider`
   - When entry created: invalidate `entriesProvider(vaultId)`
   - When entry updated: invalidate `entriesProvider(vaultId)` and `entryProvider(entryId)`
   - When entry deleted: invalidate `entriesProvider(vaultId)`

**Example Provider Structure:**
```dart
@riverpod
class Vaults extends _$Vaults {
  @override
  FutureOr<List<Vault>> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase.from('dax_vault').select();
    return (response as List<dynamic>)
        .map((json) => Vault.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

@riverpod
Future<void> createVault(
  CreateVaultRef ref,
  String name,
  Map<String, dynamic> settings,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final vault = Vault(name: name, settings: settings);
  await supabase.from('dax_vault').insert(vault.toJson());
  
  // Invalidate vaults list to refresh
  ref.invalidate(vaultsProvider);
}
```

**Deliverables:**
- Complete provider structure
- All CRUD operations as providers
- Proper invalidation logic
- Generated provider files

**Risk Level:** Medium  
**Estimated Time:** 4-6 hours  
**Testing:** Test providers independently before UI integration

---

### Phase 4: Migrate AuthProvider to Riverpod

**Objective:** Convert `AuthProvider` from Provider to Riverpod.

**Tasks:**

1. **Create `auth_providers.dart`:**
   - Convert `AuthProvider` to Riverpod `AsyncNotifier`
   - Maintain same API surface for compatibility
   - Use `supabaseClientProvider` for Supabase access

2. **Update `main.dart`:**
   - Remove `ChangeNotifierProvider` wrapper
   - Ensure `ProviderScope` wraps entire app
   - Update router to use Riverpod providers

3. **Update `app_router.dart`:**
   - Access auth state via Riverpod instead of Provider
   - Update `AuthWrapper` to use `ref.watch(authProvider)`

4. **Update all auth usages:**
   - Replace `context.read<AuthProvider>()` with `ref.read(authProvider.notifier)`
   - Replace `context.watch<AuthProvider>()` with `ref.watch(authProvider)`
   - Update `sign_in_page.dart` and other auth-related pages

**Example Auth Provider:**
```dart
@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<AuthState> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    
    // Listen to auth changes
    ref.listenSelf((previous, next) {
      // Handle auth state changes
    });
    
    return AuthState(
      isAuthenticated: user != null,
      userEmail: user?.email,
    );
  }
  
  Future<void> sendOTP(String email) async {
    // Implementation
    ref.invalidateSelf(); // Refresh auth state
  }
}
```

**Deliverables:**
- Riverpod-based auth provider
- Updated `main.dart` and router
- All auth functionality working

**Risk Level:** Medium  
**Estimated Time:** 2-3 hours  
**Testing:** Verify login/logout flow works correctly

---

### Phase 5: Update Pages to Use Riverpod (UI Layer)

**Objective:** Migrate all pages to use Riverpod providers, removing manual refresh logic.

**Migration Order:**
1. `HomePage` (simplest - just list)
2. `VaultPage` (list with filtering)
3. `EntryPage` (single item with mutations)
4. `VaultSettingsPage` (single item with mutations)

**Tasks for Each Page:**

1. **HomePage:**
   - Replace `FutureBuilder` with `ref.watch(vaultsProvider)`
   - Use `AsyncValue` for loading/error states
   - Replace `_createVault` to use `ref.read(createVaultProvider(...).future)`
   - Remove `_refreshKey` mechanism
   - Invalidation happens automatically via provider

2. **VaultPage:**
   - Replace `_loadData()` with `ref.watch(entriesProvider(vaultId))`
   - Use `AsyncValue` for loading/error states
   - Replace `_createEntry` to use `ref.read(createEntryProvider(...).future)`
   - Remove manual `_loadData()` calls
   - Navigation after create triggers automatic refresh

3. **EntryPage:**
   - Replace `_fetchData()` with `ref.watch(entryProvider(entryId))`
   - Keep debounce logic for auto-save
   - Use `ref.read(updateEntryProvider(...).future)` for saves
   - Use `ref.read(deleteEntryProvider(...).future)` for deletion
   - Invalidate on save/delete

4. **VaultSettingsPage:**
   - Replace `_loadVault()` with `ref.watch(vaultProvider(vaultId))`
   - Use providers for update/delete operations
   - Remove manual state management

**Example Page Migration:**
```dart
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(vaultsProvider);

    return vaultsAsync.when(
      data: (vaults) => _buildPageContent(context, ref, vaults),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _createVault(BuildContext context, WidgetRef ref, String name) async {
    try {
      await ref.read(createVaultProvider(name, {}).future);
      // No need to refresh - provider invalidates automatically
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vault created')),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}
```

**Deliverables:**
- All pages migrated to Riverpod
- Manual refresh logic removed
- Automatic data refresh working
- All existing functionality preserved

**Risk Level:** High  
**Estimated Time:** 6-8 hours  
**Testing:** Thoroughly test each page after migration

---

### Phase 6: Add Real-time Updates (Optional Enhancement)

**Objective:** Add Supabase Realtime subscriptions for automatic updates across devices/tabs.

**Tasks:**

1. **Enable Realtime on Supabase tables:**
   - Verify Realtime is enabled for `dax_vault` and `dax_entry` tables
   - Check Supabase dashboard settings

2. **Create Realtime providers:**
   - `vaultsRealtimeProvider` - Listens to vault changes
   - `entriesRealtimeProvider(vaultId)` - Listens to entry changes

3. **Integrate with existing providers:**
   - Update `vaultsProvider` to listen to Realtime changes
   - Update `entriesProvider` to listen to Realtime changes
   - Invalidate providers when Realtime events occur

4. **Handle edge cases:**
   - Multiple tabs/devices
   - Network disconnections
   - Conflict resolution

**Example Realtime Integration:**
```dart
@riverpod
class Vaults extends _$Vaults {
  StreamSubscription? _subscription;

  @override
  FutureOr<List<Vault>> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    
    // Initial load
    final response = await supabase.from('dax_vault').select();
    final vaults = (response as List<dynamic>)
        .map((json) => Vault.fromJson(json as Map<String, dynamic>))
        .toList();
    
    // Listen to Realtime changes
    _subscription = supabase
        .from('dax_vault')
        .stream(primaryKey: ['id'])
        .listen((data) {
      // Invalidate to refresh
      ref.invalidateSelf();
    });
    
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    return vaults;
  }
}
```

**Deliverables:**
- Realtime subscriptions working
- Automatic updates across tabs/devices
- Proper cleanup on dispose

**Risk Level:** Medium  
**Estimated Time:** 3-4 hours  
**Testing:** Test with multiple tabs/devices

---

## Important Considerations

### 1. Riverpod Codegen Benefits

- **Type Safety**: Compile-time checking of provider dependencies
- **Less Boilerplate**: Generated code reduces manual work
- **Better IDE Support**: Autocomplete and navigation work better
- **Easier Refactoring**: Rename providers and regenerate

### 2. Freezed + JsonSerializable Integration

- **Freezed** generates immutable classes with `copyWith`
- **JsonSerializable** handles JSON conversion
- Use `@JsonSerializable(fieldRename: FieldRename.snake)` for snake_case DB columns
- Works seamlessly together

### 3. Provider Invalidation Strategy

**Key Principle:** Invalidate providers that depend on changed data.

**Invalidation Rules:**
- Create vault → invalidate `vaultsProvider`
- Update vault → invalidate `vaultsProvider` and `vaultProvider(vaultId)`
- Delete vault → invalidate `vaultsProvider` and all `entriesProvider(vaultId)` for that vault
- Create entry → invalidate `entriesProvider(vaultId)`
- Update entry → invalidate `entriesProvider(vaultId)` and `entryProvider(entryId)`
- Delete entry → invalidate `entriesProvider(vaultId)`

**Best Practices:**
- Use `ref.invalidate()` for immediate refresh
- Use `ref.refresh()` if you need the new value immediately
- Consider `autoDispose: false` for important providers that should persist

### 4. Error Handling

- Use `AsyncValue` for loading/error states
- Handle network errors gracefully
- Consider retry logic for failed operations
- Show user-friendly error messages

**Example Error Handling:**
```dart
vaultsAsync.when(
  data: (vaults) => VaultList(vaults: vaults),
  loading: () => LoadingIndicator(),
  error: (error, stack) => ErrorWidget(
    error: error,
    onRetry: () => ref.invalidate(vaultsProvider),
  ),
)
```

### 5. Migration Challenges & Solutions

**Challenge 1: GoRouter Integration**
- **Problem:** Router callbacks need access to `ref`
- **Solution:** Use `ref.read` in callbacks, or pass `ref` through context

**Challenge 2: Navigation After Mutations**
- **Problem:** Need to navigate after create/update
- **Solution:** Use `ref.read(createProvider(...).future).then((_) => context.go(...))`

**Challenge 3: Debounced Saves**
- **Problem:** EntryPage has debounced auto-save
- **Solution:** Keep debounce logic in page, use provider for actual save

**Challenge 4: Conditional Providers**
- **Problem:** Some providers depend on auth state
- **Solution:** Use `ref.watch(authProvider)` and conditionally build providers

### 6. Testing Strategy

While tests are not currently part of the project, consider:
- Unit tests for providers (mock Supabase client)
- Widget tests for pages using Riverpod
- Integration tests for full flows

### 7. Performance Considerations

- **Provider Caching:** Riverpod caches provider values automatically
- **Auto-dispose:** Use `autoDispose: true` for providers that should clean up
- **Selective Watching:** Use `ref.watch(provider.select(...))` to watch only specific parts
- **Lazy Loading:** Providers only build when first accessed

---

## Potential Pitfalls

### 1. Circular Dependencies

**Problem:** Providers depending on each other can cause issues.

**Solution:** 
- Structure providers hierarchically
- Use `ref.watch` for dependencies
- Avoid mutual dependencies

### 2. Over-invalidation

**Problem:** Invalidating too many providers causes performance issues.

**Solution:**
- Only invalidate what's necessary
- Use selective invalidation
- Consider using `ref.refresh` instead of `ref.invalidate` when appropriate

### 3. State Persistence

**Problem:** Some providers should persist across navigation.

**Solution:**
- Use `autoDispose: false` for important providers
- Consider `keepAlive` for providers that should persist

### 4. Supabase Client Access

**Problem:** Need consistent Supabase client access.

**Solution:**
- Create `supabaseClientProvider` for dependency injection
- Use `ref.watch(supabaseClientProvider)` everywhere

### 5. AsyncValue Handling

**Problem:** Forgetting to handle all AsyncValue states.

**Solution:**
- Always use `.when()` or check `.isLoading`, `.hasError`, `.hasValue`
- Provide UI for all states

---

## Recommended Migration Approach

### Incremental Migration Strategy

Break the work into smaller, manageable phases:

**Plan 1: Setup & Models (Low Risk)**
- Add dependencies
- Convert models to Freezed
- Update data service
- **No UI changes** - everything still works the same way

**Plan 2: Core Providers (Medium Risk)**
- Create Riverpod providers
- Keep existing UI temporarily
- Test providers independently
- Wire up providers alongside current code

**Plan 3: Migrate Auth & Main App (Medium Risk)**
- Convert AuthProvider to Riverpod
- Update main.dart with ProviderScope
- Update router
- Test auth flow thoroughly

**Plan 4: Migrate Pages One-by-One (Higher Risk)**
- Start with HomePage (simplest)
- Test thoroughly after each page
- Move to VaultPage, then EntryPage, then VaultSettingsPage
- Remove old code once stable

**Plan 5: Real-time & Polish (Enhancement)**
- Add Supabase Realtime subscriptions
- Optimize refresh logic
- Clean up any remaining manual refresh code
- Performance tuning

---

## File Structure After Migration

```
client-flutter/lib/
├── main.dart                    # ProviderScope wrapper
├── models/
│   ├── entry.dart              # Freezed Entry model
│   ├── entry.freezed.dart      # Generated
│   ├── entry.g.dart            # Generated
│   ├── vault.dart              # Freezed Vault model
│   ├── vault.freezed.dart      # Generated
│   └── vault.g.dart            # Generated
├── providers/
│   ├── supabase_provider.dart  # Supabase client provider
│   ├── supabase_provider.g.dart # Generated
│   ├── auth_providers.dart     # Auth providers
│   ├── auth_providers.g.dart   # Generated
│   ├── vault_providers.dart    # Vault providers
│   ├── vault_providers.g.dart  # Generated
│   ├── entry_providers.dart    # Entry providers
│   └── entry_providers.g.dart  # Generated
├── services/
│   ├── supabase_service.dart   # Supabase initialization (unchanged)
│   └── app_router.dart         # GoRouter (updated for Riverpod)
└── pages/
    ├── home_page.dart          # Uses Riverpod providers
    ├── vault_page.dart         # Uses Riverpod providers
    ├── entry_page.dart         # Uses Riverpod providers
    ├── vault_settings_page.dart # Uses Riverpod providers
    └── sign_in_page.dart       # Uses Riverpod auth providers
```

---

## Code Generation Commands

After making changes to providers or models:

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate automatically
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## Success Criteria

The refactoring is complete when:

1. ✅ All models use Freezed with JSON serialization
2. ✅ All data operations use Riverpod providers
3. ✅ Auth uses Riverpod instead of Provider
4. ✅ All pages use Riverpod providers
5. ✅ Data automatically refreshes after create/update/delete
6. ✅ No manual refresh logic remains
7. ✅ All existing functionality works as before
8. ✅ Code is cleaner and more maintainable

---

## Next Steps

1. Review this document
2. Create detailed plans for each phase in `.cursor/plans/`
3. Start with Phase 1 (Setup & Dependencies)
4. Progress through phases incrementally
5. Test thoroughly after each phase

---

## References

- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [JsonSerializable Documentation](https://pub.dev/packages/json_serializable)
- [Supabase Flutter Realtime](https://supabase.com/docs/guides/realtime/postgres-changes)
