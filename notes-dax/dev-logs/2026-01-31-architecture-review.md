# Log: Architecture Review & Technical Debt

**Date:** 2026-01-31
**Context:** During Realtime Sync implementation

## Raw Input
> While working on realtime sync, i was reminded of some threds that need to be addressed:
> 1. in the frontend models, vault and entry ids are currently represented as strings, but im starting to see that this is a source of confusion. I will want to change this. Instead, i want the frontent to represent ids with the same type as the database (int if they are integer, and string of thet're uuid).
> 2. the entry detais page (where the text editor is) has not been updated to use riverpod providers like the other pages have been, so in some ways it is inconsistent with the rest of the app. This needs to be addressed.
> 3. as discussed, im not currently happy with the folder structure of the app. One problem, is there's a seperation of the data management process in different layers: there's the data service, then there's the data ui helpers, then the riverpod providers. So the data ui helpers are for data mutation and the riverpod providfers are for data fetching, and they both call the data service to interact with the supabase sdk. When i think about it, it makes sense but sometimes i don't clearly remember this, and im not sure of the optimal way of both breaking up these responsibilities horizontally and vertically, and dividing the logic into files/folders in the cleanest way.

## AI Analysis & Next Steps

### 1. ID Type Safety (Technical Debt)
*   **Current State:** Frontend uses `String` for all IDs (Entries, Vaults), but backend uses `bigint` (Entries) and `uuid` (Auth/Vault Owners).
*   **Issue:** Requires frequent casting (`int.parse`, `toString()`) and mismatch in logic (e.g., `RealtimeSyncService` seeing ints vs UI seeing Strings).
*   **Action Item:** Refactor `Entry` model to use `int` for `id` and `vaultId` (if vault ID is int). Verify schema types.
    *   *Note:* `dax_vault.id` is `bigint`. `dax_entry.id` is `bigint`. `dax_entry.vault_id` is `bigint`.
    *   *Plan:* Update Models (`Entry`, `Vault`) to use `int` (or `BigInt` if generic int is insufficient, but Dart `int` is 64-bit so usually fine).

### 2. `EntryPage` Refactoring (Consistency)
*   **Current State:** Uses `StatefulWidget` with local `setState` and direct `Data.entries` calls.
*   **Goal:** Move to `ConsumerStatefulWidget` (already done partialy) but leverage Riverpod for state management (e.g., `EntryNotifier`) instead of manual controllers/state.
*   **Benefit:** Better testing, separation of logic, and easier sync integration.

### 3. Architecture & Folder Structure (Cleanup)
*   **Current Friction:** Confusion between `DataService` (SDK wrapper), `DataUIHelpers` (Mutations), and `Providers` (Fetching).
*   **Analysis:**
    *   **Vertical Slicing:** Group by feature (`features/entries/`, `features/vaults/`) instead of layer (`services/`, `providers/`).
    *   **Unified Layer:** Merge "UI Helpers" and "Providers" into "Controllers" (Riverpod `AsyncNotifier`).
        *   *Fetching:* `build()` method of Notifier.
        *   *Mutations:* Methods on the Notifier (`addEntry`, `deleteEntry`).
    *   **Data Layer:** Keep `DataService` as the "Repository", called by the Notifier.
*   **Action Item:** Create a restructuring plan (e.g., `refactor-architecture.md`) to move towards "Feature-First" architecture with Riverpod Notifiers handling both state and mutations.
