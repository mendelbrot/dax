import 'package:dax/features/notebook/domain/models/data_ui_helpers.dart';
import 'package:dax/providers/riverpod_providers.dart';
import 'package:dax/shared/utils/get_error_message.dart';
import 'package:dax/shared/utils/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCreateVaultDialog() {
    final vaultNameController = TextEditingController();

    Future<void> onSubmit() async {
      final Result(:isSuccess, :message) = await createVault(
        vaultNameController.text,
      );

      if (mounted) {
        _showSnackBar(message);
      }

      if (isSuccess && context.mounted) {
        ref.invalidate(vaultsProvider);
        Navigator.of(context).pop();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create vault'),
          content: TextField(
            controller: vaultNameController,
            decoration: const InputDecoration(
              labelText: 'Vault name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) => onSubmit(),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: onSubmit, child: const Text('Save')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultsAsync = ref.watch(vaultsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showCreateVaultDialog,
          tooltip: 'Create new vault',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthHelper.signOut();
            },
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: switch (vaultsAsync) {
        // 1. Data State: Check if the list is empty first
        AsyncValue(value: final vaults?) when vaults.isEmpty => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No vaults yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // 2. Data State: List has items
        AsyncValue(value: final vaults?) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: vaults.length,
          itemBuilder: (context, index) {
            final vault = vaults[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(vault.name ?? vault.id.toString()),
                onTap: () => context.go('/vault/${vault.id}'),
              ),
            );
          },
        ),

        // 3. Error State
        AsyncValue(:final error?) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              Text('Error: ${getErrorMessage(error)}'),
              TextButton(
                onPressed: () => ref.invalidate(vaultsProvider),
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