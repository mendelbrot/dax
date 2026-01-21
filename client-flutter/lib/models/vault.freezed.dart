// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Vault _$VaultFromJson(Map<String, dynamic> json) {
  return _Vault.fromJson(json);
}

/// @nodoc
mixin _$Vault {
  @IdConverter()
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  Map<String, dynamic>? get settings => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @IdConverter()
  @JsonKey(name: 'owner_id')
  String? get ownerId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VaultCopyWith<Vault> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaultCopyWith<$Res> {
  factory $VaultCopyWith(Vault value, $Res Function(Vault) then) =
      _$VaultCopyWithImpl<$Res, Vault>;
  @useResult
  $Res call(
      {@IdConverter() String? id,
      String? name,
      Map<String, dynamic>? settings,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @IdConverter() @JsonKey(name: 'owner_id') String? ownerId});
}

/// @nodoc
class _$VaultCopyWithImpl<$Res, $Val extends Vault>
    implements $VaultCopyWith<$Res> {
  _$VaultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? settings = freezed,
    Object? createdAt = freezed,
    Object? ownerId = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VaultImplCopyWith<$Res> implements $VaultCopyWith<$Res> {
  factory _$$VaultImplCopyWith(
          _$VaultImpl value, $Res Function(_$VaultImpl) then) =
      __$$VaultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@IdConverter() String? id,
      String? name,
      Map<String, dynamic>? settings,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @IdConverter() @JsonKey(name: 'owner_id') String? ownerId});
}

/// @nodoc
class __$$VaultImplCopyWithImpl<$Res>
    extends _$VaultCopyWithImpl<$Res, _$VaultImpl>
    implements _$$VaultImplCopyWith<$Res> {
  __$$VaultImplCopyWithImpl(
      _$VaultImpl _value, $Res Function(_$VaultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? settings = freezed,
    Object? createdAt = freezed,
    Object? ownerId = freezed,
  }) {
    return _then(_$VaultImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      settings: freezed == settings
          ? _value._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VaultImpl implements _Vault {
  const _$VaultImpl(
      {@IdConverter() this.id,
      this.name,
      final Map<String, dynamic>? settings,
      @JsonKey(name: 'created_at') this.createdAt,
      @IdConverter() @JsonKey(name: 'owner_id') this.ownerId})
      : _settings = settings;

  factory _$VaultImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaultImplFromJson(json);

  @override
  @IdConverter()
  final String? id;
  @override
  final String? name;
  final Map<String, dynamic>? _settings;
  @override
  Map<String, dynamic>? get settings {
    final value = _settings;
    if (value == null) return null;
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @IdConverter()
  @JsonKey(name: 'owner_id')
  final String? ownerId;

  @override
  String toString() {
    return 'Vault(id: $id, name: $name, settings: $settings, createdAt: $createdAt, ownerId: $ownerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._settings, _settings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name,
      const DeepCollectionEquality().hash(_settings), createdAt, ownerId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VaultImplCopyWith<_$VaultImpl> get copyWith =>
      __$$VaultImplCopyWithImpl<_$VaultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaultImplToJson(
      this,
    );
  }
}

abstract class _Vault implements Vault {
  const factory _Vault(
          {@IdConverter() final String? id,
          final String? name,
          final Map<String, dynamic>? settings,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @IdConverter() @JsonKey(name: 'owner_id') final String? ownerId}) =
      _$VaultImpl;

  factory _Vault.fromJson(Map<String, dynamic> json) = _$VaultImpl.fromJson;

  @override
  @IdConverter()
  String? get id;
  @override
  String? get name;
  @override
  Map<String, dynamic>? get settings;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @IdConverter()
  @JsonKey(name: 'owner_id')
  String? get ownerId;
  @override
  @JsonKey(ignore: true)
  _$$VaultImplCopyWith<_$VaultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
