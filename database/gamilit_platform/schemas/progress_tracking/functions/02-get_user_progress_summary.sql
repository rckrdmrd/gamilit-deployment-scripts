-- =====================================================
-- Function: progress_tracking.get_user_progress_summary
-- Description: Retorna resumen completo de progreso del usuario
-- Parameters: p_user_id uuid
-- Returns: record
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION progress_tracking.get_user_progress_summary(p_user_id uuid)
 RETURNS TABLE(total_modules integer, completed_modules integer, in_progress_modules integer, total_exercises_attempted integer, total_exercises_completed integer, average_score numeric, total_time_spent_hours numeric)
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT mp.module_id)::INTEGER as total_modules,
        COUNT(DISTINCT mp.module_id) FILTER (WHERE mp.status = 'completed')::INTEGER as completed_modules,
        COUNT(DISTINCT mp.module_id) FILTER (WHERE mp.status = 'in_progress')::INTEGER as in_progress_modules,
        COUNT(ea.id)::INTEGER as total_exercises_attempted,
        COUNT(ea.id) FILTER (WHERE ea.is_correct = true)::INTEGER as total_exercises_completed,
        AVG(ea.score)::NUMERIC(5,2) as average_score,
        EXTRACT(EPOCH FROM SUM(mp.time_spent))::NUMERIC / 3600 as total_time_spent_hours
    FROM progress_tracking.module_progress mp
    LEFT JOIN progress_tracking.exercise_attempts ea ON ea.user_id = mp.user_id
    WHERE mp.user_id = p_user_id;
END;
$function$;

COMMENT ON FUNCTION progress_tracking.get_user_progress_summary(p_user_id uuid) IS 'Retorna resumen completo de progreso del usuario';
