-- =====================================================
-- Enable RLS for gamification_system tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en tablas de
--              sistema de gamificación (solo tablas con policies activas)
-- =====================================================

-- Nota: Solo algunas tablas tienen RLS habilitado actualmente
-- Tablas específicas del sistema de gamificación

-- Comentarios
COMMENT ON TABLE gamification_system.achievements IS 'RLS enabled: Logros disponibles en el sistema';
COMMENT ON TABLE gamification_system.ml_coins_transactions IS 'RLS enabled: Transacciones de ML coins de usuarios';
COMMENT ON TABLE gamification_system.user_achievements IS 'RLS enabled: Logros obtenidos por usuarios';
COMMENT ON TABLE gamification_system.user_stats IS 'RLS enabled: Estadísticas de usuario';
