---
name: Refactor VaultPage with Riverpod
overview: Refactor vault_page.dart to use Riverpod for data fetching, implement the Result pattern for mutations, and apply the established ConsumerStatefulWidget pattern with AsyncValue switch statements.
todos:
  - id: create-entries-provider
    content: Create entries_provider.dart with family provider for vault entries
    status: pending
  - id: add-entry-helpers
    content: Add createEntry, updateEntry, deleteEntry helpers to data_ui_helpers.dart
    status: pending
  - id: convert-widget-class
    content: Convert VaultPage to ConsumerStatefulWidget and remove manual state
    status: pending
  - id: implement-data-loading
    content: Replace _loadData with provider watches and AsyncValue switch
    status: pending
  - id: refactor-create-operation
    content: Update _createEntry to use helper and invalidate providers
    status: pending
  - id: cleanup-ui
    content: Remove const keywords and apply consistent error handling
    status: pending
---

# Refactor VaultPage with Riverpod

## Overview

Transform [`client-flutter/lib/pages/vault_page.dart`](client-flutter/lib/pages/vault_page.dart) from manual state management to Riverpod-based architecture, following the established patterns in [`home_page.dart`](client-flutter/lib/pages/home_page.dart) and [`vault_settings_page.dart`](client-flutter/lib/pages/vault_settings_page.dart).

## Changes Required

### 1. Create Entries Provider

Add a new family provider in a new file [`client-flutter/lib/providers/entries_provider.dart`](client-flutter/lib/providers/entries_provider.dart):

- `FutureProvider.family<List<Entry>, String>` that takes `vaultId` as parameter
- Fetches entries using `Data.entries.list()` with vault_id filter and sorted by updated_at descending

### 2. Add Entry Helper Functions

Extend [`client-flutter/lib/helpers/data_ui_helpers.dart`](client-flutter/lib/helpers/data_ui_helpers.dart) with:

- `createEntry(String vaultId, String heading)` - validates heading, calls Data.entries.create, returns Result
- `updateEntry(String entryId, Entry updates)` - calls Data.entries.update, returns Result  
- `deleteEntry(String entryId)` - calls Data.entries.delete, returns Result

### 3. Refactor VaultPage Widget

Transform [`client-flutter/lib/pages/vault_page.dart`](client-flutter/lib/pages/vault_page.dart):

**Widget Structure:**

- Convert from `StatefulWidget` to `ConsumerStatefulWidget`
- Remove manual state variables: `_isLoading`, `_errorMessage`, `_vault`, `_allEntries`
- Keep `_filteredEntries`, `_searchController`, focus nodes as local UI state

**Data Loading:**

- Replace manual `_loadData()` with `ref.watch(vaultDetailProvider(vaultId))` and `ref.watch(entriesProvider(vaultId))`
- Use switch statement on AsyncValue to handle loading/error/data states
- Client-side search filtering updates `_filteredEntries` from the provider's data

**Create Operation:**

- Update `_createEntry()` to use `createEntry()` helper from data_ui_helpers
- Show snackbar with Result message
- On success: invalidate `entriesProvider(widget.vaultId)` and navigate to entry

**UI Updates:**

- Remove all `const` keywords from Text, Icon, etc.
- Use switch expression for body rendering similar to home_page.dart pattern
- Maintain keyboard shortcuts and search functionality as-is

**Error Handling:**

- Use `getErrorMessage()` helper for consistent error display
- Add retry button that calls `ref.refresh()` on providers

## Implementation Notes

- Search remains local state since it's UI-only filtering on already-loaded data
- Both vault details and entries load in parallel via separate provider watches
- Provider invalidation triggers automatic refetch without manual setState
- The Result pattern provides consistent error handling and user feedback