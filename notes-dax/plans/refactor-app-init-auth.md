# Plan: Refactor App Initialization & Auth to Riverpod

**Objective:** Clean up app initialization by separating the app component, moving routing logic to a provider, and fully migrating authentication to Riverpod.

## 1. Refactor `AuthProvider`
**Current State:** `ChangeNotifier` using `Provider`.
**Goal:** `Notifier<AuthState>` using `Riverpod`.
- Create `AuthState` class (immutable) with fields:
  - `User? user`
  - `bool isLoading`
  - `String? errorMessage`
- Create `AuthNotifier` extending `Notifier<AuthState>`.
- Remove `ChangeNotifier` dependency.
- Expose via `authProvider`.

## 2. Create `routerProvider`
**Current State:** `createAppRouter` function manually called in `main.dart`, taking `AuthProvider` as an argument.
**Goal:** `Provider<GoRouter>` in `app_router.dart`.
- Create `routerProvider` that:
  - Uses `ref.watch(authProvider)` to listen for auth changes.
  - Configures `GoRouter` with `redirect` logic based on the watched auth state.
  - Removes the need for `refreshListenable`.

## 3. Create `app.dart`
**Current State:** `MyApp` is a `StatefulWidget` in `main.dart`.
**Goal:** `MyApp` as a `ConsumerWidget` in `lib/app.dart`.
- Move `MyApp` class to `lib/app.dart`.
- Change to `ConsumerWidget`.
- Watch `routerProvider` to get the `routerConfig`.
- Remove manual provider injection (since we use `ProviderScope` at root).

## 4. Clean `main.dart`
**Current State:** Contains `MyApp`, Supabase init, and manual provider wiring.
**Goal:** minimal entry point.
- Only keep:
  - `WidgetsFlutterBinding.ensureInitialized()` (implicit in `runApp` but good practice with async init)
  - `setPathUrlStrategy()`
  - Supabase initialization.
  - `runApp(ProviderScope(child: MyApp()))`.

## 5. Update Pages
**Current State:** Uses `context.read<AuthProvider>()` and `context.watch<AuthProvider>()`.
**Goal:** Use Riverpod `ref`.
- **`SignInPage`**:
  - Convert to `ConsumerStatefulWidget` or `ConsumerWidget`.
  - Use `ref.watch(authProvider)` for UI state (loading, error).
  - Use `ref.read(authProvider.notifier)` for actions (`signIn`, `verifyOTP`).
- **`HomePage`**:
  - Use `ref.read(authProvider.notifier).signOut()`.

## Execution Order
1.  Create `app.dart` (move `MyApp` logic first).
2.  Refactor `AuthProvider` to Riverpod.
3.  Implement `routerProvider` using the new Auth provider.
4.  Update `MyApp` to use `routerProvider`.
5.  Clean `main.dart`.
6.  Fix `SignInPage` and `HomePage`.
