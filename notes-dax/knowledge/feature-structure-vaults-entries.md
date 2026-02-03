# Feature Structure Decision: Vaults and Entries

**Date:** 2026-02-02
**Context:** During the planning for a feature-first refactor, the question arose whether "Vaults" and "Entries" should be separated into distinct features (e.g., `features/vaults/` and `features/entries/`).

## Analysis
The intuition is that separating them creates artificial boundaries between logically inseparable concepts. The `VaultPage` inherently displays `Entries` and provides UI to create/search them.

### 1. High Cohesion, Low Coupling
*   **Reality:** A `VaultPage` essentially acts as a view for a list of `Entries`. It requires `Entry` widgets, models, and providers to function.
*   **Problem with Separation:** Splitting them into separate feature directories (`features/vaults` vs. `features/entries`) does not decouple them. Instead, it creates a heavy dependency where `features/vaults` relies extensively on `features/entries`, spreading coupled code across multiple directories and complicating imports.

### 2. Domain-Driven Design (Aggregate Root)
*   **Concept:** In DDD terms, if an **Entry** cannot exist or be meaningfully manipulated without the context of a **Vault**, the **Vault** acts as the Aggregate Root.
*   **Conclusion:** They belong to the same domain context.

## Decision / Recommendation
**Keep Vaults and Entries together.**

Instead of splitting by noun (Vault vs. Entry), define the feature by **User Capability** or **Domain Area**.

### Recommended Structure
Encapsulate both concepts under a single feature, such as `features/notebook` or `features/vaults`.

```text
lib/
├── features/
│   ├── auth/                 <-- Distinct feature
│   │   ├── pages/
│   │   └── providers/
│   └── notebook/             <-- The "Core" feature (manages Vaults AND Entries)
│       ├── components/       <-- Shared UI parts (entry list items, vault headers)
│       ├── models/           <-- Vault, Entry
│       ├── pages/            <-- VaultPage, EntryPage, VaultSettingsPage
│       └── providers/        <-- VaultController, EntryController (or combined)
```

### Exception Criteria
Separation would only be considered if "Entries" had a significant independent existence outside of a vault context (e.g., a complex global system not tied to vaults), but even then, a specific feature (like `features/search`) consuming the core domain models is often preferable to splitting the domain itself.
