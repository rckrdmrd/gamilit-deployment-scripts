-- Function: educational_content.calculate_learning_path
-- Description: Calcula ruta de aprendizaje personalizada basada en progreso del usuario
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_max_items: INTEGER - Número máximo de items a retornar (default 5)
-- Returns: TABLE (item_type, item_id, item_name, difficulty_level, estimated_time_minutes, xp_reward, priority_score)
-- Example:
--   SELECT * FROM educational_content.calculate_learning_path('123e4567-e89b-12d3-a456-426614174000', 5);
-- Dependencies: gamification_system.user_stats, user_ranks, educational_content.modules, missions, progress_tracking.module_progress, mission_progress
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION educational_content.calculate_learning_path(
    p_user_id UUID,
    p_max_items INTEGER DEFAULT 5
)
RETURNS TABLE (
    item_type VARCHAR(20),
    item_id UUID,
    item_name VARCHAR(255),
    difficulty_level INTEGER,
    estimated_time_minutes INTEGER,
    xp_reward INTEGER,
    priority_score NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH user_progress AS (
        SELECT
            us.current_level,
            ur.current_rank
        FROM gamification_system.user_stats us
        JOIN gamification_system.user_ranks ur ON ur.user_id = us.user_id
        WHERE us.user_id = p_user_id
    ),
    incomplete_modules AS (
        SELECT
            'MODULE'::VARCHAR as item_type,
            m.id as item_id,
            m.title as item_name,
            m.difficulty_level,
            m.estimated_time_minutes,
            m.xp_reward,
            CASE
                WHEN mp.completion_percentage IS NULL THEN 100
                ELSE 100 - mp.completion_percentage
            END as priority
        FROM educational_content.modules m
        LEFT JOIN progress_tracking.module_progress mp
            ON mp.module_id = m.id AND mp.user_id = p_user_id
        WHERE (mp.is_completed IS NULL OR mp.is_completed = false)
          AND m.is_active = true
    ),
    incomplete_missions AS (
        SELECT
            'MISSION'::VARCHAR as item_type,
            mi.id as item_id,
            mi.title as item_name,
            mi.difficulty_level,
            mi.estimated_time_minutes,
            mi.xp_reward,
            CASE mi.mission_status
                WHEN 'ACTIVE' THEN 200
                WHEN 'AVAILABLE' THEN 150
                ELSE 100
            END as priority
        FROM educational_content.missions mi
        WHERE NOT EXISTS (
            SELECT 1 FROM progress_tracking.mission_progress mp
            WHERE mp.mission_id = mi.id
              AND mp.user_id = p_user_id
              AND mp.is_completed = true
        )
        AND mi.is_active = true
    )
    SELECT
        i.item_type,
        i.item_id,
        i.item_name,
        i.difficulty_level,
        i.estimated_time_minutes,
        i.xp_reward,
        i.priority::NUMERIC(5,2)
    FROM (
        SELECT * FROM incomplete_modules
        UNION ALL
        SELECT * FROM incomplete_missions
    ) i
    ORDER BY i.priority DESC, i.xp_reward DESC
    LIMIT p_max_items;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION educational_content.calculate_learning_path(UUID, INTEGER) IS
    'Calcula ruta de aprendizaje personalizada basada en progreso del usuario';

-- Grant permissions
GRANT EXECUTE ON FUNCTION educational_content.calculate_learning_path(UUID, INTEGER) TO authenticated;
