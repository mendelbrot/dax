---
name: Homepage Vault List with Create Dialog
overview: Rewrite the homepage to fetch and display user vaults using FutureBuilder, add a + icon button to open a modal dialog for creating new vaults, and handle loading/error states properly.
todos: []
---

# Homepage Vault List with Create Dialog

## Overview

Rewrite [`client-flutter/lib/pages/home_page.dart`](client-flutter/lib/pages/home_page.dart) to display the user's vaults fetched from Supabase, with a + icon button to create new vaults via a modal dialog.

## Implementation Details

### 1. Update HomePage State

- Replace hardcoded vault list with `FutureBuilder<List<Vault>>` that calls `Data.vaults.list()`
- Add state management for refreshing the vault list after creation
- Handle three states: loading, error, and data

### 2. UI Structure

- **AppBar**: Keep logout button on the right, add + icon button on the left (leading position)
- **Body**: Use `FutureBuilder` with:
- **Loading**: Show `CircularProgressIndicator` centered
- **Error**: Show error message with retry option
- **Data**: Display vaults in a `ListView` with proper styling (matching wireframe - simple list items with vault names)

### 3. Create Vault Dialog

- Use `showDialog` with `AlertDialog` widget (standard Flutter pattern)
- Dialog contains:
- Title: "Create New Vault"
- Text field for vault name (with validation)
- Cancel and Save buttons
- Save button calls `Data.vaults.create(name, {})` with empty settings map
- On success: close dialog and refresh the vault list

### 4. Vault List Items

- Display vault names in list tiles
- Make items tappable (but navigation logic will be added later)
- Style to match wireframe aesthetic (simple, clean list)

### 5. Error Handling

- Wrap `Data.vaults.list()` and `Data.vaults.create()` in try-catch
- Display user-friendly error messages
- Provide retry functionality for failed operations

## Files to Modify

- [`client-flutter/lib/pages/home_page.dart`](client-flutter/lib/pages/home_page.dart) - Complete rewrite

## Files to Reference

- [`client-flutter/lib/models/vault.dart`](client-flutter/lib/models/vault.dart) - Vault model structure
- [`client-flutter/lib/services/data_service.dart`](client-flutter/lib/services/data_service.dart) - Data.vaults API
