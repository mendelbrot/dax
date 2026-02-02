---
name: go_router_setup
overview: Set up go_router for declarative navigation with authentication redirects, replacing the current AuthWrapper approach with proper route handling for Home → Vault → Entry hierarchy.
todos:
  - id: add_go_router_dependency
    content: Add go_router package to pubspec.yaml dependencies
    status: pending
  - id: create_router_config
    content: Create lib/router/app_router.dart with route definitions and authentication redirect logic
    status: pending
  - id: update_main_dart
    content: Update main.dart to use MaterialApp.router with GoRouter configuration
    status: pending
  - id: update_home_page_navigation
    content: Update HomePage to navigate to vault page using go_router
    status: pending
  - id: create_vault_page
    content: Create placeholder VaultPage that accepts vaultId parameter
    status: pending
  - id: create_entry_page
    content: Create placeholder EntryPage that accepts vaultId and entryId parameters
    status: pending
---

# Go Router Setup with Authentication

## Overview

Replace the current `AuthWrapper`-based navigation with `go_router` for declarative routing that supports deep linking and proper authentication redirects. The router will handle the route hierarchy: `/signin` → `/` (Home) → `/vault/:vaultId` → `/vault/:vaultId/entry/:entryId`.

## Implementation Steps

### 1. Add go_router Dependency

Add `go_router` to [pubspec.yaml](client-flutter/pubspec.yaml) dependencies section.

### 2. Create Router Configuration

Create [lib/router/app_router.dart](client-flutter/lib/router/app_router.dart) with:
- Route definitions for all four routes (signin, home, vault, entry)
- Nested route structure for vault and entry
- Redirect logic that checks `AuthProvider.isAuthenticated`
- Proper handling of authentication state changes using `refreshListenable`

The router will:
- Redirect unauthenticated users from protected routes to `/signin`
- Redirect authenticated users from `/signin` to `/`
- Extract `vaultId` and `entryId` from path parameters

### 3. Update main.dart

Modify [lib/main.dart](client-flutter/lib/main.dart) to:
- Replace `MaterialApp` with `MaterialApp.router`
- Use `GoRouter` from the router configuration
- Wrap `AuthProvider` with `ChangeNotifierProvider` (already present)
- Pass `AuthProvider` as `refreshListenable` to the router so it reacts to auth state changes

### 4. Update HomePage Navigation

Update [lib/pages/home_page.dart](client-flutter/lib/pages/home_page.dart):
- Replace the empty `onTap` handler (line 224) with `context.go('/vault/${vault.id}')`
- Import `go_router` package

### 5. Create Placeholder Pages

Create minimal placeholder pages that accept route parameters:

- [lib/pages/vault_page.dart](client-flutter/lib/pages/vault_page.dart): Accepts `vaultId` parameter, displays vault ID
- [lib/pages/entry_page.dart](client-flutter/lib/pages/entry_page.dart): Accepts `vaultId` and `entryId` parameters, displays both IDs

These placeholders will be replaced with full implementations later.

## Architecture Notes

The router's `redirect` callback will check authentication state via `AuthProvider`. Since `AuthProvider` extends `ChangeNotifier`, we can pass it as `refreshListenable` to `GoRouter` so route redirects update automatically when authentication state changes (e.g., after successful OTP verification or sign out).

## Files to Modify

- `client-flutter/pubspec.yaml` - Add go_router dependency
- `client-flutter/lib/main.dart` - Replace MaterialApp with MaterialApp.router
- `client-flutter/lib/pages/home_page.dart` - Add navigation to vault page

## Files to Create

- `client-flutter/lib/router/app_router.dart` - Router configuration
- `client-flutter/lib/pages/vault_page.dart` - Placeholder vault page
- `client-flutter/lib/pages/entry_page.dart` - Placeholder entry page
