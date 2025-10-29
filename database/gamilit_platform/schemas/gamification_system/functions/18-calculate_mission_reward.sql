-- Function: gamification_system.calculate_mission_reward
-- Description: Calcula recompensas de misión con todos los multiplicadores activos (XP y Coins)
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_mission_id: UUID - ID de la misión
--   - p_base_xp: INTEGER - XP base de la misión
--   - p_base_coins: INTEGER - ML Coins base de la misión
-- Returns: TABLE (base_xp, base_coins, xp_multiplier, coins_multiplier, final_xp, final_coins, bonus_applied)
-- Example:
--   SELECT * FROM gamification_system.calculate_mission_reward('123e4567-e89b-12d3-a456-426614174000', 'mission-uuid', 100, 50);
-- Dependencies: gamification_system.active_boosts
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.calculate_mission_reward(
    p_user_id UUID,
    p_mission_id UUID,
    p_base_xp INTEGER,
    p_base_coins INTEGER
)
RETURNS TABLE (
    base_xp INTEGER,
    base_coins INTEGER,
    xp_multiplier NUMERIC(4,2),
    coins_multiplier NUMERIC(4,2),
    final_xp INTEGER,
    final_coins INTEGER,
    bonus_applied VARCHAR(200)
) AS $$
DECLARE
    v_xp_mult NUMERIC(4,2) := 1.0;
    v_coins_mult NUMERIC(4,2) := 1.0;
    v_bonus_desc TEXT := '';
BEGIN
    -- Aplicar boost de XP
    SELECT COALESCE(SUM(multiplier - 1.0), 0.0) + 1.0
    INTO v_xp_mult
    FROM gamification_system.active_boosts
    WHERE user_id = p_user_id
      AND boost_type = 'XP'
      AND is_active = true
      AND expires_at > NOW();

    -- Aplicar boost de Coins
    SELECT COALESCE(SUM(multiplier - 1.0), 0.0) + 1.0
    INTO v_coins_mult
    FROM gamification_system.active_boosts
    WHERE user_id = p_user_id
      AND boost_type = 'COINS'
      AND is_active = true
      AND expires_at > NOW();

    -- Construir descripción de bonus
    IF v_xp_mult > 1.0 THEN
        v_bonus_desc := 'XP Boost x' || v_xp_mult::TEXT;
    END IF;

    IF v_coins_mult > 1.0 THEN
        IF v_bonus_desc != '' THEN
            v_bonus_desc := v_bonus_desc || ', ';
        END IF;
        v_bonus_desc := v_bonus_desc || 'Coins Boost x' || v_coins_mult::TEXT;
    END IF;

    IF v_bonus_desc = '' THEN
        v_bonus_desc := 'Sin bonus activos';
    END IF;

    RETURN QUERY SELECT
        p_base_xp,
        p_base_coins,
        v_xp_mult,
        v_coins_mult,
        (p_base_xp * v_xp_mult)::INTEGER,
        (p_base_coins * v_coins_mult)::INTEGER,
        v_bonus_desc::VARCHAR;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION gamification_system.calculate_mission_reward(UUID, UUID, INTEGER, INTEGER) IS
    'Calcula recompensas de misión con todos los multiplicadores activos';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.calculate_mission_reward(UUID, UUID, INTEGER, INTEGER) TO authenticated;
