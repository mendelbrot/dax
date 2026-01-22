import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/entry.dart';
import 'supabase_provider.dart';

part 'entry_providers.g.dart';

/// Provider for listing entries in a vault
@riverpod
class Entries extends _$Entries {
  @override
  Future<List<Entry>> build(String vaultId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase
        .from('dax_entry')
        .select()
        .eq('vault_id', vaultId)
        .order('updated_at', ascending: false);
    return (response as List<dynamic>)
        .map((json) => Entry.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Provider for a single entry (supports mutations)
@riverpod
class EntryDetail extends _$EntryDetail {
  @override
  Future<Entry> build(String entryId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final response = await supabase
        .from('dax_entry')
        .select()
        .eq('id', entryId)
        .single();
    return Entry.fromJson(response);
  }

  /// Save entry with optimistic update (no refetch)
  Future<void> saveEntry(Entry updatedEntry) async {
    final supabase = ref.watch(supabaseClientProvider);

    final json = <String, dynamic>{};
    if (updatedEntry.heading != null) json['heading'] = updatedEntry.heading;
    if (updatedEntry.body != null) json['body'] = updatedEntry.body;
    if (updatedEntry.attributes != null) json['attributes'] = updatedEntry.attributes;

    await supabase
        .from('dax_entry')
        .update(json)
        .eq('id', updatedEntry.id!);

    // Update local state directly - NO REFETCH
    state = AsyncValue.data(updatedEntry);

    // Invalidate entries list (lazy - won't refetch until vault page watched)
    if (updatedEntry.vaultId != null) {
      ref.invalidate(entriesProvider(updatedEntry.vaultId!));
    }
  }

  /// Delete entry
  Future<void> deleteEntry(String vaultId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final entryId = state.value!.id!;

    await supabase.from('dax_entry').delete().eq('id', entryId);

    // Invalidate entries list
    ref.invalidate(entriesProvider(vaultId));
  }
}

/// Provider for creating a new entry
@riverpod
Future<Entry> createEntry(
  CreateEntryRef ref,
  String vaultId,
  String heading,
) async {
  final supabase = ref.watch(supabaseClientProvider);

  final json = {
    'heading': heading,
    'vault_id': vaultId,
  };

  final response = await supabase
      .from('dax_entry')
      .insert(json)
      .select()
      .single();

  // Invalidate entries list (lazy refetch)
  ref.invalidate(entriesProvider(vaultId));

  return Entry.fromJson(response);
}