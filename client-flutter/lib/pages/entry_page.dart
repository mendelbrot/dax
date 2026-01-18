import 'package:dax/models/entry.dart';
import 'package:flutter/material.dart';
import '../services/data_service.dart';

class EntryPage extends StatefulWidget {
  final String vaultId;
  final String entryId;

  const EntryPage({super.key, required this.vaultId, required this.entryId});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  int _refreshKey = 0;

  Future<Entry> _fetchData() {
    return Data.entries.get(widget.entryId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Entry>(
      key: ValueKey(_refreshKey),
      future: _fetchData(),
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
                    'Error loading entry',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(snapshot.error.toString()),
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

        final entry = snapshot.data!;
        return _buildPageContent(entry);
      },
    );
  }

  Widget _buildPageContent(Entry entry) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.heading ?? widget.entryId)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Vault ID: ${widget.vaultId}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Entry ID: ${entry.id}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              entry.heading ?? 'No Heading',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
