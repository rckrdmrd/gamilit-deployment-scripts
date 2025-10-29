-- =====================================================
-- View: progress_tracking.user_progress_summary
-- Type: Normal View
-- Description: Vista resumen del progreso del usuario, consolidando estadísticas de gamificación
-- Purpose: Proporciona un resumen completo de las métricas de progreso de cada usuario
-- Created: 2025-10-27
-- =====================================================

DROP VIEW IF EXISTS progress_tracking.user_progress_summary CASCADE;

CREATE VIEW progress_tracking.user_progress_summary AS
SELECT
    user_id,
    level,
    total_xp,
    ml_coins,
    current_streak AS streak_days,
    current_streak,
    max_streak,
    exercises_completed,
    modules_completed,
    achievements_earned,
    total_time_spent,
    last_activity_at,
    created_at,
    updated_at
FROM gamification_system.user_stats us;

COMMENT ON VIEW progress_tracking.user_progress_summary IS 'Vista resumen del progreso del usuario, consolidando estadísticas de gamificación incluyendo XP, monedas, rachas y completados';
