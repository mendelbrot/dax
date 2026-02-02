# Plan: Frontend Real-time Sync with Echo Cancellation

## Objective
Implement robust real-time synchronization in the Flutter frontend, ensuring local changes are reflected immediately ("optimistic UI") while filtering out "echo" notifications from the server.

## Components

### 1. `ExpiringSet` Helper
**File:** `client-flutter/lib/helpers/expiring_set.dart`
- **Purpose:** Tracks IDs of items deleted by the local user.
- **Mechanism:** Stores IDs for a short duration (e.g., 5s). Used to ignore incoming `DELETE` events for these IDs.

### 2. Session Management
**File:** `client-flutter/lib/providers/riverpod_providers.dart`
- **New Provider:** `transientClientIdProvider`.
- **Value:** A randomly generated UUID (v4) created at app startup.
- **Purpose:** Unique identifier for the current app instance to tag all write operations.

### 3. Data Service Updates
**File:** `client-flutter/lib/services/data_service.dart`
- **Change:** Update `BaseDataService.create` and `.update` (and `delete`?) to accept an optional `transient_client_id`.
- **Logic:** If provided, inject this ID into the payload sent to Supabase.
- **Note:** `delete` usually takes just an ID, but for the `ExpiringSet` logic, we handle the tracking *before* calling delete. The `transient_client_id` is crucial for `INSERT/UPDATE`.

### 4. Realtime Sync Service Refactoring
**File:** `client-flutter/lib/providers/realtime_change_notifier.dart`
- **Dependencies:** Read `transientClientIdProvider`.
- **State:** Maintain an instance of `ExpiringSet<int>`.
- **Logic:**
    - **Subscribe:** Listen to `dax_entry` and `dax_vault` (ensure correct table names).
    - **On Event:**
        - **DELETE:** Check `ExpiringSet`. If present -> Ignore. Else -> Invalidate provider.
        - **INSERT/UPDATE:** Check `payload['transient_client_id']`. If == `transientClientId` -> Ignore. Else -> Invalidate provider.
    - **Public Method:** `ignoreNextDelete(int id)`: Adds ID to `ExpiringSet`.

### 5. UI/Logic Integration
- **Update Logic:** When user creates/updates/deletes:
    1.  Get `transientClientId` from provider.
    2.  For Delete: Call `realtimeSync.ignoreNextDelete(id)`.
    3.  Call `Data.service.operation(..., transientClientId: transientClientId)`.

## Execution Steps
1.  **Create `ExpiringSet` class.**
2.  **Add `transientClientIdProvider`.**
3.  **Update `BaseDataService` signature.**
4.  **Refactor `RealtimeSyncService`.**
5.  **Verify compilation and basic flow.** (User will verify runtime).
