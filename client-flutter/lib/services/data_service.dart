import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vault.dart';
import '../models/entry.dart';
import 'supabase_service.dart';

// Query options for entries with sorting and filtering
class EntryQueryOptions {
  final String? vaultId;
  final String? sortBy; // e.g., 'created_at', 'updated_at', 'heading'
  final bool ascending; // true for ascending, false for descending
  final Map<String, dynamic>? filters; // e.g., {'heading': 'test'}
  final int? limit;
  final int? offset;

  const EntryQueryOptions({
    this.vaultId,
    this.sortBy,
    this.ascending = true,
    this.filters,
    this.limit,
    this.offset,
  });
}

// Vault operations handler
class VaultService {
  final SupabaseClient _supabase;

  VaultService(this._supabase);

  Future<List<Vault>> list() async {
    final response = await _supabase.from('dax_vault').select();
    return (response as List<dynamic>)
        .map((json) => Vault.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Vault> get(String id) async {
    final response = await _supabase
        .from('dax_vault')
        .select()
        .eq('id', id)
        .single();
    return Vault.fromJson(response);
  }

  Future<Vault> create(String name, Map<String, dynamic> settings) async {
    final vault = Vault(name: name, settings: settings);
    final response = await _supabase
        .from('dax_vault')
        .insert(vault.toJson())
        .select()
        .single();
    return Vault.fromJson(response);
  }

  Future<Vault> update(Vault vault) async {
    if (vault.id == null) {
      throw ArgumentError('Vault id is required for update');
    }
    final response = await _supabase
        .from('dax_vault')
        .update(vault.toJson())
        .eq('id', vault.id!)
        .select()
        .single();
    return Vault.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _supabase.from('dax_vault').delete().eq('id', id);
  }
}

// Entry operations handler
class EntryService {
  final SupabaseClient _supabase;

  EntryService(this._supabase);

  Future<List<Entry>> list([EntryQueryOptions? options]) async {
    dynamic query = _supabase.from('dax_entry').select();

    // Apply filters
    if (options != null) {
      if (options.vaultId != null) {
        query = query.eq('vault_id', options.vaultId!);
      }

      // Apply custom filters
      if (options.filters != null) {
        options.filters!.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Apply sorting
      if (options.sortBy != null) {
        query = query.order(
          options.sortBy!,
          ascending: options.ascending,
        );
      }

      // Apply pagination
      if (options.limit != null) {
        query = query.limit(options.limit!);
      }
      if (options.offset != null) {
        query = query.range(
          options.offset!,
          options.offset! + (options.limit ?? 10) - 1,
        );
      }
    }

    final response = await query;
    return (response as List<dynamic>)
        .map((json) => Entry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Entry> get(String id) async {
    final response = await _supabase
        .from('dax_entry')
        .select()
        .eq('id', id)
        .single();
    return Entry.fromJson(response);
  }

  Future<Entry> create(Entry entry) async {
    final response = await _supabase
        .from('dax_entry')
        .insert(entry.toJson())
        .select()
        .single();
    return Entry.fromJson(response);
  }

  Future<Entry> update(Entry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Entry id is required for update');
    }
    final response = await _supabase
        .from('dax_entry')
        .update(entry.toJson())
        .eq('id', entry.id!)
        .select()
        .single();
    return Entry.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _supabase.from('dax_entry').delete().eq('id', id);
  }
}

// Main Data service
class Data {
  static final SupabaseClient _supabase = SupabaseService.client;

  // Nested service properties
  static VaultService get vaults => VaultService(_supabase);
  static EntryService get entries => EntryService(_supabase);
}
