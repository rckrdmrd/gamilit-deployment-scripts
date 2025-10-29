-- Function: gamification_system.process_daily_rewards
-- Description: Procesa y otorga recompensas diarias a usuarios activos basado en racha y actividad
-- Parameters: None
-- Returns: TABLE (user_id, streak_bonus, activity_bonus, total_rewarded)
-- Example:
--   SELECT * FROM gamification_system.process_daily_rewards();
-- Dependencies: gamification_system.user_stats
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.process_daily_rewards()
RETURNS TABLE (
    user_id UUID,
    streak_bonus INTEGER,
    activity_bonus INTEGER,
    total_rewarded INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH active_users AS (
        SELECT us.user_id, us.current_streak
        FROM gamification_system.user_stats us
        WHERE us.last_activity_date = CURRENT_DATE
    ),
    rewards AS (
        SELECT
            au.user_id,
            (au.current_streak * 10)::INTEGER as streak_bonus,
            50::INTEGER as activity_bonus,
            (au.current_streak * 10 + 50)::INTEGER as total_reward
        FROM active_users au
    )
    SELECT
        r.user_id,
        r.streak_bonus,
        r.activity_bonus,
        r.total_reward
    FROM rewards r;

    -- Aplicar recompensas
    UPDATE gamification_system.user_stats us
    SET ml_coins = ml_coins + (
        SELECT total_reward
        FROM (
            SELECT user_id, (current_streak * 10 + 50)::INTEGER as total_reward
            FROM gamification_system.user_stats
            WHERE last_activity_date = CURRENT_DATE
        ) calc
        WHERE calc.user_id = us.user_id
    )
    WHERE last_activity_date = CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION gamification_system.process_daily_rewards() IS
    'Procesa y otorga recompensas diarias a usuarios activos';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.process_daily_rewards() TO authenticated;
