-- Function to handle updated_at timestamp on UPDATE
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to handle created_at timestamp on INSERT (for tables with only created_at)
CREATE OR REPLACE FUNCTION public.handle_created_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to handle created_at and updated_at timestamps on INSERT (for tables with both)
CREATE OR REPLACE FUNCTION public.handle_created_at_with_updated()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at = CURRENT_TIMESTAMP;
    END IF;
    IF NEW.updated_at IS NULL THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for dax_vault: set created_at on INSERT
CREATE TRIGGER set_dax_vault_timestamp
    BEFORE INSERT ON public.dax_vault
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_created_at();

-- Trigger for dax_entry: set created_at and updated_at on INSERT
CREATE TRIGGER set_dax_entry_timestamps
    BEFORE INSERT ON public.dax_entry
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_created_at_with_updated();

-- Trigger for dax_entry: update updated_at on UPDATE
CREATE TRIGGER update_dax_entry_timestamp
    BEFORE UPDATE ON public.dax_entry
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
