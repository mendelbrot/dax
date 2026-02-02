-- Migration: Add search indexes and full-text search support
-- Date: 2026-01-27
-- Description: Adds trigram index for heading, tsvector for body, and search_entries RPC function

-- ============================================
-- Enable Extensions
-- ============================================
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- Add Generated Column for Full-Text Search
-- ============================================
-- Add body_tsvector column to dax_entry table
ALTER TABLE public.dax_entry 
  ADD COLUMN IF NOT EXISTS body_tsvector tsvector 
  GENERATED ALWAYS AS (to_tsvector('english', coalesce(body, ''))) STORED;

-- ============================================
-- Create Indexes
-- ============================================

-- Timestamp Indexes (for filtering and sorting by date)
CREATE INDEX IF NOT EXISTS idx_dax_entry_created_at 
  ON public.dax_entry (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_dax_entry_updated_at 
  ON public.dax_entry (updated_at DESC);

-- Foreign Key Index (for efficient vault-based queries)
CREATE INDEX IF NOT EXISTS idx_dax_entry_vault_id 
  ON public.dax_entry (vault_id);

-- Heading Trigram Index (for fuzzy text search)
CREATE INDEX IF NOT EXISTS idx_dax_entry_heading_trgm 
  ON public.dax_entry USING GIN (heading gin_trgm_ops);

-- Body Full-Text Search Index (for keyword-based search)
CREATE INDEX IF NOT EXISTS idx_dax_entry_body_tsvector 
  ON public.dax_entry USING GIN (body_tsvector);

-- Composite Index for Vault + Date (for efficient filtering and sorting)
CREATE INDEX IF NOT EXISTS idx_dax_entry_vault_created 
  ON public.dax_entry (vault_id, created_at DESC);

-- ============================================
-- Search Entries RPC Function
-- ============================================
CREATE OR REPLACE FUNCTION search_entries(
  p_vault_id BIGINT,
  p_query TEXT
)
RETURNS TABLE (
  id BIGINT,
  vault_id BIGINT,
  heading CHARACTER VARYING(255),
  body TEXT,
  body_tsvector TSVECTOR,
  attributes JSONB,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
) 
SECURITY DEFINER
AS $$
DECLARE
  ts_query_text TEXT;
BEGIN
  -- Convert query to tsquery format (space-separated words become AND operations)
  ts_query_text := regexp_replace(trim(p_query), '\s+', ' & ', 'g');
  
  RETURN QUERY
  SELECT 
    e.id,
    e.vault_id,
    e.heading,
    e.body,
    e.body_tsvector,
    e.attributes,
    e.created_at,
    e.updated_at
  FROM dax_entry e
  WHERE e.vault_id = p_vault_id
    AND (
      -- Trigram fuzzy search on heading (uses idx_dax_entry_heading_trgm)
      e.heading ILIKE '%' || p_query || '%'
      OR
      -- Full-text search on body (uses idx_dax_entry_body_tsvector)
      (ts_query_text != '' AND e.body_tsvector @@ to_tsquery('english', ts_query_text))
    )
  ORDER BY e.updated_at DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION search_entries(BIGINT, TEXT) TO authenticated;
