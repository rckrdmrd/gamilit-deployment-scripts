-- =====================================================
-- Materialized View: gamification_system.leaderboard_coins
-- Type: Materialized View
-- Description: Clasificación de usuarios basada en ML Coins ganadas (lifetime total)
-- Purpose: Proporciona el ranking de usuarios ordenados por monedas ML ganadas históricamente
-- Refresh: Actualizado cada hora vía CRON job
-- Performance: Incluye índices en user_id (único) y rank_position para búsquedas rápidas
-- Created: 2025-10-27
-- =====================================================

DROP MATERIALIZED VIEW IF EXISTS gamification_system.leaderboard_coins CASCADE;

CREATE MATERIALIZED VIEW gamification_system.leaderboard_coins AS
SELECT
    us.user_id,
    p.full_name,
    p.avatar_url,
    us.ml_coins,
    us.ml_coins_earned_total AS ml_coins_lifetime,
    ur.current_rank AS maya_rank,
    row_number() OVER (ORDER BY us.ml_coins_earned_total DESC, us.user_id) AS rank_position,
    us.updated_at AS last_updated
FROM gamification_system.user_stats us
    JOIN auth_management.profiles p ON us.user_id = p.id
    LEFT JOIN gamification_system.user_ranks ur ON us.user_id = ur.user_id AND ur.is_current = true
WHERE us.ml_coins_earned_total > 0
ORDER BY us.ml_coins_earned_total DESC
WITH DATA;

-- =====================================================
-- Índices para optimización de consultas
-- =====================================================

-- Índice único en user_id para búsquedas por usuario
CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_coins_user
ON gamification_system.leaderboard_coins (user_id);

-- Índice en rank_position para consultas de ranking
CREATE INDEX IF NOT EXISTS idx_leaderboard_coins_rank
ON gamification_system.leaderboard_coins (rank_position);

-- =====================================================
-- Comando de actualización (ejecutado por CRON cada hora)
-- =====================================================
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.leaderboard_coins;

COMMENT ON MATERIALIZED VIEW gamification_system.leaderboard_coins IS 'Materialized view for ML Coins leaderboard rankings. Refreshed hourly via CRON.';
