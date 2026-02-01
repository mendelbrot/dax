---
name: Flutter Theme Cleanup
overview: Create a centralized theme configuration using green as the seed color, and replace all hardcoded colors throughout the app with theme-based colors for consistency.
todos:
  - id: create-theme-file
    content: Create app_theme.dart with green-based ColorScheme and ThemeData
    status: pending
  - id: update-main
    content: Update main.dart to import and use the centralized theme
    status: pending
    dependencies:
      - create-theme-file
  - id: replace-error-colors
    content: Replace all Colors.red instances with colorScheme.error in home_page, entry_page, sign_in_page, and vault_settings_page
    status: pending
    dependencies:
      - create-theme-file
  - id: replace-grey-colors
    content: Replace Colors.grey instances with appropriate theme colors (onSurfaceVariant)
    status: pending
    dependencies:
      - create-theme-file
  - id: configure-divider-theme
    content: Configure DividerTheme in app_theme.dart to ensure consistent divider colors throughout the app
    status: pending
    dependencies:
      - create-theme-file
---

# Flutter Theme Cleanup

Generate a Material 3 theme from green and apply it consistently throughout the app by replacing hardcoded colors with theme colors.

## Implementation Plan

### 1. Create Theme Configuration File

Create [`client-flutter/lib/theme/app_theme.dart`](client-flutter/lib/theme/app_theme.dart):

- Generate `ColorScheme` from `Colors.green` seed color
- Create `ThemeData` with Material 3 enabled
- Configure `DividerTheme` to ensure consistent divider styling using theme colors
- Export theme for use in `main.dart`

### 2. Update Main App

Update [`client-flutter/lib/main.dart`](client-flutter/lib/main.dart):

- Import the new theme file
- Replace inline theme definition with the centralized theme

### 3. Replace Hardcoded Colors

Replace all hardcoded color references with theme colors:

**Error Colors (`Colors.red`):**

- [`client-flutter/lib/pages/home_page.dart`](client-flutter/lib/pages/home_page.dart) line 107: Error icon → `colorScheme.error`
- [`client-flutter/lib/pages/entry_page.dart`](client-flutter/lib/pages/entry_page.dart) line 183: Error icon → `colorScheme.error`
- [`client-flutter/lib/pages/sign_in_page.dart`](client-flutter/lib/pages/sign_in_page.dart) line 58: SnackBar background → `colorScheme.error`
- [`client-flutter/lib/pages/vault_settings_page.dart`](client-flutter/lib/pages/vault_settings_page.dart) lines 130, 166, 169: Delete button and icon → `colorScheme.error` (appropriate for destructive actions)

**Neutral/Grey Colors (`Colors.grey`):**

- [`client-flutter/lib/pages/home_page.dart`](client-flutter/lib/pages/home_page.dart) line 172: Empty state icon → `colorScheme.onSurfaceVariant`
- [`client-flutter/lib/pages/entry_page.dart`](client-flutter/lib/pages/entry_page.dart) line 220: Saving indicator icon → `colorScheme.onSurfaceVariant`

**Dividers:**

- Configure `DividerTheme` in theme to ensure all dividers use consistent theme colors
- Dividers are currently using default styling in:
- [`client-flutter/lib/pages/home_page.dart`](client-flutter/lib/pages/home_page.dart): 2 dividers (thickness: 2)
- [`client-flutter/lib/pages/vault_page.dart`](client-flutter/lib/pages/vault_page.dart): 2 dividers (height: 1)
- [`client-flutter/lib/pages/entry_page.dart`](client-flutter/lib/pages/entry_page.dart): 2 dividers (height: 1, thickness: 1)
- [`client-flutter/lib/pages/vault_settings_page.dart`](client-flutter/lib/pages/vault_settings_page.dart): 1 divider (default)
- Theme configuration will ensure dividers automatically use `colorScheme.outlineVariant` or appropriate theme color

### 4. Ensure Theme Consistency

**Automatic (no changes needed):**

- **Text inputs (TextField/TextFormField)**: Material 3 automatically applies theme colors to borders, labels, hint text, and input text. No changes needed.
- **Text widgets**: Most text already uses `Theme.of(context).textTheme.*` which automatically uses theme colors. Plain `Text()` widgets without explicit styles also automatically use theme text colors.
- **Icons in IconButton**: Icons inside `IconButton` widgets automatically use theme colors. No changes needed for these.
- **Dividers**: Once `DividerTheme` is configured, all dividers automatically use theme colors (`colorScheme.outlineVariant`).

**Requires explicit changes:**

- **Standalone Icon widgets**: Icons with explicit `color:` parameters (currently `Colors.red` and `Colors.grey`) need to be updated to use theme colors.
- **SnackBars**: Error SnackBars with hardcoded `backgroundColor: Colors.red` need to use `colorScheme.error`.
- **Error icons**: Standalone error icons need to use `colorScheme.error` instead of `Colors.red`.

## Files to Modify

1. **New file:** `client-flutter/lib/theme/app_theme.dart` - Theme configuration
2. `client-flutter/lib/main.dart` - Use centralized theme
3. `client-flutter/lib/pages/home_page.dart` - Replace hardcoded colors
4. `client-flutter/lib/pages/sign_in_page.dart` - Replace hardcoded colors
5. `client-flutter/lib/pages/entry_page.dart` - Replace hardcoded colors
6. `client-flutter/lib/pages/vault_settings_page.dart` - Replace hardcoded colors
