import 'package:dax/models/vault.dart';
import 'package:dax/services/data_service.dart';
import 'package:dax/helpers/error_handling_helpers.dart';

class Result {
  final bool isSuccess;
  final String message;

  Result(this.isSuccess, this.message);
}

Future<Result> createVault(String name) async {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    return Result(false, 'Vault name cannot be empty');
  }

  try {
    await Data.vaults.create(Vault(name: trimmedName));
    return Result(true, 'Vault created');
  } catch (e) {
    return Result(false, 'Error creating vault: $getErrorMessage(e)');
  }
}
