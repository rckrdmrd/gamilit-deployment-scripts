-- Function: gamification_system.check_streak
-- Description: Verifica y actualiza la racha de días consecutivos del usuario con bonus XP
-- Parameters:
--   - p_user_id: UUID - ID del usuario
-- Returns: TABLE (current_streak, longest_streak, streak_maintained, bonus_xp)
-- Example:
--   SELECT * FROM gamification_system.check_streak('123e4567-e89b-12d3-a456-426614174000');
-- Dependencies: gamification_system.user_stats
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.check_streak(
    p_user_id UUID
)
RETURNS TABLE (
    current_streak INTEGER,
    longest_streak INTEGER,
    streak_maintained BOOLEAN,
    bonus_xp INTEGER
) AS $$
DECLARE
    v_last_activity DATE;
    v_current_streak INTEGER;
    v_longest_streak INTEGER;
    v_streak_maintained BOOLEAN := false;
    v_bonus_xp INTEGER := 0;
BEGIN
    -- Obtener información de racha actual
    SELECT
        last_activity_date,
        us.current_streak,
        us.longest_streak
    INTO v_last_activity, v_current_streak, v_longest_streak
    FROM gamification_system.user_stats us
    WHERE us.user_id = p_user_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Verificar racha
    IF v_last_activity = CURRENT_DATE THEN
        -- Ya registró actividad hoy
        v_streak_maintained := true;
    ELSIF v_last_activity = CURRENT_DATE - INTERVAL '1 day' THEN
        -- Mantiene racha
        v_current_streak := v_current_streak + 1;
        v_streak_maintained := true;

        -- Bonus XP por racha (10 XP por cada día de racha)
        v_bonus_xp := v_current_streak * 10;

        -- Actualizar racha y otorgar bonus
        UPDATE gamification_system.user_stats
        SET
            current_streak = v_current_streak,
            longest_streak = GREATEST(longest_streak, v_current_streak),
            last_activity_date = CURRENT_DATE,
            total_xp = total_xp + v_bonus_xp,
            updated_at = NOW()
        WHERE user_id = p_user_id;

        v_longest_streak := GREATEST(v_longest_streak, v_current_streak);
    ELSE
        -- Racha rota
        v_current_streak := 1;
        v_streak_maintained := false;

        UPDATE gamification_system.user_stats
        SET
            current_streak = 1,
            last_activity_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = p_user_id;
    END IF;

    RETURN QUERY SELECT
        v_current_streak,
        v_longest_streak,
        v_streak_maintained,
        v_bonus_xp;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION gamification_system.check_streak(UUID) IS
    'Verifica y actualiza la racha de días consecutivos del usuario';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.check_streak(UUID) TO authenticated;
