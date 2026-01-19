drop trigger if exists "set_dax_vault_timestamp" on "public"."dax_vault";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_vault_insert()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at = CURRENT_TIMESTAMP;
    END IF;
    -- Always set owner_id to the authenticated user's ID (ignores any value from frontend)
    NEW.owner_id = auth.uid();
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER set_dax_vault_timestamp BEFORE INSERT ON public.dax_vault FOR EACH ROW EXECUTE FUNCTION public.handle_vault_insert();


