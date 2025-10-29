-- =====================================================
-- Indexes: gamification_system.active_boosts
-- Description: Índices para optimizar consultas de boosts activos
-- Table: gamification_system.active_boosts
-- Created: 2025-10-28
-- =====================================================

-- Index: Boosts por usuario
CREATE INDEX IF NOT EXISTS idx_active_boosts_user
    ON gamification_system.active_boosts(user_id);

-- Index: Boosts por fecha de expiración (solo activos)
CREATE INDEX IF NOT EXISTS idx_active_boosts_expires
    ON gamification_system.active_boosts(expires_at)
    WHERE is_active = true;

-- Index: Boosts por tipo (solo activos)
CREATE INDEX IF NOT EXISTS idx_active_boosts_type
    ON gamification_system.active_boosts(boost_type)
    WHERE is_active = true;

-- Index: Boosts por usuario y tipo
CREATE INDEX IF NOT EXISTS idx_active_boosts_user_type
    ON gamification_system.active_boosts(user_id, boost_type, is_active);

-- Index: Boosts activos por fecha de expiración
CREATE INDEX IF NOT EXISTS idx_active_boosts_active
    ON gamification_system.active_boosts(is_active, expires_at)
    WHERE is_active = true;

-- Comments
COMMENT ON INDEX gamification_system.idx_active_boosts_user IS 'Índice para consultar todos los boosts de un usuario';
COMMENT ON INDEX gamification_system.idx_active_boosts_expires IS 'Índice parcial para detectar boosts próximos a expirar';
COMMENT ON INDEX gamification_system.idx_active_boosts_type IS 'Índice parcial para filtrar por tipo de boost';
COMMENT ON INDEX gamification_system.idx_active_boosts_user_type IS 'Índice compuesto para consultas de usuario + tipo de boost';
COMMENT ON INDEX gamification_system.idx_active_boosts_active IS 'Índice para limpieza de boosts expirados';
