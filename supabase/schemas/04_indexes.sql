-- Enable pg_trgm extension for trigram indexing
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- Timestamp Indexes
-- ============================================
-- For filtering and sorting by date
CREATE INDEX IF NOT EXISTS idx_dax_entry_created_at 
  ON public.dax_entry (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_dax_entry_updated_at 
  ON public.dax_entry (updated_at DESC);

-- ============================================
-- Foreign Key Index
-- ============================================
-- For efficient vault-based queries
CREATE INDEX IF NOT EXISTS idx_dax_entry_vault_id 
  ON public.dax_entry (vault_id);

-- ============================================
-- Heading Trigram Index
-- ============================================
-- For fuzzy text search on headings
CREATE INDEX IF NOT EXISTS idx_dax_entry_heading_trgm 
  ON public.dax_entry USING GIN (heading gin_trgm_ops);

-- ============================================
-- Body Full-Text Search Index
-- ============================================
-- For keyword-based search on body content
CREATE INDEX IF NOT EXISTS idx_dax_entry_body_tsvector 
  ON public.dax_entry USING GIN (body_tsvector);

-- ============================================
-- Composite Index for Vault + Date
-- ============================================
-- For efficient filtering by vault and sorting by date
CREATE INDEX IF NOT EXISTS idx_dax_entry_vault_created 
  ON public.dax_entry (vault_id, created_at DESC);
