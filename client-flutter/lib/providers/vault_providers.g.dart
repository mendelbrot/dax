// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$createVaultHash() => r'c6ca1c066adc453c327979ed07a8a48ff0b34cb4';

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

/// Provider for creating a new vault
///
/// Copied from [createVault].
@ProviderFor(createVault)
const createVaultProvider = CreateVaultFamily();

/// Provider for creating a new vault
///
/// Copied from [createVault].
class CreateVaultFamily extends Family<AsyncValue<Vault>> {
  /// Provider for creating a new vault
  ///
  /// Copied from [createVault].
  const CreateVaultFamily();

  /// Provider for creating a new vault
  ///
  /// Copied from [createVault].
  CreateVaultProvider call(
    String name,
    Map<String, dynamic> settings,
  ) {
    return CreateVaultProvider(
      name,
      settings,
    );
  }

  @override
  CreateVaultProvider getProviderOverride(
    covariant CreateVaultProvider provider,
  ) {
    return call(
      provider.name,
      provider.settings,
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
  String? get name => r'createVaultProvider';
}

/// Provider for creating a new vault
///
/// Copied from [createVault].
class CreateVaultProvider extends AutoDisposeFutureProvider<Vault> {
  /// Provider for creating a new vault
  ///
  /// Copied from [createVault].
  CreateVaultProvider(
    String name,
    Map<String, dynamic> settings,
  ) : this._internal(
          (ref) => createVault(
            ref as CreateVaultRef,
            name,
            settings,
          ),
          from: createVaultProvider,
          name: r'createVaultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createVaultHash,
          dependencies: CreateVaultFamily._dependencies,
          allTransitiveDependencies:
              CreateVaultFamily._allTransitiveDependencies,
          name: name,
          settings: settings,
        );

  CreateVaultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.name,
    required this.settings,
  }) : super.internal();

  final String name;
  final Map<String, dynamic> settings;

  @override
  Override overrideWith(
    FutureOr<Vault> Function(CreateVaultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreateVaultProvider._internal(
        (ref) => create(ref as CreateVaultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        name: name,
        settings: settings,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Vault> createElement() {
    return _CreateVaultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateVaultProvider &&
        other.name == name &&
        other.settings == settings;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, name.hashCode);
    hash = _SystemHash.combine(hash, settings.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreateVaultRef on AutoDisposeFutureProviderRef<Vault> {
  /// The parameter `name` of this provider.
  String get name;

  /// The parameter `settings` of this provider.
  Map<String, dynamic> get settings;
}

class _CreateVaultProviderElement
    extends AutoDisposeFutureProviderElement<Vault> with CreateVaultRef {
  _CreateVaultProviderElement(super.provider);

  @override
  String get name => (origin as CreateVaultProvider).name;
  @override
  Map<String, dynamic> get settings => (origin as CreateVaultProvider).settings;
}

String _$vaultsHash() => r'd2b9a17b2174bdbae7c3cbb7c71ff1e006c79139';

/// Provider for listing all vaults
///
/// Copied from [Vaults].
@ProviderFor(Vaults)
final vaultsProvider =
    AutoDisposeAsyncNotifierProvider<Vaults, List<Vault>>.internal(
  Vaults.new,
  name: r'vaultsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$vaultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Vaults = AutoDisposeAsyncNotifier<List<Vault>>;
String _$vaultDetailHash() => r'6d889aa09d3c2c4644197334fc7437c559e4650e';

abstract class _$VaultDetail extends BuildlessAutoDisposeAsyncNotifier<Vault> {
  late final String vaultId;

  FutureOr<Vault> build(
    String vaultId,
  );
}

/// Provider for a single vault (supports mutations)
///
/// Copied from [VaultDetail].
@ProviderFor(VaultDetail)
const vaultDetailProvider = VaultDetailFamily();

/// Provider for a single vault (supports mutations)
///
/// Copied from [VaultDetail].
class VaultDetailFamily extends Family<AsyncValue<Vault>> {
  /// Provider for a single vault (supports mutations)
  ///
  /// Copied from [VaultDetail].
  const VaultDetailFamily();

  /// Provider for a single vault (supports mutations)
  ///
  /// Copied from [VaultDetail].
  VaultDetailProvider call(
    String vaultId,
  ) {
    return VaultDetailProvider(
      vaultId,
    );
  }

  @override
  VaultDetailProvider getProviderOverride(
    covariant VaultDetailProvider provider,
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
  String? get name => r'vaultDetailProvider';
}

/// Provider for a single vault (supports mutations)
///
/// Copied from [VaultDetail].
class VaultDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<VaultDetail, Vault> {
  /// Provider for a single vault (supports mutations)
  ///
  /// Copied from [VaultDetail].
  VaultDetailProvider(
    String vaultId,
  ) : this._internal(
          () => VaultDetail()..vaultId = vaultId,
          from: vaultDetailProvider,
          name: r'vaultDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaultDetailHash,
          dependencies: VaultDetailFamily._dependencies,
          allTransitiveDependencies:
              VaultDetailFamily._allTransitiveDependencies,
          vaultId: vaultId,
        );

  VaultDetailProvider._internal(
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
  FutureOr<Vault> runNotifierBuild(
    covariant VaultDetail notifier,
  ) {
    return notifier.build(
      vaultId,
    );
  }

  @override
  Override overrideWith(VaultDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: VaultDetailProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<VaultDetail, Vault> createElement() {
    return _VaultDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaultDetailProvider && other.vaultId == vaultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vaultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaultDetailRef on AutoDisposeAsyncNotifierProviderRef<Vault> {
  /// The parameter `vaultId` of this provider.
  String get vaultId;
}

class _VaultDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<VaultDetail, Vault>
    with VaultDetailRef {
  _VaultDetailProviderElement(super.provider);

  @override
  String get vaultId => (origin as VaultDetailProvider).vaultId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
