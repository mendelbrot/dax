-- Enable Realtime for the tables
ALTER PUBLICATION supabase_realtime ADD TABLE dax_vault, dax_entry;

-- Create the optimization index for ENTRIES
--    We include 'vault_id' because we need it for the RLS check & the frontend logic.
--    We exclude 'body' so note content is never logged.
--    transient_client_id provided by the client so that it can filter out notifications originating from itself
CREATE UNIQUE INDEX idx_dax_entry_realtime 
ON dax_entry (id, vault_id, transient_client_id);

CREATE UNIQUE INDEX idx_dax_vault_realtime 
ON dax_vault (id, owner_id, transient_client_id);

-- Set the Identity to use this index
ALTER TABLE dax_entry REPLICA IDENTITY USING INDEX idx_dax_entry_realtime;

ALTER TABLE dax_vault REPLICA IDENTITY USING INDEX idx_dax_vault_realtime;