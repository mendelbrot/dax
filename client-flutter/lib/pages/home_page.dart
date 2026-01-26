import 'package:dax/helpers/data_ui_helpers.dart';
import 'package:dax/providers/vaults_provider.dart';
import 'package:dax/helpers/error_handling_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dax/providers/auth_provider.dart';
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

    ;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: vaultNameController,
            decoration: const InputDecoration(
              labelText: 'Vault Name',
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
            TextButton(
              onPressed: onSubmit,
              child: const Text('Save'),
            ),
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
              await context.read<AuthProvider>().signOut();
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
              Icon(
                Icons.folder_open_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No vaults yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // 2. Data State: List has items
        AsyncValue(value: final vaults?) => ListView.separated(
          itemCount: vaults.length,
          separatorBuilder: (context, index) =>
              const Divider(thickness: 2, height: 2),
          itemBuilder: (context, index) {
            final vault = vaults[index];
            return ListTile(
              title: Text(vault.name ?? vault.id.toString()),
              onTap: () => context.go('/vault/${vault.id}'),
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
                onPressed: () => ref.refresh(vaultsProvider),
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
