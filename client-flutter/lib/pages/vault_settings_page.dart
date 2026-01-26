import 'package:dax/helpers/data_ui_helpers.dart';
import 'package:dax/providers/riverpod_providers.dart';
import 'package:dax/helpers/error_handling_helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VaultSettingsPage extends ConsumerStatefulWidget {
  final String vaultId;

  const VaultSettingsPage({super.key, required this.vaultId});

  @override
  ConsumerState<VaultSettingsPage> createState() => _VaultSettingsPageState();
}

class _VaultSettingsPageState extends ConsumerState<VaultSettingsPage> {
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUpdateNameDialog() {
    final vaultNameController = TextEditingController();

    Future<void> onSubmit() async {
      final Result(:isSuccess, :message) = await updateVaultName(
        widget.vaultId,
        vaultNameController.text,
      );

      if (mounted) {
        _showSnackBar(message);
      }

      if (isSuccess && context.mounted) {
        ref.invalidate(vaultDetailProvider(widget.vaultId));
        ref.invalidate(vaultsProvider);
        Navigator.of(context).pop();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit vault name'),
          content: TextField(
            controller: vaultNameController,
            decoration: InputDecoration(
              labelText: 'Vault name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) => onSubmit(),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text('Cancel'),
            ),
            TextButton(onPressed: onSubmit, child: Text('Save')),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    Future<void> onSubmit() async {
      final Result(:isSuccess, :message) = await deleteVault(widget.vaultId);

      if (mounted) {
        _showSnackBar(message);
      }

      if (isSuccess && context.mounted) {
        ref.invalidate(vaultDetailProvider(widget.vaultId));
        ref.invalidate(vaultsProvider);
        Navigator.of(context).pop();
        context.go('/');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete vault'),
          content: Text(
            'Are you sure you want to delete this vault? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: Navigator.of(context).pop,
              child: Text('Cancel'),
            ),
            TextButton(onPressed: onSubmit, child: Text('Delete')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultDetailAsync = ref.watch(vaultDetailProvider(widget.vaultId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vault settings')),
      body: switch (vaultDetailAsync) {
        // 2. Data State: List has items
        AsyncValue(value: final vault?) => ListView(
          children: [
            ListTile(
              title: Text(
                vault.name ?? 'Untitled Vault',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showUpdateNameDialog,
                tooltip: 'Edit name',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete vault',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _showDeleteConfirmationDialog,
            ),
          ],
        ),

        // 3. Error State
        AsyncValue(:final error?) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              Text('Error: ${getErrorMessage(error)}'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(vaultDetailProvider(widget.vaultId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        // 4. Loading State
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
