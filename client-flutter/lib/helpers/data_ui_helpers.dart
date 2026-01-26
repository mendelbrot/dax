import 'package:dax/models/vault.dart';
import 'package:dax/models/entry.dart';
import 'package:dax/services/data_service.dart';
import 'package:dax/helpers/error_handling_helpers.dart';

class Result {
  final bool isSuccess;
  final String message;
  final dynamic data;

  Result(this.isSuccess, this.message, {this.data});
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

Future<Result> updateVaultName(String vaultId, String newName) async {
  final trimmedName = newName.trim();
  if (trimmedName.isEmpty) {
    return Result(false, 'Vault name cannot be empty');
  }

  try {
    await Data.vaults.update(vaultId, Vault(name: trimmedName));
    return Result(true, 'Vault name updated');
  } catch (e) {
    return Result(false, 'Error updating vault: $getErrorMessage(e)');
  }
}

Future<Result> deleteVault(String vaultId) async {
  try {
    await Data.vaults.delete(vaultId);
    return Result(true, 'Vault deleted');
  } catch (e) {
    return Result(false, 'Error deleting vault: $getErrorMessage(e)');
  }
}

Future<Result> createEntry(String vaultId, String heading) async {
  final trimmedHeading = heading.trim();

  try {
    final newEntry = await Data.entries.create(Entry(heading: trimmedHeading, vaultId: vaultId));
    return Result(true, 'Entry created', data: newEntry.id);
  } catch (e) {
    return Result(false, 'Error creating entry: ${getErrorMessage(e)}');
  }
}

Future<Result> updateEntry(String entryId, Entry updates) async {
  try {
    await Data.entries.update(entryId, updates);
    return Result(true, 'Entry updated');
  } catch (e) {
    return Result(false, 'Error updating entry: ${getErrorMessage(e)}');
  }
}

Future<Result> deleteEntry(String entryId) async {
  try {
    await Data.entries.delete(entryId);
    return Result(true, 'Entry deleted');
  } catch (e) {
    return Result(false, 'Error deleting entry: ${getErrorMessage(e)}');
  }
}