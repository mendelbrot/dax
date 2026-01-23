import 'package:dax/models/vault.dart';
import 'package:dax/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaultSettingsPage extends StatefulWidget {
  final String vaultId;

  const VaultSettingsPage({super.key, required this.vaultId});

  @override
  State<VaultSettingsPage> createState() => _VaultSettingsPageState();
}

class _VaultSettingsPageState extends State<VaultSettingsPage> {
  Vault? _vault;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVault();
  }

  Future<void> _loadVault() async {
    try {
      final vault = await Data.vaults.get(widget.vaultId);
      if (mounted) {
        setState(() {
          _vault = vault;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateVaultName(String newName) async {
    if (_vault == null) return;

    try {
      final updatedVault = await Data.vaults.update(
        widget.vaultId,
        _vault!.copyWith(name: newName),
      );
      if (mounted) {
        setState(() {
          _vault = updatedVault;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vault name updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating name: $e')));
      }
    }
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _vault?.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Vault Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Vault Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                _updateVaultName(newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVault() async {
    try {
      await Data.vaults.delete(widget.vaultId);
      if (mounted) {
        context.go('/'); // Navigate to home after deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting vault: $e')));
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vault'),
        content: const Text(
          'Are you sure you want to delete this vault? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteVault();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vault Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : ListView(
              children: [
                ListTile(
                  // Streamlined approach: Display name with an edit icon
                  title: Text(
                    _vault?.name ?? 'Untitled Vault',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showEditNameDialog,
                    tooltip: 'Edit Name',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Vault',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _showDeleteConfirmationDialog,
                ),
              ],
            ),
    );
  }
}
