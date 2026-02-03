# Strategies for Initializing `transientClientId`

This document outlines architectural strategies for initializing and managing the `transientClientId` in the Flutter frontend. This ID is primarily used for **echo cancellation** in Realtime systems—allowing the client to distinguish between "changes I just made" (which should be ignored/optimistically updated) and "changes others made" (which should trigger a UI refresh).

## 1. Ephemeral Session ID (Riverpod Provider)

This is the current recommended approach for Dax. A new ID is generated every time the app is launched (or more precisely, when the Provider container is built).

**Mechanism:**
- Generate a `Uuid().v4()` inside a synchronous Riverpod `Provider`.
- The ID exists only in memory for the lifecycle of the application instance.

**Pros:**
- **Simplicity:** No async dependencies, available immediately.
- **Correctness for Echoes:** "Echo cancellation" only cares about the *current* active socket connection/session. A restart implies a new session, so a new ID is appropriate.
- **Testability:** Can be easily overridden in tests using `ProviderScope(overrides: [...])`.

**Cons:**
- **No Persistence:** Cannot track "this device" across app restarts (e.g., for audit logs).

**Code Example:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Defined in riverpod_providers.dart
final transientClientIdProvider = Provider<String>((ref) {
  // Generates a new ID every time the app starts/hot restarts
  return const Uuid().v4();
});

// Usage
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientId = ref.watch(transientClientIdProvider);
    return Text('Client ID: $clientId');
  }
}
```

## 2. Persistent Device ID

This strategy generates an ID once, saves it to local storage, and reuses it across app restarts.

**Mechanism:**
- On startup, check `SharedPreferences` (or `flutter_secure_storage`).
- If found, use it. If not, generate -> save -> use.

**Pros:**
- **Device Identity:** Useful if you want to track "Changes made by iPhone 13" in backend logs permanently.
- **Consistent Debugging:** You know your Device ID and can filter logs by it across days.

**Cons:**
- **Async Initialization:** Requires `FutureProvider` or `SharedPreferences` initialization before the app runs `runApp()`. This adds complexity to startup.
- **Privacy/Cleanup:** The ID sticks around until the app is uninstalled or cache cleared.

**Code Example:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Would likely need to be a FutureProvider or initialized in main()
final deviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('dax_device_id');
  
  if (id == null) {
    id = const Uuid().v4();
    await prefs.setString('dax_device_id', id);
  }
  
  return id;
});

// Usage requires handling async state
final idAsync = ref.watch(deviceIdProvider);
// idAsync.when(...)
```

## 3. Static/Singleton Service Initialization

A traditional approach often used without Dependency Injection frameworks.

**Mechanism:**
- A static `final` field on a Service class or a global singleton.

**Pros:**
- **Global Access:** Can be accessed via `Data.transientClientId` anywhere without `context` or `ref`.
- **Simple:** No boilerplate.

**Cons:**
- **Tight Coupling:** Hard dependency makes unit testing difficult (mocking static fields is hard).
- **Lifecycle Management:** Harder to reset or scope if requirements change (e.g., multi-window support).

**Code Example:**
```dart
import 'package:uuid/uuid.dart';

class DataService {
  // Initialized when the class is first loaded
  static final String transientClientId = const Uuid().v4();
  
  Future<void> createEntry(Map<String, dynamic> data) async {
    // Implicitly used
    data['transient_client_id'] = transientClientId;
    await supabase.from('entries').insert(data);
  }
}
```

## 4. Backend-Assigned ID

The client requests an ID from the server upon connection.

**Mechanism:**
- Client connects -> Calls RPC `get_session_id()` -> Server mints ID and logs connection -> Returns ID.

**Pros:**
- **Security:** Server can validate the client or associate the ID with a user session table.
- **Uniqueness:** Guaranteed uniqueness by the central authority.

**Cons:**
- **Latency:** Client cannot perform "optimistic" actions until the network round-trip completes.
- **Complexity:** Requires handling offline startup scenarios (what ID do we use if we can't reach the server?).

**Code Example:**
```dart
final serverClientIdProvider = FutureProvider<String>((ref) async {
  // Must wait for network
  final response = await Supabase.instance.client.rpc('generate_client_id');
  return response as String;
});
```

## Recommendation

For Dax's current architecture (Supabase Realtime + Riverpod):
**Use Strategy 1 (Ephemeral Session ID via Provider)**.
It balances simplicity with the specific requirement of "ignoring *current* self-changes," without the async complexity of persistence.
