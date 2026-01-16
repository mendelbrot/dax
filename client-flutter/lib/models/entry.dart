class Entry {
  final String? id;
  final String heading;
  final String body;
  final Map<String, dynamic> attributes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String vaultId;

  Entry({
    this.id,
    required this.heading,
    required this.body,
    required this.attributes,
    this.createdAt,
    this.updatedAt,
    required this.vaultId,
  });

  // Factory constructor to map JSON to Object
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id']?.toString(),
      heading: json['heading'] ?? '',
      body: json['body'] ?? '',
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      vaultId: json['vault_id'].toString(),
    );
  }

  // Convert to JSON for Supabase SDK
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'heading': heading,
      'body': body,
      'attributes': attributes,
      'vault_id': vaultId,
    };
    return json;
  }

  // Create a copy of this Entry with some fields changed
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
