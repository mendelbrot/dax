# Architecture Refactoring Analysis

## Context
The project currently suffers from a fragmented data layer:
1.  **`DataService` (SDK Wrapper):** Low-level access to Supabase. Generic and clean.
2.  **`DataUIHelpers` (Mutations):** Standalone functions (`createEntry`, `deleteVault`) that wrap `DataService` logic but lack context (Riverpod Ref).
3.  **`Riverpod Providers` (State/Fetching):** `FutureProvider`s for fetching lists, often invalidated manually by UI code after a Helper function runs.
4.  **UI Logic (Widgets):** Mix of direct `DataService` calls, Helper calls, and Provider invalidations.

## The Problem
*   **Separation of Concerns:** Mutation logic is separated from State logic. This makes optimistic UI updates difficult because the "updater" doesn't know about the "state".
*   **Inconsistency:** Some pages use Helpers, some call `DataService` directly.
*   **Sync Complexity:** Realtime sync requires coordination (e.g., `ignoreNextDelete`). If mutations are scattered, ensuring this logic is consistently applied is error-prone.
*   **Testing:** Static helpers are hard to mock.

## Refactoring Options

### Option 1: The "Controller" Pattern (Recommended)
Consolidate "State" and "Mutation" into a single Riverpod `AsyncNotifier`.

**Structure:**
```dart
@riverpod
class VaultEntries extends _$VaultEntries {
  @override
  Future<List<Entry>> build(int vaultId) async {
    return Data.entries.list(vaultId); // Fetching
  }

  Future<void> addEntry(String heading) async {
    // 1. Optimistic Update (Optional)
    state = AsyncValue.data([...?state.value, tempEntry]);
    
    // 2. Network Call
    final newEntry = await Data.entries.create(...);
    
    // 3. Update State
    ref.invalidateSelf(); // Or manually update list
  }
  
  Future<void> deleteEntry(int id) async {
    // 1. Sync Logic
    ref.read(realtimeSyncProvider).ignoreNextDelete(id);
    
    // 2. Network Call
    await Data.entries.delete(id);
    
    // 3. Update State
    ref.invalidateSelf();
  }
}
```

**Pros:**
*   **Encapsulation:** Fetching + Mutating in one place.
*   **Consistency:** UI only interacts with the Provider.
*   **Testability:** Notifiers can be overridden.

**Cons:**
*   Requires significant boilerplate conversion (switching `FutureProvider` to `AsyncNotifier`).

### Option 2: The "Repository" Pattern + Use Cases
Formalize `DataService` into a Repository Provider, and keep mutations in "Use Case" providers.

**Structure:**
*   `entryRepositoryProvider` (Wraps Supabase)
*   `createEntryProvider` (Function/Class for the action)
*   `entriesProvider` (State)

**Pros:**
*   Clean separation.
*   Good for very large apps.

**Cons:**
*   Overkill for current scale.
*   Still separates Mutation from State.

### Option 3: Standardize on Helpers + Ref (Minimal Change)
Keep `FutureProvider` for state. Update `DataUIHelpers` to accept `WidgetRef` and handle invalidation internally.

**Structure:**
```dart
Future<void> createEntry(WidgetRef ref, int vaultId, String heading) async {
   await Data.entries.create(...);
   ref.invalidate(entriesProvider(vaultId));
}
```

**Pros:**
*   Least effort.
*   Fixes the "UI manually invalidates" issue.

**Cons:**
*   Still separates logic.
*   Harder to do optimistic updates.

## Recommendation
**Adopt Option 1 (AsyncNotifier)** incrementally.

1.  **Phase 1:** Convert `entriesProvider` to `AsyncNotifier`.
    *   Move `createEntry`, `updateEntry`, `deleteEntry` logic into this class.
    *   This centralizes the `RealtimeSync` integration (echo cancellation) into the `deleteEntry` method of the notifier, ensuring it's never missed.
2.  **Phase 2:** Convert `vaultDetailProvider` / `vaultsProvider`.
3.  **Phase 3:** Delete `data_ui_helpers.dart`.

## Folder Structure Impact
This supports a move to "Feature-First":
```
features/
  entries/
    providers/
      entries_notifier.dart (The AsyncNotifier)
    ui/
      entry_page.dart
```
