# Plan 1: Setup & Dependencies

**Objective:** Add all necessary dependencies and configure build tools for Riverpod and Freezed.

**Risk Level:** Low  
**Estimated Time:** 1-2 hours

---

## Checklist

- [ ] Update `pubspec.yaml` with new dependencies
- [ ] Create `build.yaml` configuration file
- [ ] Update `analysis_options.yaml` for generated code
- [ ] Add `ProviderScope` wrapper in `main.dart`
- [ ] Run `flutter pub get` to install dependencies
- [ ] Verify build succeeds

---

## Step 1: Update pubspec.yaml

Add the following dependencies to `client-flutter/pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies ...
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  # ... existing dev_dependencies ...
  riverpod_generator: ^2.3.11
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  build_runner: ^2.4.8
  riverpod_lint: ^2.3.10
```

> [!NOTE]
> The `provider` package can remain temporarily for backwards compatibility with `AuthProvider`.

---

## Step 2: Create build.yaml

Create `client-flutter/build.yaml`:

```yaml
targets:
  $default:
    builders:
      riverpod_generator:
        generate_for:
          - lib/**
      json_serializable:
        options:
          any_map: false
          checked: false
```

---

## Step 3: Update analysis_options.yaml

Update `client-flutter/analysis_options.yaml` to include Riverpod lint rules and ignore generated files:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  plugins:
    - custom_lint

linter:
  rules:
    # ... existing rules ...

custom_lint:
  rules:
    - riverpod_final_provider
```

---

## Step 4: Add ProviderScope in main.dart

Wrap the app with `ProviderScope` while keeping existing `ChangeNotifierProvider`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In main():
runApp(
  const ProviderScope(
    child: MyApp(),
  ),
);
```

The existing `ChangeNotifierProvider.value()` wrapper remains inside `_MyAppState.build()` until Phase 4 (Auth migration).

---

## Step 5: Verify Setup

Run these commands:

```bash
cd client-flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## Success Criteria

- [ ] All dependencies resolve without conflicts
- [ ] `flutter analyze` passes
- [ ] App runs without errors
- [ ] No changes to existing functionality
