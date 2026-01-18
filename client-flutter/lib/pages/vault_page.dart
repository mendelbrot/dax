import 'package:dax/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/data_service.dart';

class VaultPage extends StatefulWidget {
  final String vaultId;

  const VaultPage({super.key, required this.vaultId});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  // Use a key to force FutureBuilder to rebuild when vaults are created
  int _refreshKey = 0;

  Future<List<Entry>> _fetchEntries() async {
    return await Data.entries.list(EntryQueryOptions(vaultId: widget.vaultId));
  }

  void _showCreateEntryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Entry Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) => _createEntry(nameController.text, context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _createEntry(nameController.text, context),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEntry(String name, BuildContext dialogContext) async {

    try {
      await Data.entries.create(Entry(heading: name.trim(), vaultId: widget.vaultId));
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      // Refresh the vault list by incrementing the key
      setState(() {
        _refreshKey++;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Entry created')));
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating entry: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vault: ${widget.vaultId}'),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showCreateEntryDialog,
          tooltip: 'Create New Entry',
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
      body: FutureBuilder<List<Entry>>(
        key: ValueKey(_refreshKey),
        future: _fetchEntries(),
        builder: (context, snapshot) {
          const topDivider = Divider(thickness: 2, height: 2);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                topDivider,
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Column(
              children: [
                topDivider,
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
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
                ),
              ],
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
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
                          'No entries yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final entries = snapshot.data!;

          return Column(
            children: [
              topDivider,
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: entries.length * 2,
                  itemBuilder: (context, index) {
                    // Every odd index is a divider, even indices are vaults
                    if (index.isOdd) {
                      return const Divider(thickness: 2, height: 2);
                    }
                    // Even indices are vaults
                    final vaultIndex = index ~/ 2;
                    final entry = entries[vaultIndex];
                    return ListTile(
                      title: Text(entry.heading ?? ''),
                      onTap: () {
                        context.go('/vault/${widget.vaultId}/entry/${entry.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
