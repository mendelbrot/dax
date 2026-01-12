-- Enable Row Level Security on tables
ALTER TABLE public.dax_vault ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dax_entry ENABLE ROW LEVEL SECURITY;

-- RLS Policies for dax_vault
-- Allow authenticated users to read
CREATE POLICY "Allow authenticated users to read dax_vault"
    ON public.dax_vault
    FOR SELECT
    TO authenticated
    USING (true);

-- Allow authenticated users to insert
CREATE POLICY "Allow authenticated users to insert dax_vault"
    ON public.dax_vault
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Allow authenticated users to update
CREATE POLICY "Allow authenticated users to update dax_vault"
    ON public.dax_vault
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Allow authenticated users to delete
CREATE POLICY "Allow authenticated users to delete dax_vault"
    ON public.dax_vault
    FOR DELETE
    TO authenticated
    USING (true);

-- RLS Policies for dax_entry
-- Allow authenticated users to read
CREATE POLICY "Allow authenticated users to read dax_entry"
    ON public.dax_entry
    FOR SELECT
    TO authenticated
    USING (true);

-- Allow authenticated users to insert
CREATE POLICY "Allow authenticated users to insert dax_entry"
    ON public.dax_entry
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Allow authenticated users to update
CREATE POLICY "Allow authenticated users to update dax_entry"
    ON public.dax_entry
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Allow authenticated users to delete
CREATE POLICY "Allow authenticated users to delete dax_entry"
    ON public.dax_entry
    FOR DELETE
    TO authenticated
    USING (true);
