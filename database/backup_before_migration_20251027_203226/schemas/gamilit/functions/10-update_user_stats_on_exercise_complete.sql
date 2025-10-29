-- =====================================================
-- Function: gamilit.update_user_stats_on_exercise_complete
-- Description: Actualiza estadísticas de usuario al completar un ejercicio
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.update_user_stats_on_exercise_complete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.is_correct = true THEN
        -- Update user stats
        UPDATE gamification_system.user_stats
        SET
            exercises_completed = exercises_completed + 1,
            total_xp = total_xp + COALESCE(NEW.xp_earned, 0),
            ml_coins = ml_coins + COALESCE(NEW.ml_coins_earned, 0),
            ml_coins_earned_total = ml_coins_earned_total + COALESCE(NEW.ml_coins_earned, 0),
            last_activity_at = gamilit.now_mexico(),
            updated_at = gamilit.now_mexico()
        WHERE user_id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$function$

COMMENT ON FUNCTION gamilit.update_user_stats_on_exercise_complete() IS 'Actualiza estadísticas de usuario al completar un ejercicio';
