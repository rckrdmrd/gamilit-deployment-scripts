-- Function: progress_tracking.check_mechanic_completion
-- Description: Verifica el estado de completitud de una mecánica para un usuario
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_mechanic_id: UUID - ID de la mecánica
-- Returns: TABLE (is_completed, completion_percentage, exercises_completed, exercises_total, xp_earned, completed_at)
-- Example:
--   SELECT * FROM progress_tracking.check_mechanic_completion('123e4567-e89b-12d3-a456-426614174000', 'mechanic-uuid');
-- Dependencies: progress_tracking.mechanic_progress, educational_content.mechanics
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION progress_tracking.check_mechanic_completion(
    p_user_id UUID,
    p_mechanic_id UUID
)
RETURNS TABLE (
    is_completed BOOLEAN,
    completion_percentage NUMERIC(5,2),
    exercises_completed INTEGER,
    exercises_total INTEGER,
    xp_earned INTEGER,
    completed_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        mp.is_completed,
        mp.completion_percentage,
        mp.exercises_completed,
        mp.exercises_total,
        mp.xp_earned,
        mp.completed_at
    FROM progress_tracking.mechanic_progress mp
    WHERE mp.user_id = p_user_id
      AND mp.mechanic_id = p_mechanic_id;

    -- Si no existe registro, retornar valores por defecto
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            false,
            0.00::NUMERIC,
            0::INTEGER,
            (SELECT total_exercises FROM educational_content.mechanics WHERE id = p_mechanic_id),
            0::INTEGER,
            NULL::TIMESTAMPTZ;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION progress_tracking.check_mechanic_completion(UUID, UUID) IS
    'Verifica el estado de completitud de una mecánica para un usuario';

-- Grant permissions
GRANT EXECUTE ON FUNCTION progress_tracking.check_mechanic_completion(UUID, UUID) TO authenticated;
