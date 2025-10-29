-- =====================================================
-- Indexes for: gamification_system.user_stats
-- Created: 2025-10-28
-- Description: Índices para optimización de leaderboards y rankings
-- =====================================================

-- ========================================
-- PERFORMANCE INDEXES - Created 2025-10-28
-- ========================================

-- Index: idx_user_stats_xp_desc
-- Purpose: Optimiza queries de leaderboard ordenados por XP
-- Type: BTREE DESC
-- Impact: Mejora significativa en consultas de ranking global por experiencia
-- Use Case: SELECT * FROM user_stats ORDER BY total_xp DESC LIMIT 100
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_stats_xp_desc
    ON gamification_system.user_stats(total_xp DESC);

COMMENT ON INDEX gamification_system.idx_user_stats_xp_desc IS
'Índice para leaderboard ordenado por XP descendente';

-- Index: idx_user_stats_rank_xp
-- Purpose: Optimiza queries de leaderboard filtrados por rango
-- Type: BTREE Composite
-- Impact: Permite búsquedas eficientes dentro de rangos específicos
-- Use Case: SELECT * FROM user_stats WHERE current_rank = 'GOLD' ORDER BY total_xp DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_stats_rank_xp
    ON gamification_system.user_stats(current_rank, total_xp DESC);

COMMENT ON INDEX gamification_system.idx_user_stats_rank_xp IS
'Índice compuesto para leaderboard filtrado por rango y ordenado por XP';

-- Index: idx_user_stats_coins_desc
-- Purpose: Optimiza queries de leaderboard ordenados por monedas
-- Type: BTREE DESC
-- Impact: Mejora consultas de ranking por riqueza de usuario
-- Use Case: SELECT * FROM user_stats ORDER BY ml_coins DESC LIMIT 100
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_stats_coins_desc
    ON gamification_system.user_stats(ml_coins DESC);

COMMENT ON INDEX gamification_system.idx_user_stats_coins_desc IS
'Índice para leaderboard ordenado por ML Coins descendente';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- Global XP Leaderboard (uses idx_user_stats_xp_desc)
SELECT
    user_id,
    total_xp,
    current_rank,
    ROW_NUMBER() OVER (ORDER BY total_xp DESC) as position
FROM gamification_system.user_stats
ORDER BY total_xp DESC
LIMIT 100;

-- Rank-filtered Leaderboard (uses idx_user_stats_rank_xp)
SELECT
    user_id,
    total_xp,
    current_rank
FROM gamification_system.user_stats
WHERE current_rank = 'PLATINUM'
ORDER BY total_xp DESC
LIMIT 50;

-- Wealth Leaderboard (uses idx_user_stats_coins_desc)
SELECT
    user_id,
    ml_coins,
    total_xp
FROM gamification_system.user_stats
ORDER BY ml_coins DESC
LIMIT 100;
*/
