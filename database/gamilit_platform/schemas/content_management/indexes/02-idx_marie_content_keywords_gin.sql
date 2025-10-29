-- =====================================================
-- GIN Index: idx_marie_content_keywords_gin
-- Table: content_management.marie_curie_content
-- Column: keywords (ARRAY)
-- Description: Índice GIN para búsqueda por keywords (array)
-- Priority: HIGH - Performance optimization
-- Created: 2025-10-27
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_marie_content_keywords_gin
ON content_management.marie_curie_content
USING GIN (keywords);

COMMENT ON INDEX content_management.idx_marie_content_keywords_gin IS 'Índice GIN para búsqueda por keywords (array)';

-- =====================================================
-- Performance Improvement Example
-- =====================================================

/*
-- Search content by keyword (now uses GIN index)
SELECT *
FROM content_management.marie_curie_content
WHERE keywords @> ARRAY['science', 'physics'];
*/
