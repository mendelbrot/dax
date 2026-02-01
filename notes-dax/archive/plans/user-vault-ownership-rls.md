---
name: User Vault Ownership RLS
status: completed
created: 2026-01-12
overview: Add user ownership to vaults and enforce Row Level Security (RLS) so users can only CRUD vaults they own and entries belonging to their vaults.
---

# User Vault Ownership and RLS Implementation

## Overview
Add user ownership to vaults and enforce Row Level Security (RLS) so users can only CRUD vaults they own and entries belonging to vaults they own.

## Database Schema Changes

### 1. Add owner_id column to dax_vault table
- Add `owner_id uuid NOT NULL` column to `public.dax_vault`
- Reference `auth.users(id)` via foreign key constraint
- Since there's no existing data, we can make it NOT NULL immediately

### 2. Add foreign key constraint
- Create foreign key: `dax_vault.owner_id` → `auth.users.id`
- Add constraint name: `dax_vault_owner_id_fkey`

### 3. Add foreign key for dax_entry.vault_id (if missing)
- Verify/add foreign key: `dax_entry.vault_id` → `dax_vault.id`
- This ensures referential integrity for the ownership chain

## RLS Policy Updates

### 4. Update dax_vault RLS policies
Replace existing permissive policies with ownership-based policies:
- **SELECT**: Users can only read vaults where `owner_id = auth.uid()`
- **INSERT**: Users can only insert vaults with `owner_id = auth.uid()` (enforced via WITH CHECK)
- **UPDATE**: Users can only update vaults they own (`owner_id = auth.uid()`)
- **DELETE**: Users can only delete vaults they own (`owner_id = auth.uid()`)

### 5. Update dax_entry RLS policies
Replace existing permissive policies with vault ownership checks:
- **SELECT**: Users can only read entries where the vault's `owner_id = auth.uid()` (via JOIN or subquery)
- **INSERT**: Users can only insert entries into vaults they own (check via `vault_id`)
- **UPDATE**: Users can only update entries in vaults they own
- **DELETE**: Users can only delete entries in vaults they own

## Implementation Files

### Schema Files (Declarative Schema Approach)
**Edit these schema files directly** - migrations will be auto-generated:
- Update `supabase/schemas/02_tables.sql`:
  - Add `owner_id uuid NOT NULL` column to `dax_vault` table definition
  - Add foreign key constraint: `CONSTRAINT dax_vault_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES auth.users(id)`
  - Add foreign key constraint for `dax_entry.vault_id` → `dax_vault.id` if missing

- Update `supabase/schemas/06_rls_policies.sql`:
  - Drop existing permissive RLS policies for both tables
  - Create new ownership-based RLS policies for `dax_vault`
  - Create new vault ownership-based RLS policies for `dax_entry`

### Migration Generation
After schema files are updated, the user will run:
```bash
npm run db:diff add_vault_ownership
```
This will generate the migration file automatically from the schema changes.

## RLS Policy Implementation Details

### Vault Policies
```sql
-- SELECT: Only own vaults
CREATE POLICY "Users can only read own vaults"
    ON public.dax_vault
    FOR SELECT
    TO authenticated
    USING (owner_id = auth.uid());

-- INSERT: Must set owner_id to current user
CREATE POLICY "Users can only insert own vaults"
    ON public.dax_vault
    FOR INSERT
    TO authenticated
    WITH CHECK (owner_id = auth.uid());

-- UPDATE: Only own vaults, cannot change owner
CREATE POLICY "Users can only update own vaults"
    ON public.dax_vault
    FOR UPDATE
    TO authenticated
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- DELETE: Only own vaults
CREATE POLICY "Users can only delete own vaults"
    ON public.dax_vault
    FOR DELETE
    TO authenticated
    USING (owner_id = auth.uid());
```

### Entry Policies
```sql
-- SELECT: Entries in owned vaults
CREATE POLICY "Users can only read entries in own vaults"
    ON public.dax_entry
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM dax_vault 
            WHERE dax_vault.id = dax_entry.vault_id 
            AND dax_vault.owner_id = auth.uid()
        )
    );

-- INSERT: Must belong to owned vault
CREATE POLICY "Users can only insert entries in own vaults"
    ON public.dax_entry
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM dax_vault 
            WHERE dax_vault.id = dax_entry.vault_id 
            AND dax_vault.owner_id = auth.uid()
        )
    );

-- UPDATE: Only entries in owned vaults
CREATE POLICY "Users can only update entries in own vaults"
    ON public.dax_entry
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM dax_vault 
            WHERE dax_vault.id = dax_entry.vault_id 
            AND dax_vault.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM dax_vault 
            WHERE dax_vault.id = dax_entry.vault_id 
            AND dax_vault.owner_id = auth.uid()
        )
    );

-- DELETE: Only entries in owned vaults
CREATE POLICY "Users can only delete entries in own vaults"
    ON public.dax_entry
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM dax_vault 
            WHERE dax_vault.id = dax_entry.vault_id 
            AND dax_vault.owner_id = auth.uid()
        )
    );
```

## Notes
- Using `auth.uid()` which is the standard Supabase function to get the current authenticated user's UUID
- Entry policies use EXISTS subqueries to check vault ownership efficiently
- All policies ensure users cannot access or modify data belonging to other users
- Foreign key constraints ensure data integrity at the database level
- Schema files are edited directly - migrations are auto-generated via `npm run db:diff`
