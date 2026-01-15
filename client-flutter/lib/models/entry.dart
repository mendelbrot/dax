class Entry {
  final String id;
  final String heading;
  final String body;
  final Map<String, dynamic> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String vaultId;

  Entry({
    required this.id,
    required this.heading,
    required this.body,
    required this.attributes,
    required this.createdAt,
    required this.updatedAt,
    required this.vaultId,
  });

  // Factory constructor to map JSON to Object
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'].toString(),
      heading: json['heading'] ?? '',
      body: json['body'] ?? '',
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      vaultId: json['vault_id'].toString(),
    );
  }
}
