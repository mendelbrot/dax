import 'package:dax/models/entry.dart';
import 'package:dax/models/vault.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/data_service.dart';

class VaultPage extends StatefulWidget {
  final String vaultId;

  const VaultPage({super.key, required this.vaultId});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _firstEntryFocusNode = FocusNode();

  bool _isLoading = true;
  String? _errorMessage;
  Vault? _vault;
  List<Entry> _allEntries = [];
  List<Entry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(VaultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vaultId != widget.vaultId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _firstEntryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        Data.vaults.get(widget.vaultId),
        Data.entries.list(
          EntryQueryOptions(
            vaultId: widget.vaultId,
            sortBy: 'updated_at',
            ascending: false,
          ),
        ),
      ]);

      if (mounted) {
        setState(() {
          _vault = results[0] as Vault;
          _allEntries = results[1] as List<Entry>;
          _filteredEntries = _allEntries;
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

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.length < 2) {
        _filteredEntries = _allEntries;
      } else {
        _filteredEntries = _allEntries.where((entry) {
          final h = entry.heading?.toLowerCase() ?? '';
          final b = entry.body?.toLowerCase() ?? '';
          return h.contains(query) || b.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _openEntry(String entryId) async {
    context.go('/vault/${widget.vaultId}/entry/$entryId');
  }

  Future<void> _createEntry() async {
    final text = _searchController.text.trim();

    try {
      final newEntry = await Data.entries.create(
        Entry(heading: text, vaultId: widget.vaultId),
      );

      await _openEntry(newEntry.id!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vault?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              context.go('/vault/${widget.vaultId}/settings');
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                      if (_filteredEntries.isNotEmpty) {
                        _firstEntryFocusNode.requestFocus();
                      }
                    },
                  },
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    onSubmitted: (_) => _createEntry(),
                    decoration: const InputDecoration(
                      hintText: 'Search or create...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                onPressed: _createEntry,
                tooltip: 'Create Note',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _filteredEntries.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.length >= 2
                        ? 'No matches'
                        : 'No entries',
                  ),
                )
              : ListView.separated(
                  itemCount: _filteredEntries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = _filteredEntries[index];
                    final isFirstItem = index == 0;

                    return CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter): () =>
                            _openEntry(entry.id!),

                        if (isFirstItem)
                          const SingleActivator(
                            LogicalKeyboardKey.arrowUp,
                          ): () {
                            _searchFocusNode.requestFocus();
                          },
                      },
                      child: ListTile(
                        focusNode: isFirstItem ? _firstEntryFocusNode : null,
                        title: Text(
                          entry.heading ?? 'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          (entry.body ?? '').split('\n').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _openEntry(entry.id!),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
