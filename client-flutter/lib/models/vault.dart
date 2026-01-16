class Vault {
  final String? id;
  final String name;
  final Map<String, dynamic> settings;
  final DateTime? createdAt;
  final String? ownerId; // Set by database, always exists when reading from DB

  Vault({
    this.id,
    required this.name,
    required this.settings,
    this.createdAt,
    this.ownerId, // Optional - not required when creating, always set by DB
  });

  // Factory constructor to map JSON to Object
  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      ownerId: json['owner_id']?.toString(),
    );
  }

  // Convert to JSON for Supabase SDK
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'settings': settings,
    };
    return json;
  }

  // Create a copy of this Vault with some fields changed
  Vault copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    String? ownerId,
  }) {
    return Vault(
      id: id ?? this.id,
      name: name ?? this.name,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
