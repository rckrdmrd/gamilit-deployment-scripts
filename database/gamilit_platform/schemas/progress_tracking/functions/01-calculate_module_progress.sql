-- =====================================================
-- Function: progress_tracking.calculate_module_progress
-- Description: Calcula el porcentaje de progreso en un módulo
-- Parameters: p_user_id uuid, p_module_id uuid
-- Returns: numeric
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION progress_tracking.calculate_module_progress(p_user_id uuid, p_module_id uuid)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_total_exercises INTEGER;
    v_completed_exercises INTEGER;
    v_progress NUMERIC;
BEGIN
    -- Count total exercises in module
    SELECT COUNT(*)
    INTO v_total_exercises
    FROM educational_content.exercises
    WHERE module_id = p_module_id AND is_active = true;

    -- Count completed exercises by user
    SELECT COUNT(DISTINCT ea.exercise_id)
    INTO v_completed_exercises
    FROM progress_tracking.exercise_attempts ea
    JOIN educational_content.exercises e ON e.id = ea.exercise_id
    WHERE ea.user_id = p_user_id
      AND e.module_id = p_module_id
      AND ea.is_correct = true;

    -- Calculate percentage
    IF v_total_exercises = 0 THEN
        RETURN 0;
    END IF;

    v_progress := (v_completed_exercises::numeric / v_total_exercises::numeric) * 100;
    RETURN ROUND(v_progress, 2);
END;
$function$;

COMMENT ON FUNCTION progress_tracking.calculate_module_progress(p_user_id uuid, p_module_id uuid) IS 'Calcula el porcentaje de progreso en un módulo';
