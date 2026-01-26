---
name: Backend Search for VaultPage
overview: Replace frontend search with backend search in VaultPage by extending QueryOptions to support text search, creating a search-aware provider, and removing local filtering state.
todos:
  - id: extend-query-options
    content: Add searchQuery and searchColumns to QueryOptions and update list() method
    status: pending
  - id: update-entries-provider
    content: Create EntriesQuery class and update entriesProvider to use it
    status: pending
  - id: refactor-vault-page-search
    content: Remove local filtering, add debouncing, update to use search-aware provider
    status: pending
  - id: update-provider-invalidations
    content: Update all entriesProvider invalidate calls to use EntriesQuery
    status: pending
---

# Backend Search for VaultPage

## Overview
Move search logic from frontend to backend in [`client-flutter/lib/pages/vault_page.dart`](client-flutter/lib/pages/vault_page.dart) to eliminate local state and leverage database indexing for better performance with large entry lists.

## Changes Required

### 1. Extend QueryOptions for Text Search
Update [`client-flutter/lib/services/data_service.dart`](client-flutter/lib/services/data_service.dart):

**Add search parameter to QueryOptions:**
- Add `String? searchQuery` field to QueryOptions class
- Add `List<String>? searchColumns` field to specify which columns to search (e.g., ['heading', 'body'])

**Update BaseDataService.list() method:**
- After applying filters, check if `searchQuery` is provided and non-empty
- If searchQuery exists, use Supabase `.or()` with `.ilike()` for each searchColumn
- Pattern: `query.or('heading.ilike.%$searchQuery%,body.ilike.%$searchQuery%')`
- This searches across multiple columns with case-insensitive pattern matching

### 2. Create Search-Aware Entries Provider
Update [`client-flutter/lib/providers/entries_provider.dart`](client-flutter/lib/providers/entries_provider.dart):

**Current approach - family with vaultId only:**
```dart
FutureProvider.family<List<Entry>, String>
```

**New approach - family with parameters object:**
```dart
class EntriesQuery {
  final String vaultId;
  final String searchQuery;
  
  EntriesQuery(this.vaultId, {this.searchQuery = ''});
  
  // Override == and hashCode for provider caching
}

final entriesProvider = FutureProvider.family<List<Entry>, EntriesQuery>((ref, query) async {
  return await Data.entries.list(
    QueryOptions(
      filters: {'vault_id': query.vaultId},
      sortBy: 'updated_at',
      ascending: false,
      searchQuery: query.searchQuery.trim().isEmpty ? null : query.searchQuery.trim(),
      searchColumns: ['heading', 'body'],
    ),
  );
});
```

**Search behavior:**
- If searchQuery is empty or < 2 characters, don't apply search filter (show all)
- If searchQuery >= 2 characters, apply backend search

### 3. Refactor VaultPage
Update [`client-flutter/lib/pages/vault_page.dart`](client-flutter/lib/pages/vault_page.dart):

**Remove local state:**
- Remove `List<Entry> _filteredEntries` variable
- Remove `_onSearchChanged()` method

**Update search handling:**
- Keep `_searchController` for user input
- Add debouncing to avoid excessive backend calls (use Timer to delay 300ms)
- Update search listener to call `setState()` which triggers provider rebuild with new query

**Update build method:**
- Change provider watch to pass search query:
  ```dart
  final searchQuery = _searchController.text;
  final entriesAsync = ref.watch(entriesProvider(EntriesQuery(widget.vaultId, searchQuery: searchQuery)));
  ```
- Remove references to `_filteredEntries`, use `entries` directly from AsyncValue
- Update empty state message logic based on `searchQuery.isEmpty`

**Debounce implementation:**
```dart
Timer? _searchDebounce;

void _onSearchChanged() {
  _searchDebounce?.cancel();
  _searchDebounce = Timer(const Duration(milliseconds: 300), () {
    setState(() {}); // Triggers rebuild with new search query
  });
}
```

### 4. Update Other Provider References
Check and update any other places that invalidate `entriesProvider`:
- [`vault_page.dart`](client-flutter/lib/pages/vault_page.dart) - update invalidate calls to use EntriesQuery
- [`entry_page.dart`](client-flutter/lib/pages/entry_page.dart) - check if it invalidates entries provider

## Benefits
- **Performance**: Database-level search with indexes
- **Scalability**: Handles large entry lists without loading everything to frontend
- **Less state**: No local filtering state to manage
- **Consistency**: Single source of truth from backend
- **Network efficient**: Only fetches matching results

## Implementation Notes
- Minimum search length of 2 characters prevents excessive queries
- Debouncing prevents API call on every keystroke
- EntriesQuery object ensures provider properly caches and invalidates
- Supabase `.ilike()` provides case-insensitive partial matching