// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$createEntryHash() => r'5eb751a703d29e0a1a9b4428e7b0d72fa5f48bc5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for creating a new entry
///
/// Copied from [createEntry].
@ProviderFor(createEntry)
const createEntryProvider = CreateEntryFamily();

/// Provider for creating a new entry
///
/// Copied from [createEntry].
class CreateEntryFamily extends Family<AsyncValue<Entry>> {
  /// Provider for creating a new entry
  ///
  /// Copied from [createEntry].
  const CreateEntryFamily();

  /// Provider for creating a new entry
  ///
  /// Copied from [createEntry].
  CreateEntryProvider call(
    String vaultId,
    String heading,
  ) {
    return CreateEntryProvider(
      vaultId,
      heading,
    );
  }

  @override
  CreateEntryProvider getProviderOverride(
    covariant CreateEntryProvider provider,
  ) {
    return call(
      provider.vaultId,
      provider.heading,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'createEntryProvider';
}

/// Provider for creating a new entry
///
/// Copied from [createEntry].
class CreateEntryProvider extends AutoDisposeFutureProvider<Entry> {
  /// Provider for creating a new entry
  ///
  /// Copied from [createEntry].
  CreateEntryProvider(
    String vaultId,
    String heading,
  ) : this._internal(
          (ref) => createEntry(
            ref as CreateEntryRef,
            vaultId,
            heading,
          ),
          from: createEntryProvider,
          name: r'createEntryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createEntryHash,
          dependencies: CreateEntryFamily._dependencies,
          allTransitiveDependencies:
              CreateEntryFamily._allTransitiveDependencies,
          vaultId: vaultId,
          heading: heading,
        );

  CreateEntryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vaultId,
    required this.heading,
  }) : super.internal();

  final String vaultId;
  final String heading;

  @override
  Override overrideWith(
    FutureOr<Entry> Function(CreateEntryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreateEntryProvider._internal(
        (ref) => create(ref as CreateEntryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vaultId: vaultId,
        heading: heading,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Entry> createElement() {
    return _CreateEntryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateEntryProvider &&
        other.vaultId == vaultId &&
        other.heading == heading;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vaultId.hashCode);
    hash = _SystemHash.combine(hash, heading.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreateEntryRef on AutoDisposeFutureProviderRef<Entry> {
  /// The parameter `vaultId` of this provider.
  String get vaultId;

  /// The parameter `heading` of this provider.
  String get heading;
}

class _CreateEntryProviderElement
    extends AutoDisposeFutureProviderElement<Entry> with CreateEntryRef {
  _CreateEntryProviderElement(super.provider);

  @override
  String get vaultId => (origin as CreateEntryProvider).vaultId;
  @override
  String get heading => (origin as CreateEntryProvider).heading;
}

String _$entriesHash() => r'edbfe03389865b0c375d0432333a91f0cdd5d633';

abstract class _$Entries
    extends BuildlessAutoDisposeAsyncNotifier<List<Entry>> {
  late final String vaultId;

  FutureOr<List<Entry>> build(
    String vaultId,
  );
}

/// Provider for listing entries in a vault
///
/// Copied from [Entries].
@ProviderFor(Entries)
const entriesProvider = EntriesFamily();

/// Provider for listing entries in a vault
///
/// Copied from [Entries].
class EntriesFamily extends Family<AsyncValue<List<Entry>>> {
  /// Provider for listing entries in a vault
  ///
  /// Copied from [Entries].
  const EntriesFamily();

  /// Provider for listing entries in a vault
  ///
  /// Copied from [Entries].
  EntriesProvider call(
    String vaultId,
  ) {
    return EntriesProvider(
      vaultId,
    );
  }

  @override
  EntriesProvider getProviderOverride(
    covariant EntriesProvider provider,
  ) {
    return call(
      provider.vaultId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'entriesProvider';
}

/// Provider for listing entries in a vault
///
/// Copied from [Entries].
class EntriesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Entries, List<Entry>> {
  /// Provider for listing entries in a vault
  ///
  /// Copied from [Entries].
  EntriesProvider(
    String vaultId,
  ) : this._internal(
          () => Entries()..vaultId = vaultId,
          from: entriesProvider,
          name: r'entriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entriesHash,
          dependencies: EntriesFamily._dependencies,
          allTransitiveDependencies: EntriesFamily._allTransitiveDependencies,
          vaultId: vaultId,
        );

  EntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vaultId,
  }) : super.internal();

  final String vaultId;

  @override
  FutureOr<List<Entry>> runNotifierBuild(
    covariant Entries notifier,
  ) {
    return notifier.build(
      vaultId,
    );
  }

  @override
  Override overrideWith(Entries Function() create) {
    return ProviderOverride(
      origin: this,
      override: EntriesProvider._internal(
        () => create()..vaultId = vaultId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vaultId: vaultId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Entries, List<Entry>>
      createElement() {
    return _EntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntriesProvider && other.vaultId == vaultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vaultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EntriesRef on AutoDisposeAsyncNotifierProviderRef<List<Entry>> {
  /// The parameter `vaultId` of this provider.
  String get vaultId;
}

class _EntriesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Entries, List<Entry>>
    with EntriesRef {
  _EntriesProviderElement(super.provider);

  @override
  String get vaultId => (origin as EntriesProvider).vaultId;
}

String _$entryDetailHash() => r'b3e1d309ea17884e5de70649536711be7b954603';

abstract class _$EntryDetail extends BuildlessAutoDisposeAsyncNotifier<Entry> {
  late final String entryId;

  FutureOr<Entry> build(
    String entryId,
  );
}

/// Provider for a single entry (supports mutations)
///
/// Copied from [EntryDetail].
@ProviderFor(EntryDetail)
const entryDetailProvider = EntryDetailFamily();

/// Provider for a single entry (supports mutations)
///
/// Copied from [EntryDetail].
class EntryDetailFamily extends Family<AsyncValue<Entry>> {
  /// Provider for a single entry (supports mutations)
  ///
  /// Copied from [EntryDetail].
  const EntryDetailFamily();

  /// Provider for a single entry (supports mutations)
  ///
  /// Copied from [EntryDetail].
  EntryDetailProvider call(
    String entryId,
  ) {
    return EntryDetailProvider(
      entryId,
    );
  }

  @override
  EntryDetailProvider getProviderOverride(
    covariant EntryDetailProvider provider,
  ) {
    return call(
      provider.entryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'entryDetailProvider';
}

/// Provider for a single entry (supports mutations)
///
/// Copied from [EntryDetail].
class EntryDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<EntryDetail, Entry> {
  /// Provider for a single entry (supports mutations)
  ///
  /// Copied from [EntryDetail].
  EntryDetailProvider(
    String entryId,
  ) : this._internal(
          () => EntryDetail()..entryId = entryId,
          from: entryDetailProvider,
          name: r'entryDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entryDetailHash,
          dependencies: EntryDetailFamily._dependencies,
          allTransitiveDependencies:
              EntryDetailFamily._allTransitiveDependencies,
          entryId: entryId,
        );

  EntryDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entryId,
  }) : super.internal();

  final String entryId;

  @override
  FutureOr<Entry> runNotifierBuild(
    covariant EntryDetail notifier,
  ) {
    return notifier.build(
      entryId,
    );
  }

  @override
  Override overrideWith(EntryDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: EntryDetailProvider._internal(
        () => create()..entryId = entryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entryId: entryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<EntryDetail, Entry> createElement() {
    return _EntryDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntryDetailProvider && other.entryId == entryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EntryDetailRef on AutoDisposeAsyncNotifierProviderRef<Entry> {
  /// The parameter `entryId` of this provider.
  String get entryId;
}

class _EntryDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EntryDetail, Entry>
    with EntryDetailRef {
  _EntryDetailProviderElement(super.provider);

  @override
  String get entryId => (origin as EntryDetailProvider).entryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
