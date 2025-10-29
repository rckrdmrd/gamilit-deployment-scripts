-- Function: progress_tracking.get_classroom_analytics
-- Description: Obtiene estadísticas y analytics completos de un classroom con rango de fechas
-- Parameters:
--   - p_classroom_id: UUID - ID del classroom
--   - p_date_from: TIMESTAMPTZ - Fecha inicio (default: 30 días atrás)
--   - p_date_to: TIMESTAMPTZ - Fecha fin (default: ahora)
-- Returns: TABLE (total_students, active_students, avg_completion_rate, total_missions_completed, total_xp_earned, avg_current_streak, top_performer_id, top_performer_name, top_performer_xp)
-- Example:
--   SELECT * FROM progress_tracking.get_classroom_analytics('classroom-uuid', NOW() - INTERVAL '30 days', NOW());
-- Dependencies: social_features.classroom_members, gamification_system.user_stats, progress_tracking.module_progress, auth.profiles
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION progress_tracking.get_classroom_analytics(
    p_classroom_id UUID,
    p_date_from TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days',
    p_date_to TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
    total_students INTEGER,
    active_students INTEGER,
    avg_completion_rate NUMERIC(5,2),
    total_missions_completed INTEGER,
    total_xp_earned BIGINT,
    avg_current_streak NUMERIC(5,2),
    top_performer_id UUID,
    top_performer_name VARCHAR(255),
    top_performer_xp BIGINT
) AS $$
BEGIN
    RETURN QUERY
    WITH classroom_students AS (
        SELECT user_id
        FROM social_features.classroom_members
        WHERE classroom_id = p_classroom_id
          AND joined_at BETWEEN p_date_from AND p_date_to
    ),
    student_stats AS (
        SELECT
            cs.user_id,
            us.total_xp,
            us.missions_completed,
            us.current_streak,
            us.last_activity_date
        FROM classroom_students cs
        JOIN gamification_system.user_stats us ON us.user_id = cs.user_id
    )
    SELECT
        COUNT(*)::INTEGER as total_students,
        COUNT(*) FILTER (WHERE last_activity_date >= CURRENT_DATE - 7)::INTEGER as active_students,
        AVG(
            (SELECT completion_percentage
             FROM progress_tracking.module_progress mp
             WHERE mp.user_id = ss.user_id
             LIMIT 1)
        )::NUMERIC(5,2) as avg_completion_rate,
        SUM(missions_completed)::INTEGER as total_missions_completed,
        SUM(total_xp)::BIGINT as total_xp_earned,
        AVG(current_streak)::NUMERIC(5,2) as avg_current_streak,
        (SELECT user_id FROM student_stats ORDER BY total_xp DESC LIMIT 1) as top_performer_id,
        (SELECT full_name FROM auth.profiles WHERE id = (SELECT user_id FROM student_stats ORDER BY total_xp DESC LIMIT 1)) as top_performer_name,
        (SELECT total_xp FROM student_stats ORDER BY total_xp DESC LIMIT 1) as top_performer_xp
    FROM student_stats ss;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION progress_tracking.get_classroom_analytics(UUID, TIMESTAMPTZ, TIMESTAMPTZ) IS
    'Obtiene estadísticas y analytics completos de un classroom';

-- Grant permissions
GRANT EXECUTE ON FUNCTION progress_tracking.get_classroom_analytics(UUID, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;
