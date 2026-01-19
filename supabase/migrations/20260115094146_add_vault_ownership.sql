drop policy "Allow authenticated users to delete dax_entry" on "public"."dax_entry";

drop policy "Allow authenticated users to insert dax_entry" on "public"."dax_entry";

drop policy "Allow authenticated users to read dax_entry" on "public"."dax_entry";

drop policy "Allow authenticated users to update dax_entry" on "public"."dax_entry";

drop policy "Allow authenticated users to delete dax_vault" on "public"."dax_vault";

drop policy "Allow authenticated users to insert dax_vault" on "public"."dax_vault";

drop policy "Allow authenticated users to read dax_vault" on "public"."dax_vault";

drop policy "Allow authenticated users to update dax_vault" on "public"."dax_vault";

alter table "public"."dax_vault" add column "owner_id" uuid not null;

alter table "public"."dax_entry" add constraint "dax_entry_vault_id_fkey" FOREIGN KEY (vault_id) REFERENCES public.dax_vault(id) not valid;

alter table "public"."dax_entry" validate constraint "dax_entry_vault_id_fkey";

alter table "public"."dax_vault" add constraint "dax_vault_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) not valid;

alter table "public"."dax_vault" validate constraint "dax_vault_owner_id_fkey";


  create policy "Users can only delete entries in own vaults"
  on "public"."dax_entry"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.dax_vault
  WHERE ((dax_vault.id = dax_entry.vault_id) AND (dax_vault.owner_id = auth.uid())))));



  create policy "Users can only insert entries in own vaults"
  on "public"."dax_entry"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.dax_vault
  WHERE ((dax_vault.id = dax_entry.vault_id) AND (dax_vault.owner_id = auth.uid())))));



  create policy "Users can only read entries in own vaults"
  on "public"."dax_entry"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.dax_vault
  WHERE ((dax_vault.id = dax_entry.vault_id) AND (dax_vault.owner_id = auth.uid())))));



  create policy "Users can only update entries in own vaults"
  on "public"."dax_entry"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.dax_vault
  WHERE ((dax_vault.id = dax_entry.vault_id) AND (dax_vault.owner_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.dax_vault
  WHERE ((dax_vault.id = dax_entry.vault_id) AND (dax_vault.owner_id = auth.uid())))));



  create policy "Users can only delete own vaults"
  on "public"."dax_vault"
  as permissive
  for delete
  to authenticated
using ((owner_id = auth.uid()));



  create policy "Users can only insert own vaults"
  on "public"."dax_vault"
  as permissive
  for insert
  to authenticated
with check ((owner_id = auth.uid()));



  create policy "Users can only read own vaults"
  on "public"."dax_vault"
  as permissive
  for select
  to authenticated
using ((owner_id = auth.uid()));



  create policy "Users can only update own vaults"
  on "public"."dax_vault"
  as permissive
  for update
  to authenticated
using ((owner_id = auth.uid()))
with check ((owner_id = auth.uid()));



