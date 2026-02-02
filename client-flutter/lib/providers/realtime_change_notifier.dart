import 'package:dax/providers/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dax/helpers/expiring_set.dart';
import 'package:dax/services/data_service.dart';

final realtimeSyncProvider = Provider<RealtimeSyncService>((ref) {
  return RealtimeSyncService(ref);
});

class RealtimeSyncService {
  final Ref _ref;
  RealtimeSyncService(this._ref);

  // A temporary memory of IDs we deleted locally
  final ExpiringSet<int> _locallyDeletedIds = ExpiringSet<int>();

  // Call this BEFORE you send the delete to Supabase
  void ignoreNextDelete(int id) {
    _locallyDeletedIds.add(id);
  }

  RealtimeChannel? _vaultsChannel;
  RealtimeChannel? _entriesChannel;

  void initialize() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    _vaultsChannel = supabase.channel('public:dax_vault:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'dax_vault',
          callback: (payload) {
            _handleEvent(payload, isVault: true);
          },
        )
        .subscribe();

    _entriesChannel = supabase.channel('public:dax_entry')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'dax_entry',
      callback: (payload) {
        _handleEvent(payload, isVault: false);
      },
    )
    .subscribe();
  }

  void _handleEvent(PostgresChangePayload payload, {required bool isVault}) {
    // 1. DELETE Handling
    if (payload.eventType == PostgresChangeEvent.delete) {
      final oldRecord = payload.oldRecord;
      final deletedId = oldRecord['id'] as int?; 
      
      // Check if WE deleted this
      if (deletedId != null && _locallyDeletedIds.contains(deletedId)) {
        // Echo cancellation: We deleted it, so ignore the notification.
        // We also explicitly remove it from the set now that we've seen the echo.
        _locallyDeletedIds.remove(deletedId);
        return; 
      }
    } 
    // 2. INSERT / UPDATE Handling
    else {
      final newRecord = payload.newRecord;
      final originId = newRecord['transient_client_id'] as String?;

      // Check if WE modified this
      if (originId == Data.transientClientId) {
         return; // Ignore our own echo
      }
    }

    // 3. Invalidation Logic (if we reached here, it's a remote change)
    if (isVault) {
       _ref.invalidate(vaultsProvider);
    } else {
       // For entries, we try to invalidate just the specific vault list
       // But 'oldRecord' for DELETE might only have ID if REPLICA IDENTITY is not FULL/Index
       // However, we set up a custom index including vault_id.
       final record = payload.eventType == PostgresChangeEvent.delete
          ? payload.oldRecord
          : payload.newRecord;
       
       final vaultId = record['vault_id'];
       if (vaultId != null) {
          _ref.invalidate(entriesProvider(vaultId as int));
       }
    }
  }

  void dispose() {
    if (_vaultsChannel != null) Supabase.instance.client.removeChannel(_vaultsChannel!);
    if (_entriesChannel != null) Supabase.instance.client.removeChannel(_entriesChannel!);
    _locallyDeletedIds.dispose();
  }
}