alter table "public"."dax_entry" add column "transient_client_id" uuid not null;

alter table "public"."dax_vault" add column "transient_client_id" uuid not null;

CREATE UNIQUE INDEX idx_dax_entry_realtime ON public.dax_entry USING btree (id, vault_id, transient_client_id);

CREATE UNIQUE INDEX idx_dax_vault_realtime ON public.dax_vault USING btree (id, owner_id, transient_client_id);

ALTER TABLE dax_entry REPLICA IDENTITY USING INDEX idx_dax_entry_realtime;

ALTER TABLE dax_vault REPLICA IDENTITY USING INDEX idx_dax_vault_realtime;
