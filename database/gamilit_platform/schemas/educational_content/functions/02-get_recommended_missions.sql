-- Function: educational_content.get_recommended_missions
-- Description: Obtiene misiones recomendadas basadas en nivel y progreso del usuario
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_limit: INTEGER - Número de misiones a retornar (default 3)
-- Returns: TABLE (mission_id, mission_title, difficulty_level, xp_reward, ml_coins_reward, estimated_time_minutes, recommendation_reason)
-- Example:
--   SELECT * FROM educational_content.get_recommended_missions('123e4567-e89b-12d3-a456-426614174000', 3);
-- Dependencies: gamification_system.user_stats, user_ranks, educational_content.missions, progress_tracking.mission_progress
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION educational_content.get_recommended_missions(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 3
)
RETURNS TABLE (
    mission_id UUID,
    mission_title VARCHAR(255),
    difficulty_level INTEGER,
    xp_reward INTEGER,
    ml_coins_reward INTEGER,
    estimated_time_minutes INTEGER,
    recommendation_reason TEXT
) AS $$
DECLARE
    v_user_level INTEGER;
    v_user_rank maya_rank;
BEGIN
    -- Obtener nivel y rango del usuario
    SELECT us.current_level, ur.current_rank
    INTO v_user_level, v_user_rank
    FROM gamification_system.user_stats us
    JOIN gamification_system.user_ranks ur ON ur.user_id = us.user_id
    WHERE us.user_id = p_user_id;

    RETURN QUERY
    SELECT
        m.id,
        m.title,
        m.difficulty_level,
        m.xp_reward,
        m.ml_coins_reward,
        m.estimated_time_minutes,
        CASE
            WHEN m.difficulty_level = v_user_level THEN 'Perfecto para tu nivel'
            WHEN m.difficulty_level < v_user_level THEN 'Misión fácil - Completa rápido'
            WHEN m.difficulty_level > v_user_level THEN 'Desafío - Mayor recompensa'
            ELSE 'Misión recomendada'
        END as recommendation_reason
    FROM educational_content.missions m
    WHERE m.is_active = true
      AND m.mission_status IN ('AVAILABLE', 'ACTIVE')
      AND NOT EXISTS (
          SELECT 1 FROM progress_tracking.mission_progress mp
          WHERE mp.mission_id = m.id
            AND mp.user_id = p_user_id
            AND mp.is_completed = true
      )
      AND m.difficulty_level BETWEEN (v_user_level - 1) AND (v_user_level + 2)
    ORDER BY
        ABS(m.difficulty_level - v_user_level),
        m.xp_reward DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION educational_content.get_recommended_missions(UUID, INTEGER) IS
    'Obtiene misiones recomendadas basadas en nivel y progreso del usuario';

-- Grant permissions
GRANT EXECUTE ON FUNCTION educational_content.get_recommended_missions(UUID, INTEGER) TO authenticated;
