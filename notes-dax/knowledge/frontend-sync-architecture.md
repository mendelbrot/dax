# Frontend Architecture & Realtime Sync Guide

## 1. The Core Challenge: "Echoes" in Realtime Apps
When you build a realtime app with Supabase and Flutter, you typically have this flow:
1.  **User acts:** Deletes a note.
2.  **App updates DB:** Sends `DELETE` command to Supabase.
3.  **Supabase notifies:** Broadcasts a "DELETE happened!" event to all connected clients.
4.  **App receives event:** Your app receives the *same* event it just caused.

If you blindly react to this event (e.g., "Reload the list!"), your app might flicker or do redundant work. This is the **"Echo"**.

## 2. The Solution: Transient Client ID & Expiring Sets

To solve this, we need to know **"Did I do this?"**

### A. The "Transient Client ID" (For Inserts/Updates)
We generate a random UUID when the app starts (the `transientClientId`). We send this ID with every `INSERT` or `UPDATE`.
- **Logic:**
    - **Sending:** `UPDATE ... SET ..., transient_client_id = 'my-uuid'`
    - **Receiving:** In the realtime callback:
        ```dart
        if (payload.newRecord['transient_client_id'] == mySessionId) {
           return; // Ignore! It's my own echo.
        }
        // Otherwise, refresh data because someone else changed it.
        ```

### B. The "Expiring Set" (For Deletes)
Postgres `DELETE` events are tricky. They often don't contain the full record data (and thus might miss the `transient_client_id` unless specifically configured). Even with configuration, it's safer to track the *action* locally. **<-- the reason is the log contains only the info from the old record (because there is no new updated record) so the transient id is from the last create or update evewnt and may not be the same.**

- **The Logic:**
    1.  User clicks "Delete Note #123".
    2.  App adds `123` to the **Expiring Set**. This is a list of "IDs I just deleted".
    3.  App sends `DELETE` request to API.
    4.  ...milliseconds later... Realtime event arrives: "Note #123 was deleted".
    5.  App checks Expiring Set: "Do I have 123 in there?"
        - **Yes:** "Oh, that was me. Ignore." (Remove 123 from set). **<-- don't remove it from the set, just let it expire on its own**
        - **No:** "Someone else deleted 123! I need to remove it from my UI."

The set is "Expiring" because if the event *never* comes (network error), we don't want to ignore `123` forever. It automatically cleans itself up after 5-10 seconds. **<-- nope, the reason for the item expire is just to avoid memory leaks and holding on to unneeded data**

## 3. Riverpod: Providers vs. Notifiers

You mentioned confusion about `Provider` vs `ChangeNotifierProvider` vs `NotifierProvider`.

| Provider Type | Description | Recommendation |
| :--- | :--- | :--- |
| **`Provider`** | Read-only value. Good for simple dependencies (like a Repository or Service). | ✅ Use for Services |
| **`FutureProvider`** | Async data (like fetching `List<Note>`). Handles loading/error states automatically. | ✅ Keep using this for data fetching |
| **`ChangeNotifierProvider`** | Legacy Flutter style (mutable classes with `notifyListeners`). | ❌ Avoid for new code. Harder to test and debug. |
| **`NotifierProvider`** | Modern Riverpod. Immutable state. Best for complex logic (e.g., a Shopping Cart or Form State). | ✅ Use for complex local state |

**Your Current Setup:**
- You use `FutureProvider` for fetching (`entriesProvider`). This is correct.
- You use `invalidate(entriesProvider)` to force a refresh. This is a solid, simple strategy ("Pull-based updates").

## 4. Implementation Plan (Mental Model)

### Step 1: `ExpiringSet` Helper
Add the `ExpiringSet` class to `lib/helpers/`. This is your "memory" for deleted items.

### Step 2: Global Session ID
In `RealtimeSyncService`, generate a `final _transientClientId = Uuid().v4();`.
You will need to pass this ID to your `DataService` so it can include it in DB calls.

### Step 3: Update `DataService`
Your `BaseDataService` needs a way to include `transient_client_id`.
*   **Option A (Easy):** Add `String? transientClientId` to `create`/`update` methods.
*   **Option B (Clean):** Pass the ID to the `DataService` constructor.

### Step 4: The Sync Logic
In `RealtimeSyncService`:
```dart
// DELETE EVENT
if (payload.eventType == PostgresChangeEvent.delete) {
  final id = payload.oldRecord['id'];
  if (expiringSet.contains(id)) {
     return; // It was me.
  }
  ref.invalidate(entriesProvider); // It was someone else.
}

// INSERT/UPDATE EVENT
if (payload.newRecord['transient_client_id'] == _transientClientId) {
  return; // It was me.
}
ref.invalidate(entriesProvider); // It was someone else.
```

## 5. Directory Structure Recommendation
Since you mentioned restructuring, here is a standard "Feature-First" or "Clean" structure for Flutter:

```
lib/
├── core/               # Shared logic (ExpiringSet, BaseModels, Formatters)
├── features/
│   ├── auth/
│   ├── vault/
│   │   ├── data/       # Repositories / DataSources
│   │   ├── domain/     # Models (Vault)
│   │   ├── presentation/
│   │   │   ├── controllers/ (Riverpod Notifiers)
│   │   │   └── pages/       (Widgets)
│   └── entries/
└── main.dart
```
*For now, stick to your current structure to minimize breakage, but keep this in mind for the future.*
