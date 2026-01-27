-- ============================================
-- Search Entries Function
-- ============================================
-- Searches entries using trigram fuzzy matching on heading
-- and full-text search on body content
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
