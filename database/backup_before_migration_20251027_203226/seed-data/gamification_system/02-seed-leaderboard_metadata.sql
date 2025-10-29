-- =====================================================
-- Seed Data: gamification_system.leaderboard_metadata
-- Description: Configuración de leaderboards del sistema GAMILIT
-- Records: 4
-- Created: 2025-10-27
-- =====================================================

SET search_path TO gamification_system, public;

-- Truncate table (cuidado: elimina datos existentes)
TRUNCATE TABLE gamification_system.leaderboard_metadata CASCADE;

-- =====================================================
-- METADATA DE LEADERBOARDS
-- Configuración de las 4 tablas de clasificación del sistema
-- =====================================================

INSERT INTO gamification_system.leaderboard_metadata (
    view_name,
    last_refresh_at,
    total_users,
    refresh_duration_ms,
    created_at
) VALUES
-- Leaderboard de XP: Clasificación por experiencia acumulada
('leaderboard_xp', '2025-10-20 22:00:00.561927-06', 0, 14, '2025-10-20 21:48:33.489917-06'),

-- Leaderboard de ML Coins: Clasificación por monedas ganadas
('leaderboard_coins', '2025-10-20 22:00:00.572371-06', 3, 6, '2025-10-20 21:48:33.489917-06'),

-- Leaderboard de Rachas: Clasificación por días consecutivos de actividad
('leaderboard_streaks', '2025-10-20 22:00:00.581994-06', 1, 6, '2025-10-20 21:48:33.489917-06'),

-- Leaderboard Global: Clasificación general combinada
('leaderboard_global', '2025-10-20 22:00:00.591796-06', 3, 6, '2025-10-20 21:48:33.489917-06')

ON CONFLICT (view_name) DO UPDATE SET
    last_refresh_at = EXCLUDED.last_refresh_at,
    total_users = EXCLUDED.total_users,
    refresh_duration_ms = EXCLUDED.refresh_duration_ms;

-- =====================================================
-- NOTAS IMPORTANTES:
--
-- 1. Esta tabla mantiene metadata sobre los leaderboards materializados
-- 2. Los valores de last_refresh_at y total_users se actualizan automáticamente
--    mediante el sistema de refresh de vistas materializadas
-- 3. refresh_duration_ms indica el tiempo que tomó el último refresh en milisegundos
-- 4. Las 4 vistas corresponden a:
--    - leaderboard_xp: Top usuarios por experiencia
--    - leaderboard_coins: Top usuarios por ML Coins
--    - leaderboard_streaks: Top usuarios por rachas activas
--    - leaderboard_global: Clasificación combinada
-- 5. Esta metadata es para monitoreo y troubleshooting del sistema
-- =====================================================

-- =====================================================
-- Seed data para leaderboard_metadata completado
-- Total: 4 registros insertados/actualizados
-- =====================================================
