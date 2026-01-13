# Indexing Strategy for dax_entry Table

## Overview of Options by Field Type

### 1. **created_at & updated_at** (Timestamps)

#### Option: B-tree Index ✅ **RECOMMENDED**
- **What**: Standard PostgreSQL index for range queries and sorting
- **Use Cases**: 
  - Filter by date ranges (`WHERE created_at > '2024-01-01'`)
  - Order by date (`ORDER BY created_at DESC`)
  - Recent entries queries
- **Pros**: Fast, efficient, low overhead, good for exact/range queries
- **Cons**: None significant for timestamp fields
- **Implementation**: 
  ```sql
  CREATE INDEX idx_dax_entry_created_at ON public.dax_entry (created_at);
  CREATE INDEX idx_dax_entry_updated_at ON public.dax_entry (updated_at);
  ```
- **Optional Composite**: If you often query by both:
  ```sql
  CREATE INDEX idx_dax_entry_timestamps ON public.dax_entry (created_at, updated_at);
  ```

---

### 2. **heading** (Short Text - ~255 chars)

#### Option A: B-tree Index
- **What**: Standard index for exact matches and prefix searches
- **Use Cases**: Exact heading matches, prefix searches (`LIKE 'prefix%'`)
- **Pros**: Fast for exact matches, supports prefix search
- **Cons**: Doesn't handle fuzzy search, typos, or partial word matching
- **Query Example**: `WHERE heading = 'Exact Match'` or `WHERE heading LIKE 'My Note%'`

#### Option B: GIN Index with pg_trgm (Trigram) ✅ **RECOMMENDED for your use case**
- **What**: Indexes 3-character sequences for fuzzy text matching
- **Use Cases**: 
  - Fuzzy/fuzzy search ("Meeting" finds "Meetings", "Team Meeting")
  - Typo tolerance ("Meetng" finds "Meeting")
  - Partial word matching
- **Pros**: 
  - Excellent for fuzzy matching
  - Handles typos well
  - Good for autocomplete
  - Works with `ILIKE` and `SIMILARITY()` functions
- **Cons**: 
  - Larger index size (~3x data size)
  - Requires `pg_trgm` extension
- **Implementation**:
  ```sql
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  CREATE INDEX idx_dax_entry_heading_trgm ON public.dax_entry USING GIN (heading gin_trgm_ops);
  ```
- **Query Examples**:
  ```sql
  -- Fuzzy search
  WHERE heading % 'Meeting'  -- similarity operator
  WHERE SIMILARITY(heading, 'Meeting') > 0.3
  
  -- ILIKE can use trigram index
  WHERE heading ILIKE '%meeting%'
  ```

#### Option C: Full-Text Search (tsvector)
- **What**: Indexes words/tokens for semantic full-text search
- **Use Cases**: Finding entries containing specific words/phrases
- **Pros**: Good for word-based search, supports ranking
- **Cons**: More complex, may be overkill for short headings
- **Implementation**: Requires generated column (see below)

---

### 3. **body** (Long Text)

#### Option A: Full-Text Search (tsvector) ✅ **RECOMMENDED for keyword-based search**
- **What**: Converts text to searchable tokens with stemming
- **Use Cases**: 
  - Find entries containing specific words/phrases
  - Keyword-based search ("find entries about meetings")
  - Multiple word queries with ranking
- **Pros**: 
  - Native PostgreSQL (no extension needed for basic use)
  - Supports ranking/relevance scoring
  - Handles language-specific stemming
  - Good for keyword-based queries
- **Cons**: 
  - Doesn't understand semantic meaning
  - Requires generated column
  - Index updates on every write
- **Implementation**: 
  ```sql
  -- Generated column
  ALTER TABLE public.dax_entry 
    ADD COLUMN body_tsvector tsvector 
    GENERATED ALWAYS AS (to_tsvector('english', body)) STORED;
  
  -- GIN index
  CREATE INDEX idx_dax_entry_body_tsvector ON public.dax_entry USING GIN (body_tsvector);
  ```
- **Query Example**:
  ```sql
  WHERE body_tsvector @@ to_tsquery('english', 'meeting & agenda')
  ORDER BY ts_rank(body_tsvector, to_tsquery('english', 'meeting & agenda')) DESC
  ```

#### Option B: Vector Embeddings (pgvector) ✅ **RECOMMENDED for semantic search**
- **What**: Stores semantic embeddings (vectors) for AI-powered similarity search
- **Use Cases**: 
  - Semantic search ("find entries similar to this")
  - Meaning-based queries ("find entries about team collaboration")
  - Similarity search across concepts
- **Pros**: 
  - Understands semantic meaning
  - Excellent for "find similar" queries
  - Works with LLMs/embeddings (OpenAI, etc.)
  - Supports cosine similarity, L2 distance
- **Cons**: 
  - Requires external service to generate embeddings
  - Larger storage (~1-2KB per embedding)
  - More complex setup
  - Need to generate embeddings on insert/update
- **Requirements**: 
  - `pgvector` extension
  - Embedding generation service (OpenAI, local model, etc.)
- **Implementation**:
  ```sql
  CREATE EXTENSION IF NOT EXISTS vector;
  
  -- Add vector column (typically 1536 dimensions for OpenAI embeddings)
  ALTER TABLE public.dax_entry 
    ADD COLUMN body_embedding vector(1536);
  
  -- HNSW index for fast similarity search
  CREATE INDEX idx_dax_entry_body_embedding ON public.dax_entry 
    USING hnsw (body_embedding vector_cosine_ops);
  ```
- **Query Example**:
  ```sql
  -- Find similar entries (cosine similarity)
  WHERE body_embedding <-> '[0.1, 0.2, ...]'::vector < 0.5
  
  -- Or using embedding from another entry
  SELECT * FROM dax_entry 
  ORDER BY body_embedding <=> (SELECT body_embedding FROM dax_entry WHERE id = 123)
  LIMIT 10;
  ```

#### Option C: Hybrid Approach (Both tsvector + vector)
- **What**: Use both full-text and vector search
- **Use Cases**: Best of both worlds - keyword AND semantic search
- **Pros**: Flexible, supports different query types
- **Cons**: More storage, more complex queries

---

## Recommended Strategy

### Phase 1: Essential Indexes (Start Here)
```sql
-- Timestamps (always useful)
CREATE INDEX idx_dax_entry_created_at ON public.dax_entry (created_at DESC);
CREATE INDEX idx_dax_entry_updated_at ON public.dax_entry (updated_at DESC);

-- Heading with trigram (fuzzy search)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_dax_entry_heading_trgm ON public.dax_entry 
  USING GIN (heading gin_trgm_ops);

-- Body with full-text search (keyword-based)
ALTER TABLE public.dax_entry 
  ADD COLUMN body_tsvector tsvector 
  GENERATED ALWAYS AS (to_tsvector('english', coalesce(body, ''))) STORED;

CREATE INDEX idx_dax_entry_body_tsvector ON public.dax_entry 
  USING GIN (body_tsvector);
```

### Phase 2: Add Vector Search (For Semantic Search)
```sql
CREATE EXTENSION IF NOT EXISTS vector;

-- Add embedding column
ALTER TABLE public.dax_entry 
  ADD COLUMN body_embedding vector(1536);  -- Adjust dimensions to your embedding model

-- Create HNSW index for fast similarity search
CREATE INDEX idx_dax_entry_body_embedding ON public.dax_entry 
  USING hnsw (body_embedding vector_cosine_ops);
```

---

## Additional Considerations

### Composite Indexes
If you frequently filter by multiple fields:
```sql
-- Example: Search by vault + date range
CREATE INDEX idx_dax_entry_vault_created ON public.dax_entry (vault_id, created_at DESC);

-- Example: Search by vault + heading similarity
-- (Less common, trigram indexes work well independently)
```

### Foreign Key Index
Don't forget the `vault_id` foreign key:
```sql
CREATE INDEX idx_dax_entry_vault_id ON public.dax_entry (vault_id);
```

### Generated Columns Summary
- **body_tsvector**: Generated column for full-text search (auto-updated)
- **body_embedding**: Regular column for vector embeddings (requires application-level generation)

### Embedding Generation
For vector embeddings, you'll need to:
1. Generate embeddings when inserting/updating entries (via trigger or application code)
2. Use an embedding service (OpenAI `text-embedding-3-small/large`, local model, etc.)
3. Update the `body_embedding` column with the generated vector

---

## Query Performance Notes

- **B-tree**: Excellent for range/sort queries, prefix searches
- **Trigram (GIN)**: Best for fuzzy text matching on short-medium text
- **Full-text (tsvector)**: Best for keyword/phrase search on longer text
- **Vector (HNSW)**: Best for semantic similarity search

You can use multiple approaches and combine them in queries for flexible search capabilities!
