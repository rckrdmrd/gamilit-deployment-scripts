-- ============================================================================
-- Script: 01-initialize-user-gamification.sql
-- Descripción: Inicializa automáticamente user_stats y user_ranks para todos
--              los usuarios existentes en auth.users
-- Schema: gamification_system
-- Fecha: 2025-10-28
-- ============================================================================

BEGIN;

-- ============================================================================
-- INICIALIZAR USER_STATS
-- ============================================================================

INSERT INTO gamification_system.user_stats (
    user_id,
    tenant_id,
    level,
    total_xp,
    xp_to_next_level,
    ml_coins,
    ml_coins_earned_total,
    ml_coins_spent_total,
    current_streak,
    max_streak,
    days_active_total,
    exercises_completed,
    modules_completed,
    total_score,
    average_score,
    achievements_earned,
    certificates_earned,
    sessions_count,
    weekly_xp,
    monthly_xp,
    weekly_exercises
)
SELECT
    u.id,                           -- user_id de auth.users
    p.tenant_id,                    -- tenant del profile
    1,                              -- level inicial
    0,                              -- total_xp
    100,                            -- xp_to_next_level
    100,                            -- ml_coins iniciales
    100,                            -- ml_coins_earned_total
    0,                              -- ml_coins_spent_total
    0,                              -- current_streak
    0,                              -- max_streak
    0,                              -- days_active_total
    0,                              -- exercises_completed
    0,                              -- modules_completed
    0,                              -- total_score
    0.0,                            -- average_score
    0,                              -- achievements_earned
    0,                              -- certificates_earned
    0,                              -- sessions_count
    0,                              -- weekly_xp
    0,                              -- monthly_xp
    0                               -- weekly_exercises
FROM auth.users u
LEFT JOIN auth_management.profiles p ON u.id = p.user_id
WHERE u.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM gamification_system.user_stats us
    WHERE us.user_id = u.id
  );

-- ============================================================================
-- INICIALIZAR USER_RANKS
-- ============================================================================

INSERT INTO gamification_system.user_ranks (
    user_id,
    tenant_id,
    current_rank,
    previous_rank,
    rank_progress_percentage,
    modules_required_for_next,
    modules_completed_for_rank,
    xp_required_for_next,
    xp_earned_for_rank,
    ml_coins_bonus,
    is_current,
    achieved_at
)
SELECT
    u.id,                           -- user_id de auth.users
    p.tenant_id,                    -- tenant del profile
    'MERCENARIO'::maya_rank,        -- Rango inicial (el más bajo)
    NULL,                           -- previous_rank (no tiene previo)
    0,                              -- rank_progress_percentage
    2,                              -- módulos requeridos para GUERRERO
    0,                              -- módulos completados
    500,                            -- XP requerido para GUERRERO
    0,                              -- XP ganado en este rango
    0,                              -- bonus de ML Coins
    true,                           -- es el rango actual
    gamilit.now_mexico()            -- achieved_at
FROM auth.users u
LEFT JOIN auth_management.profiles p ON u.id = p.user_id
WHERE u.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM gamification_system.user_ranks ur
    WHERE ur.user_id = u.id AND ur.is_current = true
  );

COMMIT;

-- Verificar resultados
DO $$
DECLARE
    stats_count INT;
    ranks_count INT;
    users_count INT;
BEGIN
    SELECT COUNT(*) INTO users_count FROM auth.users WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO stats_count FROM gamification_system.user_stats;
    SELECT COUNT(*) INTO ranks_count FROM gamification_system.user_ranks WHERE is_current = true;

    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '  Inicialización de Gamificación';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Usuarios totales:    %', users_count;
    RAISE NOTICE 'User stats creados:  %', stats_count;
    RAISE NOTICE 'User ranks creados:  %', ranks_count;
    RAISE NOTICE '';

    IF stats_count = users_count AND ranks_count = users_count THEN
        RAISE NOTICE '✅ Todos los usuarios tienen stats y ranks inicializados';
    ELSE
        RAISE WARNING '⚠️ Algunos usuarios no tienen stats o ranks completos';
    END IF;
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
END $$;
