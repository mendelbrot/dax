class Vault {
  final String? id;
  final String? name;
  final Map<String, dynamic>? settings;
  final DateTime? createdAt;
  final String? ownerId;

  Vault({this.id, this.name, this.settings, this.createdAt, this.ownerId});

  factory Vault.fromMap(Map<String, dynamic> map) {
    return Vault(
      id: map['id']?.toString(),
      name: map['name'] as String?,
      settings: map['settings'] != null
          ? Map<String, dynamic>.from(map['settings'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      ownerId: map['owner_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (name != null) map['name'] = name;
    if (settings != null) map['settings'] = settings;

    return map;
  }

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
