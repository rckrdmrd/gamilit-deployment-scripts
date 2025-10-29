-- =====================================================
-- Materialized View: gamification_system.leaderboard_streaks
-- Type: Materialized View
-- Description: Clasificación de usuarios basada en rachas actuales y máximas
-- Purpose: Ranking de usuarios ordenados por racha actual, con desempate por racha máxima
-- Refresh: Actualizado cada hora vía CRON job
-- Performance: Incluye índices en user_id (único) y rank_position
-- Ordering: current_streak DESC, max_streak DESC, user_id ASC
-- Created: 2025-10-27
-- =====================================================

DROP MATERIALIZED VIEW IF EXISTS gamification_system.leaderboard_streaks CASCADE;

CREATE MATERIALIZED VIEW gamification_system.leaderboard_streaks AS
SELECT
    us.user_id,
    p.full_name,
    p.avatar_url,
    us.current_streak,
    us.max_streak,
    ur.current_rank AS maya_rank,
    row_number() OVER (ORDER BY us.current_streak DESC, us.max_streak DESC, us.user_id) AS rank_position,
    us.updated_at AS last_updated
FROM gamification_system.user_stats us
    JOIN auth_management.profiles p ON us.user_id = p.id
    LEFT JOIN gamification_system.user_ranks ur ON us.user_id = ur.user_id AND ur.is_current = true
WHERE us.current_streak > 0
ORDER BY us.current_streak DESC, us.max_streak DESC
WITH DATA;

-- =====================================================
-- Índices para optimización de consultas
-- =====================================================

-- Índice único en user_id para búsquedas por usuario
CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_streaks_user
ON gamification_system.leaderboard_streaks (user_id);

-- Índice en rank_position para consultas de ranking
CREATE INDEX IF NOT EXISTS idx_leaderboard_streaks_rank
ON gamification_system.leaderboard_streaks (rank_position);

-- =====================================================
-- Comando de actualización (ejecutado por CRON cada hora)
-- =====================================================
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.leaderboard_streaks;

COMMENT ON MATERIALIZED VIEW gamification_system.leaderboard_streaks IS 'Materialized view for streak leaderboard rankings. Refreshed hourly via CRON.';
