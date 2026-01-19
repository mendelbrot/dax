import 'dart:async';
import 'package:dax/models/entry.dart';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'package:flutter/services.dart';

class EntryPage extends StatefulWidget {
  final String vaultId;
  final String entryId;

  const EntryPage({super.key, required this.vaultId, required this.entryId});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late TextEditingController _headingController;
  late TextEditingController _bodyController;
  Timer? _debounce;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController();
    _bodyController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _headingController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final entry = await Data.entries.get(widget.entryId);
      if (mounted) {
        setState(() {
          _headingController.text = entry.heading ?? '';
          _bodyController.text = entry.body ?? '';
          _isLoading = false;
        });

        // Add listeners after initial value is set to avoid triggering auto-save on load
        _headingController.addListener(_onTextChanged);
        _bodyController.addListener(_onTextChanged);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), _saveEntry);
  }

  Future<void> _saveEntry() async {
    try {
      final entry = Entry(
        id: widget.entryId,
        heading: _headingController.text,
        body: _bodyController.text,
      );
      await Data.entries.update(entry);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving entry: $e')));
      }
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Data.entries.delete(widget.entryId);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
        }
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _bodyController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading entry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntry,
            tooltip: 'Delete',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copy',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Border between App Bar and Heading
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _headingController,
              decoration: const InputDecoration(
                hintText: 'Heading',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1,
            ),
          ),
          // Border between Heading and Body
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
