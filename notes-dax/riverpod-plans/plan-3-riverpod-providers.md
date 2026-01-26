# Plan 3: Create Riverpod Providers

**Objective:** Create Riverpod providers for data fetching and mutations with automatic invalidation.

**Risk Level:** Medium  
**Estimated Time:** 4-6 hours

**Prerequisite:** Plans 1-2 completed

---

## Checklist

- [ ] Create provider directory structure
- [ ] Create `supabase_provider.dart`
- [ ] Create `vault_providers.dart`
- [ ] Create `entry_providers.dart`
- [ ] Run code generation
- [ ] Test providers independently (before UI integration)

---

## Directory Structure

Create `client-flutter/lib/providers/`:

```
lib/providers/
├── supabase_provider.dart
├── vault_providers.dart
└── entry_providers.dart
```

---

## Step 1: Create Supabase Provider

Create `client-flutter/lib/providers/supabase_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dax/services/supabase_service.dart';

part 'supabase_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return SupabaseService.client;
}
```

---

## Step 2: Create Vault Providers

Create `client-flutter/lib/providers/vault_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dax/models/vault.dart';
import 'supabase_provider.dart';

part 'vault_providers.g.dart';

/// Provider for listing all vaults
@riverpod
class Vaults extends _$Vaults {
  @override
  Future<List<Vault>> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase.from('dax_vault').select();
    return (response as List<dynamic>)
        .map((json) => Vault.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Provider for a single vault (supports mutations)
@riverpod
class VaultDetail extends _$VaultDetail {
  @override
  Future<Vault> build(String vaultId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase
        .from('dax_vault')
        .select()
        .eq('id', vaultId)
        .single();
    return Vault.fromJson(response);
  }

  /// Save vault with optimistic update (no refetch)
  Future<void> saveVault(Vault updatedVault) async {
    final supabase = ref.watch(supabaseClientProvider);
    
    final json = updatedVault.toJson()
      ..removeWhere((key, value) => 
          key == 'id' || key == 'created_at' || key == 'owner_id');
    
    await supabase
        .from('dax_vault')
        .update(json)
        .eq('id', updatedVault.id!);
    
    // Update local state directly - NO REFETCH
    state = AsyncValue.data(updatedVault);
    
    // Invalidate vaults list (lazy - won't refetch until watched)
    ref.invalidate(vaultsProvider);
  }

  /// Delete vault
  Future<void> deleteVault() async {
    final supabase = ref.watch(supabaseClientProvider);
    final vaultId = state.value!.id!;
    
    await supabase.from('dax_vault').delete().eq('id', vaultId);
    
    // Invalidate vaults list
    ref.invalidate(vaultsProvider);
  }
}

/// Provider for creating a new vault
@riverpod
Future<Vault> createVault(
  CreateVaultRef ref,
  String name,
  Map<String, dynamic> settings,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  
  final vault = Vault(name: name, settings: settings);
  final json = vault.toJson()
    ..removeWhere((key, value) => value == null);
  
  final response = await supabase
      .from('dax_vault')
      .insert(json)
      .select()
      .single();
  
  // Invalidate vaults list (lazy refetch)
  ref.invalidate(vaultsProvider);
  
  return Vault.fromJson(response);
}
```

---

## Step 3: Create Entry Providers

Create `client-flutter/lib/providers/entry_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dax/models/entry.dart';
import 'supabase_provider.dart';

part 'entry_providers.g.dart';

/// Provider for listing entries in a vault
@riverpod
class Entries extends _$Entries {
  @override
  Future<List<Entry>> build(String vaultId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase
        .from('dax_entry')
        .select()
        .eq('vault_id', vaultId)
        .order('updated_at', ascending: false);
    return (response as List<dynamic>)
        .map((json) => Entry.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Provider for a single entry (supports mutations)
@riverpod
class EntryDetail extends _$EntryDetail {
  @override
  Future<Entry> build(String entryId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase
        .from('dax_entry')
        .select()
        .eq('id', entryId)
        .single();
    return Entry.fromJson(response);
  }

  /// Save entry with optimistic update (no refetch)
  Future<void> saveEntry(Entry updatedEntry) async {
    final supabase = ref.watch(supabaseClientProvider);
    
    final json = <String, dynamic>{};
    if (updatedEntry.heading != null) json['heading'] = updatedEntry.heading;
    if (updatedEntry.body != null) json['body'] = updatedEntry.body;
    if (updatedEntry.attributes != null) json['attributes'] = updatedEntry.attributes;
    
    await supabase
        .from('dax_entry')
        .update(json)
        .eq('id', updatedEntry.id!);
    
    // Update local state directly - NO REFETCH
    state = AsyncValue.data(updatedEntry);
    
    // Invalidate entries list (lazy - won't refetch until vault page watched)
    if (updatedEntry.vaultId != null) {
      ref.invalidate(entriesProvider(updatedEntry.vaultId!));
    }
  }

  /// Delete entry
  Future<void> deleteEntry(String vaultId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final entryId = state.value!.id!;
    
    await supabase.from('dax_entry').delete().eq('id', entryId);
    
    // Invalidate entries list
    ref.invalidate(entriesProvider(vaultId));
  }
}

/// Provider for creating a new entry
@riverpod
Future<Entry> createEntry(
  CreateEntryRef ref,
  String vaultId,
  String heading,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  
  final json = {
    'heading': heading,
    'vault_id': vaultId,
  };
  
  final response = await supabase
      .from('dax_entry')
      .insert(json)
      .select()
      .single();
  
  // Invalidate entries list (lazy refetch)
  ref.invalidate(entriesProvider(vaultId));
  
  return Entry.fromJson(response);
}
```

---

## Step 4: Run Code Generation

```bash
cd client-flutter
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `supabase_provider.g.dart`
- `vault_providers.g.dart`
- `entry_providers.g.dart`

---

## Step 5: Test Providers (Optional)

Before integrating with UI, you can test providers in isolation by temporarily adding test code:

```dart
// In a test file or temporary main
void testProviders() async {
  final container = ProviderContainer();
  
  // Test vaults list
  final vaults = await container.read(vaultsProvider.future);
  print('Vaults: ${vaults.length}');
  
  // Test single vault
  if (vaults.isNotEmpty) {
    final vault = await container.read(vaultDetailProvider(vaults.first.id!).future);
    print('Vault name: ${vault.name}');
  }
  
  container.dispose();
}
```

---

## Key Design Decisions

### Optimistic Updates
- `saveVault` and `saveEntry` update local state directly after saving
- No unnecessary network request to refetch what we already know
- The entries/vaults lists are invalidated but won't refetch until watched

### Lazy Invalidation
- `ref.invalidate()` marks providers stale but doesn't trigger refetch
- Refetch happens only when a widget watches the provider
- Prevents unnecessary API calls when editing entries

### Provider Naming
- `vaultsProvider` — list of all vaults
- `vaultDetailProvider(vaultId)` — single vault with mutations
- `createVaultProvider(name, settings)` — one-shot create operation
- Same pattern for entries

---

## Success Criteria

- [ ] Generated files compile without errors
- [ ] `flutter analyze` passes
- [ ] Provider structure matches the plan
- [ ] Ready for UI integration in subsequent plans
