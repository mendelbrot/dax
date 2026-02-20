import 'package:dax/shared/models/base_model.dart';

class Entry extends BaseModel{
  final int? id;
  final String? heading;
  final String? body;
  final Map<String, dynamic>? attributes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? vaultId;

  Entry({
    this.id,
    this.heading,
    this.body,
    this.attributes,
    this.createdAt,
    this.updatedAt,
    this.vaultId,
  });

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int?,
      heading: map['heading'] as String?,
      body: map['body'] as String?,
      attributes: map['attributes'] != null
          ? Map<String, dynamic>.from(map['attributes'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      vaultId: map['vault_id'] as int?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (heading != null) map['heading'] = heading;
    if (body != null) map['body'] = body;
    if (attributes != null) map['attributes'] = attributes;
    if (vaultId != null) map['vault_id'] = vaultId;

    return map;
  }

  Entry copyWith({
    int? id,
    String? heading,
    String? body,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? vaultId,
  }) {
    return Entry(
      id: id ?? this.id,
      heading: heading ?? this.heading,
      body: body ?? this.body,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vaultId: vaultId ?? this.vaultId,
    );
  }
}
