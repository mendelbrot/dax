import 'package:dax/models/entry.dart';
import 'package:dax/models/vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/services/data_service.dart';

// Parameters for entry search
class EntrySearchParams {
  final String vaultId;
  final String query;

  const EntrySearchParams(this.vaultId, this.query);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntrySearchParams &&
          runtimeType == other.runtimeType &&
          vaultId == other.vaultId &&
          query == other.query;

  @override
  int get hashCode => Object.hash(vaultId, query);
}

// Provider for listing all entries in a vault
final entriesProvider = FutureProvider.family<List<Entry>, String>((
  ref,
  vaultId,
) async {
  return await Data.entries.list(
    QueryOptions(
      filters: {'vault_id': vaultId},
      sortBy: 'updated_at',
      ascending: false,
      limit: 8,
    ),
  );
});

// Provider for searching entries in a vault
final entriesSearchProvider =
    FutureProvider.family<List<Entry>, EntrySearchParams>((ref, params) async {
      return await Data.entries.searchEntries(params.vaultId, params.query);
    });

final vaultsProvider = FutureProvider<List<Vault>>((ref) async {
  return await Data.vaults.list();
});

final vaultDetailProvider = FutureProvider.family<Vault, String>((
  ref,
  id,
) async {
  return await Data.vaults.get(id);
});
