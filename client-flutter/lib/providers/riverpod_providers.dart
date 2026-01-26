import 'package:dax/models/entry.dart';
import 'package:dax/models/vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/services/data_service.dart';

final entriesProvider = FutureProvider.family<List<Entry>, String>((ref, vaultId) async {
  return await Data.entries.list(
    QueryOptions(
      filters: {'vault_id': vaultId},
      sortBy: 'updated_at',
      ascending: false,
    ),
  );
});

final vaultsProvider = FutureProvider<List<Vault>>((ref) async {
  return await Data.vaults.list();
});

final vaultDetailProvider = FutureProvider.family<Vault, String>((ref, id) async {
  return await Data.vaults.get(id);
});
