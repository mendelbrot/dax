-- Enable Row Level Security on tables
ALTER TABLE public.dax_vault ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dax_entry ENABLE ROW LEVEL SECURITY;

-- RLS Policies for dax_vault
-- Users can only read vaults they own
CREATE POLICY "Users can only read own vaults"
    ON public.dax_vault
    FOR SELECT
    TO authenticated
    USING (owner_id = auth.uid());

-- Users can only insert vaults with themselves as owner
CREATE POLICY "Users can only insert own vaults"
    ON public.dax_vault
    FOR INSERT
    TO authenticated
    WITH CHECK (owner_id = auth.uid());

-- Users can only update vaults they own, and cannot change owner
CREATE POLICY "Users can only update own vaults"
    ON public.dax_vault
    FOR UPDATE
    TO authenticated
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- Users can only delete vaults they own
CREATE POLICY "Users can only delete own vaults"
    ON public.dax_vault
    FOR DELETE
    TO authenticated
    USING (owner_id = auth.uid());

-- RLS Policies for dax_entry
-- Users can only read entries in vaults they own
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

-- Users can only insert entries into vaults they own
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

-- Users can only update entries in vaults they own
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

-- Users can only delete entries in vaults they own
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
