// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VaultImpl _$$VaultImplFromJson(Map<String, dynamic> json) => _$VaultImpl(
      id: const IdConverter().fromJson(json['id']),
      name: json['name'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      ownerId: const IdConverter().fromJson(json['owner_id']),
    );

Map<String, dynamic> _$$VaultImplToJson(_$VaultImpl instance) =>
    <String, dynamic>{
      'id': const IdConverter().toJson(instance.id),
      'name': instance.name,
      'settings': instance.settings,
      'created_at': instance.createdAt?.toIso8601String(),
      'owner_id': const IdConverter().toJson(instance.ownerId),
    };
