// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return _Entry.fromJson(json);
}

/// @nodoc
mixin _$Entry {
  @IdConverter()
  String? get id => throw _privateConstructorUsedError;
  String? get heading => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  Map<String, dynamic>? get attributes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @IdConverter()
  @JsonKey(name: 'vault_id')
  String? get vaultId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EntryCopyWith<Entry> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryCopyWith<$Res> {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) then) =
      _$EntryCopyWithImpl<$Res, Entry>;
  @useResult
  $Res call(
      {@IdConverter() String? id,
      String? heading,
      String? body,
      Map<String, dynamic>? attributes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @IdConverter() @JsonKey(name: 'vault_id') String? vaultId});
}

/// @nodoc
class _$EntryCopyWithImpl<$Res, $Val extends Entry>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? heading = freezed,
    Object? body = freezed,
    Object? attributes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vaultId = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      attributes: freezed == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vaultId: freezed == vaultId
          ? _value.vaultId
          : vaultId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntryImplCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$$EntryImplCopyWith(
          _$EntryImpl value, $Res Function(_$EntryImpl) then) =
      __$$EntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@IdConverter() String? id,
      String? heading,
      String? body,
      Map<String, dynamic>? attributes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @IdConverter() @JsonKey(name: 'vault_id') String? vaultId});
}

/// @nodoc
class __$$EntryImplCopyWithImpl<$Res>
    extends _$EntryCopyWithImpl<$Res, _$EntryImpl>
    implements _$$EntryImplCopyWith<$Res> {
  __$$EntryImplCopyWithImpl(
      _$EntryImpl _value, $Res Function(_$EntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? heading = freezed,
    Object? body = freezed,
    Object? attributes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vaultId = freezed,
  }) {
    return _then(_$EntryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      attributes: freezed == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vaultId: freezed == vaultId
          ? _value.vaultId
          : vaultId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntryImpl implements _Entry {
  const _$EntryImpl(
      {@IdConverter() this.id,
      this.heading,
      this.body,
      final Map<String, dynamic>? attributes,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @IdConverter() @JsonKey(name: 'vault_id') this.vaultId})
      : _attributes = attributes;

  factory _$EntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntryImplFromJson(json);

  @override
  @IdConverter()
  final String? id;
  @override
  final String? heading;
  @override
  final String? body;
  final Map<String, dynamic>? _attributes;
  @override
  Map<String, dynamic>? get attributes {
    final value = _attributes;
    if (value == null) return null;
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @IdConverter()
  @JsonKey(name: 'vault_id')
  final String? vaultId;

  @override
  String toString() {
    return 'Entry(id: $id, heading: $heading, body: $body, attributes: $attributes, createdAt: $createdAt, updatedAt: $updatedAt, vaultId: $vaultId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.body, body) || other.body == body) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.vaultId, vaultId) || other.vaultId == vaultId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      heading,
      body,
      const DeepCollectionEquality().hash(_attributes),
      createdAt,
      updatedAt,
      vaultId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryImplCopyWith<_$EntryImpl> get copyWith =>
      __$$EntryImplCopyWithImpl<_$EntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntryImplToJson(
      this,
    );
  }
}

abstract class _Entry implements Entry {
  const factory _Entry(
          {@IdConverter() final String? id,
          final String? heading,
          final String? body,
          final Map<String, dynamic>? attributes,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt,
          @IdConverter() @JsonKey(name: 'vault_id') final String? vaultId}) =
      _$EntryImpl;

  factory _Entry.fromJson(Map<String, dynamic> json) = _$EntryImpl.fromJson;

  @override
  @IdConverter()
  String? get id;
  @override
  String? get heading;
  @override
  String? get body;
  @override
  Map<String, dynamic>? get attributes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @IdConverter()
  @JsonKey(name: 'vault_id')
  String? get vaultId;
  @override
  @JsonKey(ignore: true)
  _$$EntryImplCopyWith<_$EntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
