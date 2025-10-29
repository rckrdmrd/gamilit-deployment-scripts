-- Function: gamification_system.check_and_grant_achievements
-- Description: Verifica y otorga achievements automáticamente basados en eventos del usuario
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_event_type: VARCHAR(100) - Tipo de evento (MISSIONS_COMPLETED, TOTAL_XP, STREAK_DAYS, etc)
--   - p_event_value: INTEGER - Valor del evento (default 1)
-- Returns: TABLE (achievement_id, achievement_name, xp_granted, coins_granted)
-- Example:
--   SELECT * FROM gamification_system.check_and_grant_achievements('123e4567-e89b-12d3-a456-426614174000', 'MISSIONS_COMPLETED', 1);
-- Dependencies: gamification_system.achievements, user_achievements, user_stats, ml_coins_transactions
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.check_and_grant_achievements(
    p_user_id UUID,
    p_event_type VARCHAR(100),
    p_event_value INTEGER DEFAULT 1
)
RETURNS TABLE (
    achievement_id UUID,
    achievement_name VARCHAR(100),
    xp_granted INTEGER,
    coins_granted INTEGER
) AS $$
DECLARE
    v_achievement RECORD;
    v_user_stats RECORD;
    v_condition_met BOOLEAN;
BEGIN
    -- Obtener estadísticas del usuario
    SELECT * INTO v_user_stats
    FROM gamification_system.user_stats
    WHERE user_id = p_user_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Iterar sobre achievements activos no otorgados
    FOR v_achievement IN
        SELECT a.id, a.name, a.condition_type, a.condition_value,
               a.xp_reward, a.ml_coins_reward
        FROM gamification_system.achievements a
        WHERE a.is_active = true
          AND a.condition_type = p_event_type
          AND NOT EXISTS (
              SELECT 1 FROM gamification_system.user_achievements ua
              WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id
          )
    LOOP
        v_condition_met := false;

        -- Evaluar condición según tipo
        CASE v_achievement.condition_type
            WHEN 'MISSIONS_COMPLETED' THEN
                v_condition_met := v_user_stats.missions_completed >= v_achievement.condition_value;
            WHEN 'TOTAL_XP' THEN
                v_condition_met := v_user_stats.total_xp >= v_achievement.condition_value;
            WHEN 'STREAK_DAYS' THEN
                v_condition_met := v_user_stats.current_streak >= v_achievement.condition_value;
            WHEN 'ACHIEVEMENTS_EARNED' THEN
                v_condition_met := v_user_stats.achievements_earned >= v_achievement.condition_value;
            ELSE
                v_condition_met := p_event_value >= v_achievement.condition_value;
        END CASE;

        -- Si la condición se cumple, otorgar achievement
        IF v_condition_met THEN
            -- Insertar achievement otorgado
            INSERT INTO gamification_system.user_achievements (
                user_id, achievement_id, earned_at
            ) VALUES (
                p_user_id, v_achievement.id, NOW()
            );

            -- Actualizar estadísticas del usuario
            UPDATE gamification_system.user_stats
            SET
                total_xp = total_xp + v_achievement.xp_reward,
                ml_coins = ml_coins + v_achievement.ml_coins_reward,
                achievements_earned = achievements_earned + 1,
                updated_at = NOW()
            WHERE user_id = p_user_id;

            -- Registrar transacción de coins
            IF v_achievement.ml_coins_reward > 0 THEN
                INSERT INTO gamification_system.ml_coins_transactions (
                    user_id, amount, transaction_type, description
                ) VALUES (
                    p_user_id,
                    v_achievement.ml_coins_reward,
                    'ACHIEVEMENT',
                    'Logro desbloqueado: ' || v_achievement.name
                );
            END IF;

            RETURN QUERY SELECT
                v_achievement.id,
                v_achievement.name,
                v_achievement.xp_reward,
                v_achievement.ml_coins_reward;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION gamification_system.check_and_grant_achievements(UUID, VARCHAR, INTEGER) IS
    'Verifica y otorga achievements basados en eventos del usuario';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.check_and_grant_achievements(UUID, VARCHAR, INTEGER) TO authenticated;
