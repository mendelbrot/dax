alter table "public"."dax_entry" drop constraint "dax_entry_vault_id_fkey";

alter table "public"."dax_vault" drop constraint "dax_vault_owner_id_fkey";

alter table "public"."dax_entry" add constraint "dax_entry_vault_id_fkey" FOREIGN KEY (vault_id) REFERENCES public.dax_vault(id) ON DELETE CASCADE not valid;

alter table "public"."dax_entry" validate constraint "dax_entry_vault_id_fkey";

alter table "public"."dax_vault" add constraint "dax_vault_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."dax_vault" validate constraint "dax_vault_owner_id_fkey";


