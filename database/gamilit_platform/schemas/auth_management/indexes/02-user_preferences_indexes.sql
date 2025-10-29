-- =====================================================
-- Indexes: auth_management.user_preferences
-- Description: Índices para optimizar consultas de preferencias de usuario
-- Table: auth_management.user_preferences
-- Created: 2025-10-28
-- =====================================================

-- Index: Preferencias por tema
CREATE INDEX IF NOT EXISTS idx_user_preferences_theme
    ON auth_management.user_preferences(theme);

-- Index: Preferencias por idioma
CREATE INDEX IF NOT EXISTS idx_user_preferences_language
    ON auth_management.user_preferences(language);

-- Index: Usuarios sin tutorial completado (parcial)
CREATE INDEX IF NOT EXISTS idx_user_preferences_tutorial
    ON auth_management.user_preferences(tutorial_completed)
    WHERE tutorial_completed = false;

-- Index: Metadata JSON (GIN)
CREATE INDEX IF NOT EXISTS idx_user_preferences_preferences
    ON auth_management.user_preferences USING GIN(preferences);

-- Comments
COMMENT ON INDEX auth_management.idx_user_preferences_theme IS 'Índice para filtrar usuarios por tema preferido';
COMMENT ON INDEX auth_management.idx_user_preferences_language IS 'Índice para filtrar usuarios por idioma';
COMMENT ON INDEX auth_management.idx_user_preferences_tutorial IS 'Índice parcial para encontrar usuarios que no han completado el tutorial';
COMMENT ON INDEX auth_management.idx_user_preferences_preferences IS 'Índice GIN para búsquedas en preferencias JSON adicionales';
