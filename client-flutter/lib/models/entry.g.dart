// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntryImpl _$$EntryImplFromJson(Map<String, dynamic> json) => _$EntryImpl(
      id: const IdConverter().fromJson(json['id']),
      heading: json['heading'] as String?,
      body: json['body'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      vaultId: const IdConverter().fromJson(json['vault_id']),
    );

Map<String, dynamic> _$$EntryImplToJson(_$EntryImpl instance) =>
    <String, dynamic>{
      'id': const IdConverter().toJson(instance.id),
      'heading': instance.heading,
      'body': instance.body,
      'attributes': instance.attributes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'vault_id': const IdConverter().toJson(instance.vaultId),
    };
