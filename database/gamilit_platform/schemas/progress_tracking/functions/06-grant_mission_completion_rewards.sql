-- Function: progress_tracking.grant_mission_completion_rewards
-- Description: Otorga todas las recompensas y procesa logros al completar una misión
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_mission_id: UUID - ID de la misión completada
-- Returns: TABLE (xp_granted, coins_granted, achievements_unlocked, level_ups)
-- Example:
--   SELECT * FROM progress_tracking.grant_mission_completion_rewards('123e4567-e89b-12d3-a456-426614174000', 'mission-uuid');
-- Dependencies: educational_content.missions, gamification_system.calculate_mission_reward, user_stats, ml_coins_transactions, update_user_level, check_and_grant_achievements
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION progress_tracking.grant_mission_completion_rewards(
    p_user_id UUID,
    p_mission_id UUID
)
RETURNS TABLE (
    xp_granted INTEGER,
    coins_granted INTEGER,
    achievements_unlocked INTEGER,
    level_ups INTEGER
) AS $$
DECLARE
    v_mission RECORD;
    v_boosted_xp INTEGER;
    v_boosted_coins INTEGER;
    v_old_level INTEGER;
    v_new_level INTEGER;
    v_achievements_count INTEGER := 0;
BEGIN
    -- Obtener información de la misión
    SELECT xp_reward, ml_coins_reward
    INTO v_mission
    FROM educational_content.missions
    WHERE id = p_mission_id;

    -- Calcular recompensas con boosts
    SELECT final_xp, final_coins
    INTO v_boosted_xp, v_boosted_coins
    FROM gamification_system.calculate_mission_reward(
        p_user_id, p_mission_id, v_mission.xp_reward, v_mission.ml_coins_reward
    );

    -- Obtener nivel actual
    SELECT current_level INTO v_old_level
    FROM gamification_system.user_stats
    WHERE user_id = p_user_id;

    -- Otorgar XP y Coins
    UPDATE gamification_system.user_stats
    SET
        total_xp = total_xp + v_boosted_xp,
        ml_coins = ml_coins + v_boosted_coins,
        missions_completed = missions_completed + 1,
        updated_at = NOW()
    WHERE user_id = p_user_id;

    -- Registrar transacción de coins
    INSERT INTO gamification_system.ml_coins_transactions (
        user_id, amount, transaction_type, description, metadata
    ) VALUES (
        p_user_id,
        v_boosted_coins,
        'MISSION_COMPLETION',
        'Misión completada',
        jsonb_build_object('mission_id', p_mission_id)
    );

    -- Actualizar nivel
    SELECT new_level INTO v_new_level
    FROM gamification_system.update_user_level(p_user_id);

    -- Verificar achievements
    SELECT COUNT(*) INTO v_achievements_count
    FROM gamification_system.check_and_grant_achievements(
        p_user_id, 'MISSIONS_COMPLETED', 1
    );

    RETURN QUERY SELECT
        v_boosted_xp,
        v_boosted_coins,
        v_achievements_count,
        GREATEST(0, v_new_level - v_old_level)::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION progress_tracking.grant_mission_completion_rewards(UUID, UUID) IS
    'Otorga todas las recompensas y procesa logros al completar una misión';

-- Grant permissions
GRANT EXECUTE ON FUNCTION progress_tracking.grant_mission_completion_rewards(UUID, UUID) TO authenticated;
