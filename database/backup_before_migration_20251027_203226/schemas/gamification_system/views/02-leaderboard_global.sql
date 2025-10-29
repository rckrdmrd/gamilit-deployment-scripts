-- =====================================================
-- Materialized View: gamification_system.leaderboard_global
-- Type: Materialized View
-- Description: Clasificación global combinando XP, ML Coins y Rachas
-- Purpose: Ranking global usando fórmula ponderada: (XP * 1.0) + (Coins * 0.5) + (Streak * 100)
-- Refresh: Actualizado cada hora vía CRON job
-- Performance: Incluye índices en user_id (único), rank_position y global_score
-- Formula: global_score = total_xp * 1.0 + ml_coins_lifetime * 0.5 + current_streak * 100
-- Created: 2025-10-27
-- =====================================================

DROP MATERIALIZED VIEW IF EXISTS gamification_system.leaderboard_global CASCADE;

CREATE MATERIALIZED VIEW gamification_system.leaderboard_global AS
WITH ranked_users AS (
    SELECT
        us.user_id,
        p.full_name,
        p.avatar_url,
        us.total_xp,
        us.ml_coins_earned_total AS ml_coins_lifetime,
        us.current_streak,
        us.max_streak,
        ur.current_rank AS maya_rank,
        us.total_xp::numeric * 1.0 + us.ml_coins_earned_total::numeric * 0.5 + (us.current_streak * 100)::numeric AS global_score,
        us.updated_at AS last_updated
    FROM gamification_system.user_stats us
        JOIN auth_management.profiles p ON us.user_id = p.id
        LEFT JOIN gamification_system.user_ranks ur ON us.user_id = ur.user_id AND ur.is_current = true
    WHERE us.total_xp > 0 OR us.ml_coins_earned_total > 0 OR us.current_streak > 0
)
SELECT
    user_id,
    full_name,
    avatar_url,
    total_xp,
    ml_coins_lifetime,
    current_streak,
    max_streak,
    maya_rank,
    global_score,
    row_number() OVER (ORDER BY global_score DESC, user_id) AS rank_position,
    last_updated
FROM ranked_users
ORDER BY global_score DESC
WITH DATA;

-- =====================================================
-- Índices para optimización de consultas
-- =====================================================

-- Índice único en user_id para búsquedas por usuario
CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_global_user
ON gamification_system.leaderboard_global (user_id);

-- Índice en rank_position para consultas de ranking
CREATE INDEX IF NOT EXISTS idx_leaderboard_global_rank
ON gamification_system.leaderboard_global (rank_position);

-- Índice en global_score descendente para ordenamiento rápido
CREATE INDEX IF NOT EXISTS idx_leaderboard_global_score
ON gamification_system.leaderboard_global (global_score DESC);

-- =====================================================
-- Comando de actualización (ejecutado por CRON cada hora)
-- =====================================================
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.leaderboard_global;

COMMENT ON MATERIALIZED VIEW gamification_system.leaderboard_global IS 'Materialized view for global combined leaderboard rankings. Refreshed hourly via CRON.';
