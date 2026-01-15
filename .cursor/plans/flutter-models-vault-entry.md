---
name: flutter-models-vault-entry
status: completed
created: 2026-01-15
overview: Create a models folder in the Flutter app and add Vault and Entry model classes based on the database schema, using a pragmatic approach for field naming and timestamp handling.
---

# Flutter Models: Vault and Entry

Create model classes for type-safe data handling from Supabase in the Flutter app.

## Database Schema Reference

Based on `/supabase/schemas/02_tables.sql`:

**dax_vault table:**

- `id` (bigint, primary key)
- `name` (varchar(255), not null)
- `settings` (jsonb, not null)
- `created_at` (timestamp with time zone, not null)
- `owner_id` (uuid, not null)

**dax_entry table:**

- `id` (bigint, primary key)
- `heading` (varchar(255), not null)
- `body` (text, not null)
- `attributes` (jsonb, not null)
- `created_at` (timestamp with time zone, not null)
- `updated_at` (timestamp with time zone, not null)
- `vault_id` (bigint, not null, foreign key)

## Implementation

### 1. Create models directory

- Create `/client-flutter/lib/models/` directory

### 2. Create Vault model (`/client-flutter/lib/models/vault.dart`)

- Define `Vault` class with camelCase fields:
- `id`: String
- `name`: String
- `settings`: Map<String, dynamic>
- `createdAt`: DateTime
- `ownerId`: String
- Add required constructor with all fields
- Add `fromJson` factory constructor:
- Map `id` from `json['id'].toString()`
- Map `name` from `json['name']` (with null fallback to empty string)
- Map `settings` from `json['settings'] as Map<String, dynamic>? ?? {}`
- Map `createdAt` from `DateTime.parse(json['created_at'])` (or tryParse with fallback)
- Map `ownerId` from `json['owner_id'].toString()`

### 3. Create Entry model (`/client-flutter/lib/models/entry.dart`)

- Define `Entry` class with camelCase fields:
- `id`: String
- `heading`: String
- `body`: String
- `attributes`: Map<String, dynamic>
- `createdAt`: DateTime
- `updatedAt`: DateTime
- `vaultId`: String
- Add required constructor with all fields
- Add `fromJson` factory constructor:
- Map `id` from `json['id'].toString()`
- Map `heading` from `json['heading'] ?? ''`
- Map `body` from `json['body'] ?? ''`
- Map `attributes` from `json['attributes'] as Map<String, dynamic>? ?? {}`
- Map `createdAt` from `DateTime.parse(json['created_at'])` (or tryParse with fallback)
- Map `updatedAt` from `DateTime.parse(json['updated_at'])` (or tryParse with fallback)
- Map `vaultId` from `json['vault_id'].toString()`

## Type Mappings

- `bigint` → `String` (as shown in Todo example)
- `varchar(255)` / `text` → `String`
- `jsonb` → `Map<String, dynamic>`
- `timestamp with time zone` → `DateTime`
- `uuid` → `String`

## Implementation Details

### Field Naming Convention

- **Dart fields**: Use camelCase (createdAt, ownerId, vaultId) - idiomatic Dart style
- **JSON mapping**: Supabase returns snake_case keys (created_at, owner_id, vault_id) in JSON
- Map from snake_case JSON keys to camelCase Dart fields in `fromJson`

### Timestamp Handling

- Supabase returns timestamps as ISO 8601 strings (e.g., "2024-01-15T10:30:00Z")
- Parse using `DateTime.parse()` for required fields (schema has NOT NULL constraints)
- For safety, use `DateTime.tryParse()` with fallback to current time, or throw descriptive error

### ID Handling

- Use `String` type for bigint IDs (safer for large numbers, avoids precision issues)
- Convert from JSON: `json['id'].toString()` handles both string and numeric JSON values

### JSONB Fields

- `settings` and `attributes` are jsonb → `Map<String, dynamic>` in Dart
- Handle nulls: Use `json['settings'] as Map<String, dynamic>? ?? {}` for defaults
- Cast explicitly: `json['settings'] as Map<String, dynamic>` (schema has NOT NULL, but defensive coding)

### Code Structure

- Use required constructor parameters
- Factory constructor `fromJson` for deserialization
- Handle type conversions and null safety pragmatically
