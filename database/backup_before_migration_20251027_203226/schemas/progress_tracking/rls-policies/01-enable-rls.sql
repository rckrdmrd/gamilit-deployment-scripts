-- =====================================================
-- Enable RLS for progress_tracking tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en todas las
--              tablas del schema progress_tracking
-- =====================================================

-- Tablas con RLS habilitado
ALTER TABLE progress_tracking.learning_sessions ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE progress_tracking.learning_sessions IS 'RLS enabled: Sesiones de aprendizaje de usuarios';
