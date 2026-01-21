import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_provider.dart';
import '../models/vault.dart';
import '../services/data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _refreshKey = 0;

  Future<List<Vault>> _fetchVaults() async {
    return await Data.vaults.list();
  }

  void _showCreateVaultDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Vault Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) => _createVault(nameController.text, context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _createVault(nameController.text, context),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createVault(String name, BuildContext dialogContext) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vault name cannot be empty')),
      );
      return;
    }

    try {
      await Data.vaults.create(name.trim(), {});
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      setState(() {
        _refreshKey++;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vault created')));
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating vault: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vault>>(
      key: ValueKey(_refreshKey),
      future: _fetchVaults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading vaults',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _refreshKey++;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildPageContent(snapshot.data ?? []);
      },
    );
  }

  Widget _buildPageContent(List<Vault> vaults) {
    const topDivider = Divider(thickness: 2, height: 2);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showCreateVaultDialog,
          tooltip: 'Create New Vault',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: vaults.isEmpty
          ? Column(
              children: [
                topDivider,
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vaults yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                topDivider,
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: vaults.length * 2,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        return const Divider(thickness: 2, height: 2);
                      }
                      final vaultIndex = index ~/ 2;
                      final vault = vaults[vaultIndex];
                      return ListTile(
                        title: Text(vault.name ?? vault.id.toString()),
                        onTap: () async {
                          context.go('/vault/${vault.id}');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
