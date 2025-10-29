-- =====================================================
-- Indexes: gamification_system.achievement_categories
-- Description: Índices para optimizar consultas de categorías de logros
-- Table: gamification_system.achievement_categories
-- Created: 2025-10-28
-- =====================================================

-- Index: Categorías activas
CREATE INDEX IF NOT EXISTS idx_achievement_categories_active
    ON gamification_system.achievement_categories(is_active)
    WHERE is_active = true;

-- Index: Orden de visualización
CREATE INDEX IF NOT EXISTS idx_achievement_categories_display_order
    ON gamification_system.achievement_categories(display_order);

-- Index: Búsqueda por nombre
CREATE INDEX IF NOT EXISTS idx_achievement_categories_name
    ON gamification_system.achievement_categories(name);

-- Comments
COMMENT ON INDEX gamification_system.idx_achievement_categories_active IS 'Índice parcial para filtrar categorías activas';
COMMENT ON INDEX gamification_system.idx_achievement_categories_display_order IS 'Índice para ordenar categorías por orden de visualización';
COMMENT ON INDEX gamification_system.idx_achievement_categories_name IS 'Índice para búsqueda y validación por nombre de categoría';
