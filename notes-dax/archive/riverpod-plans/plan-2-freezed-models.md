# Plan 2: Convert Models to Freezed

**Objective:** Convert `Entry` and `Vault` models to Freezed with JSON serialization.

**Risk Level:** Low  
**Estimated Time:** 2-3 hours

**Prerequisite:** Plan 1 completed

---

## Checklist

- [ ] Convert `Entry` model to Freezed
- [ ] Convert `Vault` model to Freezed
- [ ] Run code generation
- [ ] Update `data_service.dart` to use `fromJson`/`toJson`
- [ ] Test all CRUD operations still work

---

## Step 1: Convert Entry Model

Replace `client-flutter/lib/models/entry.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class Entry with _$Entry {
  const factory Entry({
    String? id,
    String? heading,
    String? body,
    Map<String, dynamic>? attributes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'vault_id') String? vaultId,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}
```

> [!NOTE]
> Using `@JsonKey(name: 'snake_case')` for database column mapping instead of `@JsonSerializable(fieldRename: FieldRename.snake)` to be explicit about each field.

---

## Step 2: Convert Vault Model

Replace `client-flutter/lib/models/vault.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault.freezed.dart';
part 'vault.g.dart';

@freezed
class Vault with _$Vault {
  const factory Vault({
    String? id,
    String? name,
    Map<String, dynamic>? settings,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'owner_id') String? ownerId,
  }) = _Vault;

  factory Vault.fromJson(Map<String, dynamic> json) => _$VaultFromJson(json);
}
```

---

## Step 3: Run Code Generation

```bash
cd client-flutter
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `entry.freezed.dart` (immutable class with `copyWith`)
- `entry.g.dart` (JSON serialization)
- `vault.freezed.dart`
- `vault.g.dart`

---

## Step 4: Update data_service.dart

Replace all `fromMap` with `fromJson` and `toMap` with `toJson`:

### VaultService changes:

```diff
- .map((json) => Vault.fromMap(json as Map<String, dynamic>))
+ .map((json) => Vault.fromJson(json as Map<String, dynamic>))

- return Vault.fromMap(response);
+ return Vault.fromJson(response);

- .insert(vault.toMap())
+ .insert(vault.toJson())

- .update(vault.toMap())
+ .update(vault.toJson())
```

### EntryService changes:

```diff
- .map((json) => Entry.fromMap(json as Map<String, dynamic>))
+ .map((json) => Entry.fromJson(json as Map<String, dynamic>))

- return Entry.fromMap(response);
+ return Entry.fromJson(response);

- .insert(entry.toMap())
+ .insert(entry.toJson())

- .update(entry.toMap())
+ .update(entry.toJson())
```

---

## Step 5: Handle toJson for Create/Update

Freezed's `toJson` includes all fields including `null` values and read-only fields like `id`, `createdAt`. We need to filter these for insert/update operations.

Add a helper extension or modify the service:

```dart
// In VaultService.create():
final vault = Vault(name: name, settings: settings);
final json = vault.toJson()
  ..removeWhere((key, value) => value == null || key == 'id' || key == 'created_at' || key == 'owner_id');

// In VaultService.update():
final json = vault.toJson()
  ..removeWhere((key, value) => key == 'created_at' || key == 'owner_id');
```

Alternatively, create extension methods:

```dart
extension VaultJson on Vault {
  Map<String, dynamic> toInsertJson() => {
    if (name != null) 'name': name,
    if (settings != null) 'settings': settings,
  };
  
  Map<String, dynamic> toUpdateJson() => {
    if (name != null) 'name': name,
    if (settings != null) 'settings': settings,
  };
}
```

---

## Testing

Test each operation manually:

1. **List vaults** — HomePage loads correctly
2. **Create vault** — New vault appears after refresh
3. **Get vault** — VaultPage loads vault name
4. **Update vault** — VaultSettingsPage name update works
5. **Delete vault** — Vault is removed
6. **List entries** — VaultPage shows entries
7. **Create entry** — New entry navigates correctly
8. **Get entry** — EntryPage loads content
9. **Update entry** — Auto-save works (debounce)
10. **Delete entry** — Entry is removed

---

## Success Criteria

- [ ] Generated files compile without errors
- [ ] All existing CRUD operations work as before
- [ ] No runtime errors
- [ ] `copyWith` works correctly (used in VaultSettingsPage)
