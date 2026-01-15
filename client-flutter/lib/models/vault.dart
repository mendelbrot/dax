class Vault {
  final String id;
  final String name;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String ownerId;

  Vault({
    required this.id,
    required this.name,
    required this.settings,
    required this.createdAt,
    required this.ownerId,
  });

  // Factory constructor to map JSON to Object
  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      ownerId: json['owner_id'].toString(),
    );
  }
}
