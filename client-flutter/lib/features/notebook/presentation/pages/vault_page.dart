import 'dart:async';
import 'package:dax/features/notebook/domain/models/entry.dart';
import 'package:dax/features/notebook/domain/models/data_ui_helpers.dart';
import 'package:dax/shared/utils/format_helper.dart';
import 'package:dax/shared/utils/get_error_message.dart';
import 'package:dax/providers/riverpod_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VaultPage extends ConsumerStatefulWidget {
  final int vaultId;

  const VaultPage({super.key, required this.vaultId});

  @override
  ConsumerState<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends ConsumerState<VaultPage> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _firstEntryFocusNode = FocusNode();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {}); // Triggers rebuild with new search query
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _firstEntryFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openEntry(int entryId) {
    context.go('/vault/${widget.vaultId}/entry/$entryId');
  }

  Future<void> _createEntry() async {
    final text = _searchController.text.trim();

    final Result(:isSuccess, :message, :createdId) = await createEntry(
      widget.vaultId,
      text,
    );

    if (mounted) {
      _showSnackBar(message);
    }

    if (isSuccess && context.mounted) {
      ref.invalidate(entriesProvider(widget.vaultId));
      ref.invalidate(entriesSearchProvider);
      if (createdId != null) {
        _openEntry(createdId as int);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaultDetailAsync = ref.watch(vaultDetailProvider(widget.vaultId));
    final searchQuery = _searchController.text.trim();
    final entriesAsync = searchQuery.length >= 2
        ? ref.watch(
            entriesSearchProvider(
              EntrySearchParams(widget.vaultId, searchQuery),
            ),
          )
        : ref.watch(entriesProvider(widget.vaultId));

    return Scaffold(
      appBar: AppBar(
        title: Text(vaultDetailAsync.value?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/vault/${widget.vaultId}/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: switch (entriesAsync) {
              AsyncValue(value: final entries?) => _buildEntriesList(entries),
              AsyncValue(:final error?) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    Text('Error: ${getErrorMessage(error)}'),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(vaultDetailProvider(widget.vaultId));
                        ref.invalidate(entriesProvider(widget.vaultId));
                        ref.invalidate(entriesSearchProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                  _firstEntryFocusNode.requestFocus();
                },
              },
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                onSubmitted: (_) => _createEntry(),
                decoration: InputDecoration(
                  hintText: 'Search or create...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48.0,
            height: 48.0,
            child: IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: _createEntry,
              tooltip: 'Create Note',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<Entry> entries) {
    final searchQuery = _searchController.text.trim();

    return entries.isEmpty
        ? Center(
            child: Text(searchQuery.length < 2 ? 'No entries' : 'No matches'),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (searchQuery.length < 2)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Recent',
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isFirstItem = index == 0;

                    return CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter): () =>
                            _openEntry(entry.id!),

                        if (isFirstItem)
                          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                            _searchFocusNode.requestFocus();
                          },
                      },
                      child: ListTile(
                        focusNode: isFirstItem ? _firstEntryFocusNode : null,
                        title: Text(
                          entry.heading ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          (entry.body ?? '').split('\n').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: (entry.updatedAt != null || entry.createdAt != null)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    FormatHelper.formatDateString(entry.updatedAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    FormatHelper.formatDateString(entry.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : null,
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
