import 'package:dax/core/models/base_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dax/features/notebook/domain/models/vault.dart';
import 'package:dax/features/notebook/domain/models/entry.dart';
import 'package:uuid/uuid.dart';

// 1. Generic Query Options (replaces EntryQueryOptions)
class QueryOptions {
  final bool ascending;
  final String? sortBy;
  final int? limit;
  final int? offset;
  // Generic filters: map of column_name -> value
  final Map<String, dynamic>? filters;

  const QueryOptions({
    this.ascending = true,
    this.sortBy,
    this.limit,
    this.offset,
    this.filters,
  });
}

// 2. The Abstract Base Repository
// T is the model type (e.g., Vault, Entry)
// ID is the type of the primary key (e.g., int, String)
abstract class BaseDataService<T extends BaseModel, ID> {
  final SupabaseClient client;
  final String tableName;
  final String? transientClientId;

  // We need a function to convert JSON back to the Model T
  final T Function(Map<String, dynamic>) fromMap;

  BaseDataService({
    required this.client,
    required this.tableName,
    required this.fromMap,
    this.transientClientId,
  });

  // Generic List with dynamic query building
  Future<List<T>> list([QueryOptions? options]) async {
    dynamic query = client.from(tableName).select();

    if (options != null) {
      // Apply Filters
      if (options.filters != null) {
        options.filters!.forEach((key, value) {
          // You can add logic here to handle nulls or specific operators
          query = query.eq(key, value);
        });
      }

      // Apply Sorting
      if (options.sortBy != null) {
        query = query.order(options.sortBy!, ascending: options.ascending);
      }

      // Apply Pagination
      if (options.limit != null) {
        query = query.limit(options.limit!);
      }

      // Note: Supabase range is inclusive
      if (options.offset != null && options.limit != null) {
        query = query.range(
          options.offset!,
          options.offset! + options.limit! - 1,
        );
      }
    }

    final List<dynamic> response = await query;
    return response
        .map((json) => fromMap(json as Map<String, dynamic>))
        .toList();
  }

  // Generic Get
  Future<T> get(ID id) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('id', id as Object)
        .single();
    return fromMap(response);
  }

  // Generic Create
  // We assume the model has a toMap() method, or we pass a map directly
  Future<T> create(T item) async {
    final data = item.toMap();
    if (transientClientId != null) {
      data['transient_client_id'] = transientClientId;
    }
    final response = await client
        .from(tableName)
        .insert(data)
        .select()
        .single();
    return fromMap(response);
  }

  // Generic Update
  Future<T> update(ID id, T item) async {
    final data = item.toMap();
    if (transientClientId != null) {
      data['transient_client_id'] = transientClientId;
    }
    final response = await client
        .from(tableName)
        .update(data)
        .eq('id', id as Object)
        .select()
        .single();
    return fromMap(response);
  }

  // Generic Delete
  Future<void> delete(ID id) async {
    await client.from(tableName).delete().eq('id', id as Object);
  }
}

// Vault Service
class VaultService extends BaseDataService<Vault, int> {
  VaultService(SupabaseClient client, String? transientClientId)
    : super(
        client: client,
        tableName: 'dax_vault',
        fromMap: Vault.fromMap, // Pass the factory method
        transientClientId: transientClientId,
      );

  // You can still add specific methods here if needed
  // Future<void> archiveVault(String id) async {
  //   await update(id, {'is_archived': true});
  // }
}

// Entry Service
class EntryService extends BaseDataService<Entry, int> {
  EntryService(SupabaseClient client, String? transientClientId)
    : super(client: client, tableName: 'dax_entry', fromMap: Entry.fromMap, transientClientId: transientClientId);

  // Search entries by heading and body using trigram and full-text search
  Future<List<Entry>> searchEntries(int vaultId, String query) async {
    final trimmedQuery = query.trim();

    // Use the PostgreSQL RPC function for optimized search
    // This leverages trigram index on heading and tsvector index on body
    final response = await client.rpc(
      'search_entries',
      params: {
        'p_vault_id': vaultId,
        'p_query': trimmedQuery,
      },
    );

    return (response as List)
        .map((json) => fromMap(json as Map<String, dynamic>))
        .toList();
  }
}

// Main Data service
class Data {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final String transientClientId = const Uuid().v4();

  // Nested service properties
  static VaultService get vaults => VaultService(_supabase, transientClientId);
  static EntryService get entries => EntryService(_supabase, transientClientId);
}

// UI helper functions
