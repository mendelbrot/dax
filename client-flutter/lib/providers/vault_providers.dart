import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/vault.dart';
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