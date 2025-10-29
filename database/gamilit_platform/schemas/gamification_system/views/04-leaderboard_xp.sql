-- =====================================================
-- Materialized View: gamification_system.leaderboard_xp
-- Type: Materialized View
-- Description: Clasificación de usuarios basada en puntos de experiencia (XP)
-- Purpose: Ranking de usuarios ordenados por XP total acumulado
-- Refresh: Actualizado cada hora vía CRON job
-- Performance: Incluye índices en user_id (único) y rank_position
-- Created: 2025-10-27
-- =====================================================

DROP MATERIALIZED VIEW IF EXISTS gamification_system.leaderboard_xp CASCADE;

CREATE MATERIALIZED VIEW gamification_system.leaderboard_xp AS
SELECT
    us.user_id,
    p.full_name,
    p.avatar_url,
    us.total_xp,
    ur.current_rank AS maya_rank,
    us.level AS current_level,
    row_number() OVER (ORDER BY us.total_xp DESC, us.user_id) AS rank_position,
    us.updated_at AS last_updated
FROM gamification_system.user_stats us
    JOIN auth_management.profiles p ON us.user_id = p.id
    LEFT JOIN gamification_system.user_ranks ur ON us.user_id = ur.user_id AND ur.is_current = true
WHERE us.total_xp > 0
ORDER BY us.total_xp DESC
WITH DATA;

-- =====================================================
-- Índices para optimización de consultas
-- =====================================================

-- Índice único en user_id para búsquedas por usuario
CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_xp_user
ON gamification_system.leaderboard_xp (user_id);

-- Índice en rank_position para consultas de ranking
CREATE INDEX IF NOT EXISTS idx_leaderboard_xp_rank
ON gamification_system.leaderboard_xp (rank_position);

-- =====================================================
-- Comando de actualización (ejecutado por CRON cada hora)
-- =====================================================
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.leaderboard_xp;

COMMENT ON MATERIALIZED VIEW gamification_system.leaderboard_xp IS 'Materialized view for XP-based leaderboard rankings. Refreshed hourly via CRON.';
