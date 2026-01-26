import 'package:dax/models/base_model.dart';

class Entry extends BaseModel{
  final String? id;
  final String? heading;
  final String? body;
  final Map<String, dynamic>? attributes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? vaultId;

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
      id: map['id']?.toString(),
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
      vaultId: map['vault_id']?.toString(),
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
    String? id,
    String? heading,
    String? body,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vaultId,
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
