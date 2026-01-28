CREATE INDEX idx_dax_entry_vault_updated ON public.dax_entry USING btree (vault_id, updated_at DESC);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.search_entries(p_vault_id bigint, p_query text)
 RETURNS TABLE(id bigint, vault_id bigint, heading character varying, body text, body_tsvector tsvector, attributes jsonb, created_at timestamp with time zone, updated_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
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
$function$
;


