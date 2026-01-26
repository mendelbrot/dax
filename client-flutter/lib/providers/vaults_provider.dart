import 'package:dax/models/vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/services/data_service.dart';

final vaultsProvider = FutureProvider<List<Vault>>((ref) async {
  return await Data.vaults.list();
});