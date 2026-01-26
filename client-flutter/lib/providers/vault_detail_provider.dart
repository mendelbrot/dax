import 'package:dax/models/vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/services/data_service.dart';

final vaultDetailProvider = FutureProvider.family<Vault, String>((ref, id) async {
  return await Data.vaults.get(id);
});