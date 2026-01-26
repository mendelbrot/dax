import 'package:dax/models/base_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dax/models/vault.dart';
import 'package:dax/models/entry.dart';
import 'supabase_service.dart';

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
abstract class BaseDataService<T extends BaseModel> {
  final SupabaseClient client;
  final String tableName;
  
  // We need a function to convert JSON back to the Model T
  final T Function(Map<String, dynamic>) fromMap;

  BaseDataService({
    required this.client,
    required this.tableName,
    required this.fromMap,
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
        query = query.order(
          options.sortBy!,
          ascending: options.ascending,
        );
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
    return response.map((json) => fromMap(json as Map<String, dynamic>)).toList();
  }

  // Generic Get
  Future<T> get(String id) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('id', id)
        .single();
    return fromMap(response);
  }

  // Generic Create
  // We assume the model has a toMap() method, or we pass a map directly
  Future<T> create(T item) async {
    final response = await client
        .from(tableName)
        .insert(item.toMap())
        .select()
        .single();
    return fromMap(response);
  }

  // Generic Update
  Future<T> update(String id, T item) async {
    final response = await client
        .from(tableName)
        .update(item.toMap())
        .eq('id', id)
        .select()
        .single();
    return fromMap(response);
  }

  // Generic Delete
  Future<void> delete(String id) async {
    await client.from(tableName).delete().eq('id', id);
  }
}

// Vault Service
class VaultService extends BaseDataService<Vault> {
  VaultService(SupabaseClient client)
      : super(
          client: client,
          tableName: 'dax_vault',
          fromMap: Vault.fromMap, // Pass the factory method
        );

  // You can still add specific methods here if needed
  // Future<void> archiveVault(String id) async {
  //   await update(id, {'is_archived': true});
  // }
}

// Entry Service
class EntryService extends BaseDataService<Entry> {
  EntryService(SupabaseClient client)
      : super(
          client: client,
          tableName: 'dax_entry',
          fromMap: Entry.fromMap,
        );

  // Search entries by heading and body
  Future<List<Entry>> searchEntries(String vaultId, String query) async {
    final trimmedQuery = query.trim();
    
    final response = await client
        .from(tableName)
        .select()
        .eq('vault_id', vaultId)
        .or('heading.ilike.%$trimmedQuery%,body.ilike.%$trimmedQuery%')
        .order('updated_at', ascending: false);
    
    return (response as List)
        .map((json) => fromMap(json as Map<String, dynamic>))
        .toList();
  }
}

// Main Data service
class Data {
  static final SupabaseClient _supabase = SupabaseService.client;

  // Nested service properties
  static VaultService get vaults => VaultService(_supabase);
  static EntryService get entries => EntryService(_supabase);
}

// UI helper functions

