-- Function: gamification_system.update_user_level
-- Description: Actualiza el nivel del usuario basado en XP total y otorga recompensas por subir de nivel
-- Parameters:
--   - p_user_id: UUID - ID del usuario
-- Returns: TABLE (old_level, new_level, level_up, reward_coins)
-- Example:
--   SELECT * FROM gamification_system.update_user_level('123e4567-e89b-12d3-a456-426614174000');
-- Dependencies: gamification_system.user_stats, ml_coins_transactions
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.update_user_level(
    p_user_id UUID
)
RETURNS TABLE (
    old_level INTEGER,
    new_level INTEGER,
    level_up BOOLEAN,
    reward_coins INTEGER
) AS $$
DECLARE
    v_current_xp BIGINT;
    v_old_level INTEGER;
    v_new_level INTEGER;
    v_coins_reward INTEGER := 0;
BEGIN
    -- Obtener XP y nivel actual
    SELECT total_xp, current_level INTO v_current_xp, v_old_level
    FROM gamification_system.user_stats
    WHERE user_id = p_user_id;

    -- Calcular nuevo nivel (cada 1000 XP = 1 nivel)
    v_new_level := FLOOR(v_current_xp / 1000.0)::INTEGER + 1;

    -- Si hubo level up
    IF v_new_level > v_old_level THEN
        v_coins_reward := (v_new_level - v_old_level) * 100;

        -- Actualizar nivel y otorgar coins
        UPDATE gamification_system.user_stats
        SET
            current_level = v_new_level,
            ml_coins = ml_coins + v_coins_reward,
            updated_at = NOW()
        WHERE user_id = p_user_id;

        -- Registrar transacción de coins
        INSERT INTO gamification_system.ml_coins_transactions (
            user_id, amount, transaction_type, description
        ) VALUES (
            p_user_id,
            v_coins_reward,
            'LEVEL_UP',
            'Subiste al nivel ' || v_new_level
        );
    END IF;

    RETURN QUERY SELECT
        v_old_level,
        v_new_level,
        v_new_level > v_old_level,
        v_coins_reward;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION gamification_system.update_user_level(UUID) IS
    'Actualiza el nivel del usuario basado en XP total y otorga recompensas';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.update_user_level(UUID) TO authenticated;
