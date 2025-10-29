-- =====================================================
-- GIN Index: idx_marie_content_grade_levels_gin
-- Table: content_management.marie_curie_content
-- Column: target_grade_levels (ARRAY)
-- Description: Índice GIN para filtrado por niveles de grado (array)
-- Priority: HIGH - Performance optimization
-- Created: 2025-10-27
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_marie_content_grade_levels_gin
ON content_management.marie_curie_content
USING GIN (target_grade_levels);

COMMENT ON INDEX content_management.idx_marie_content_grade_levels_gin IS 'Índice GIN para filtrado por niveles de grado (array)';

-- =====================================================
-- Performance Improvement Example
-- =====================================================

/*
-- Find content for specific grade level (now uses GIN index)
SELECT *
FROM content_management.marie_curie_content
WHERE target_grade_levels @> ARRAY[5];
*/
