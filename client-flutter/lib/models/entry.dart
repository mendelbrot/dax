import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

// Custom converter to handle int/string conversion for IDs
class IdConverter implements JsonConverter<String?, Object?> {
  const IdConverter();

  @override
  String? fromJson(Object? json) => json?.toString();

  @override
  Object? toJson(String? object) => object;
}

@freezed
class Entry with _$Entry {
  const factory Entry({
    @IdConverter() String? id,
    String? heading,
    String? body,
    Map<String, dynamic>? attributes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @IdConverter() @JsonKey(name: 'vault_id') String? vaultId,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}

// Extension methods for database operations
extension EntryJson on Entry {
  /// Convert to JSON for insert operations (excludes id, createdAt, updatedAt)
  Map<String, dynamic> toInsertJson() => {
    if (heading != null) 'heading': heading,
    if (body != null) 'body': body,
    if (attributes != null) 'attributes': attributes,
    if (vaultId != null) 'vault_id': vaultId,
  };

  /// Convert to JSON for update operations (excludes id, createdAt, updatedAt, vaultId)
  Map<String, dynamic> toUpdateJson() => {
    if (heading != null) 'heading': heading,
    if (body != null) 'body': body,
    if (attributes != null) 'attributes': attributes,
  };
}
