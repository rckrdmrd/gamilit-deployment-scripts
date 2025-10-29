-- =====================================================
-- GIN Index: idx_module_progress_analytics_gin
-- Table: progress_tracking.module_progress
-- Column: performance_analytics (JSONB)
-- Description: Índice GIN para análisis de performance sobre datos JSONB
-- Priority: HIGH - Performance optimization
-- Created: 2025-10-27
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_module_progress_analytics_gin
ON progress_tracking.module_progress
USING GIN (performance_analytics jsonb_path_ops);

COMMENT ON INDEX progress_tracking.idx_module_progress_analytics_gin IS 'Índice GIN para análisis de performance sobre datos JSONB';

-- =====================================================
-- Performance Improvement Example
-- =====================================================

/*
-- Query performance analytics (now uses GIN index)
SELECT *
FROM progress_tracking.module_progress
WHERE performance_analytics @> '{"accuracy": 90}';
*/
