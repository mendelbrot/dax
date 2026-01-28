import 'package:dax/providers/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final realtimeSyncProvider = Provider<RealtimeSyncService>((ref) {
  return RealtimeSyncService(ref);
});

class RealtimeSyncService {
  final Ref _ref;
  RealtimeSyncService(this._ref);

  // A temporary memory of IDs we deleted locally
  final Set<int> _locallyDeletedIds = {};

  // Call this BEFORE you send the delete to Supabase
  void ignoreNextDelete(int id) {
    _locallyDeletedIds.add(id);
    
    // Cleanup: Remove from set after 5 seconds just to prevent memory leaks
    // (The realtime event should arrive well before then)
    Future.delayed(const Duration(seconds: 5), () {
      _locallyDeletedIds.remove(id);
    });
  }

  RealtimeChannel? _vaultsChannel;
  RealtimeChannel? _entriesChannel;

  void initialize() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    _vaultsChannel = supabase.channel('public:vaults:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vaults',
          callback: (payload) {

            if (payload.eventType == PostgresChangeEvent.delete) {
              final oldRecord = payload.oldRecord;
              final deletedId = oldRecord?['id'] as int?; // Make sure type matches DB
              
              // 1. Check if WE deleted this
              if (deletedId != null && _locallyDeletedIds.contains(deletedId)) {
                print("Ignoring echo for deleted item $deletedId");
                _locallyDeletedIds.remove(deletedId);
                return; // STOP. Do not invalidate.
              }

              // 2. If not us, invalidate the vault
              final vaultId = oldRecord?['vault_id'];
              if (vaultId != null) {
                 _ref.invalidate(entriesProvider(vaultId.toString()));
              }
            }
            // "All of the user's vaults query" needs reloading
            _ref.invalidate(vaultsProvider);
          },
        )
        .subscribe();

    _entriesChannel = supabase.channel('public:dax_entry')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'dax_entry',
      callback: (payload) {
        // 1. Get the data
        // For DELETE, oldRecord has {id, vault_id} (from our index).
        // For INSERT/UPDATE, newRecord has the full row.
        final record = payload.eventType == PostgresChangeEvent.delete
            ? payload.oldRecord
            : payload.newRecord;

        // 2. Extract vault_id
        final vaultId = record['vault_id'].toString(); 
        _ref.invalidate(entriesProvider(vaultId.toString()));
      },
    )
    .subscribe();
  }

  void dispose() {
    Supabase.instance.client.removeChannel(_vaultsChannel!);
    Supabase.instance.client.removeChannel(_entriesChannel!);
  }
}