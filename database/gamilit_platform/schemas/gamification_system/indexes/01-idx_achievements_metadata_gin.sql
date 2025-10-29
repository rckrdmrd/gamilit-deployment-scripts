-- =====================================================
-- GIN Index: idx_achievements_metadata_gin
-- Table: gamification_system.achievements
-- Column: metadata (JSONB)
-- Description: Índice GIN para búsqueda eficiente en metadata de achievements
-- Priority: HIGH - Performance optimization
-- Created: 2025-10-27
-- Modified: 2025-10-28 (Verified in 04-INDEXES.sql migration)
-- =====================================================

-- NOTE: Este índice también aparece en 04-INDEXES.sql (duplicado confirmado)
-- Ambas versiones son idénticas, por lo que IF NOT EXISTS previene conflictos

CREATE INDEX IF NOT EXISTS idx_achievements_metadata_gin
ON gamification_system.achievements
USING GIN (metadata);

COMMENT ON INDEX gamification_system.idx_achievements_metadata_gin IS 'Índice GIN para búsqueda eficiente en metadata de achievements';

-- =====================================================
-- Performance Improvement Example
-- =====================================================

/*
-- Search achievements by metadata (now uses GIN index)
SELECT *
FROM gamification_system.achievements
WHERE metadata @> '{"featured": true}';
*/
