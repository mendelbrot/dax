import 'package:dax/models/entry.dart';
import 'package:dax/models/vault.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_provider.dart';
import '../services/data_service.dart';

class VaultPage extends StatefulWidget {
  final String vaultId;

  const VaultPage({super.key, required this.vaultId});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  int _refreshKey = 0;

  Future<({Vault vault, List<Entry> entries})> _fetchPageData() async {
    final vaultFuture = Data.vaults.get(widget.vaultId);
    final entriesFuture = Data.entries.list(
      EntryQueryOptions(vaultId: widget.vaultId),
    );

    return (vault: await vaultFuture, entries: await entriesFuture);
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
      await Data.entries.create(
        Entry(heading: name.trim(), vaultId: widget.vaultId),
      );
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
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
    return FutureBuilder(
      key: ValueKey(_refreshKey),
      future: _fetchPageData(),
      builder: (context, snapshot) {
        // --- LOADING STATE ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // --- ERROR STATE ---
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
                    'Error loading data',
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
                    onPressed: () => setState(() => _refreshKey++),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // --- SUCCESS STATE ---
        final data = snapshot.data!;
        return _buildPageContent(data.vault, data.entries);
      },
    );
  }

  /// Helper method to build the main content once data is loaded
  Widget _buildPageContent(Vault vault, List<Entry> entries) {
    const topDivider = Divider(thickness: 2, height: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(vault.name ?? widget.vaultId),
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
      body: entries.isEmpty
          ? Center(
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
            )
          : Column(
              children: [
                topDivider,
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: entries.length * 2,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        return const Divider(thickness: 2, height: 2);
                      }
                      final vaultIndex = index ~/ 2;
                      final entry = entries[vaultIndex];
                      return ListTile(
                        title: Text(entry.heading ?? ''),
                        onTap: () {
                          context.go(
                            '/vault/${widget.vaultId}/entry/${entry.id}',
                          );
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
