import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault.freezed.dart';
part 'vault.g.dart';

// Custom converter to handle int/string conversion for IDs
class IdConverter implements JsonConverter<String?, Object?> {
  const IdConverter();

  @override
  String? fromJson(Object? json) => json?.toString();

  @override
  Object? toJson(String? object) => object;
}

@freezed
class Vault with _$Vault {
  const factory Vault({
    @IdConverter() String? id,
    String? name,
    Map<String, dynamic>? settings,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @IdConverter() @JsonKey(name: 'owner_id') String? ownerId,
  }) = _Vault;

  factory Vault.fromJson(Map<String, dynamic> json) => _$VaultFromJson(json);
}

// Extension methods for database operations
extension VaultJson on Vault {
  /// Convert to JSON for insert operations (excludes id, createdAt, ownerId)
  Map<String, dynamic> toInsertJson() => {
    if (name != null) 'name': name,
    if (settings != null) 'settings': settings,
  };

  /// Convert to JSON for update operations (excludes id, createdAt, ownerId)
  Map<String, dynamic> toUpdateJson() => {
    if (name != null) 'name': name,
    if (settings != null) 'settings': settings,
  };
}
