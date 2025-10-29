-- Function: gamification_system.apply_xp_boost
-- Description: Calcula XP con multiplicadores de boost aplicados, sin modificar la base de datos
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_base_xp: INTEGER - XP base a multiplicar
-- Returns: TABLE (base_xp, total_multiplier, boosted_xp, active_boosts_count)
-- Example:
--   SELECT * FROM gamification_system.apply_xp_boost('123e4567-e89b-12d3-a456-426614174000', 100);
-- Dependencies: gamification_system.active_boosts
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.apply_xp_boost(
    p_user_id UUID,
    p_base_xp INTEGER
)
RETURNS TABLE (
    base_xp INTEGER,
    total_multiplier NUMERIC(4,2),
    boosted_xp INTEGER,
    active_boosts_count INTEGER
) AS $$
DECLARE
    v_multiplier NUMERIC(4,2) := 1.0;
    v_boost_count INTEGER := 0;
BEGIN
    -- Calcular multiplicador total de XP
    SELECT
        COALESCE(SUM(multiplier - 1.0), 0.0) + 1.0,
        COUNT(*)
    INTO v_multiplier, v_boost_count
    FROM gamification_system.active_boosts
    WHERE user_id = p_user_id
      AND boost_type = 'XP'
      AND is_active = true
      AND expires_at > NOW();

    RETURN QUERY SELECT
        p_base_xp,
        v_multiplier,
        (p_base_xp * v_multiplier)::INTEGER,
        v_boost_count;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION gamification_system.apply_xp_boost(UUID, INTEGER) IS
    'Calcula XP con boosts aplicados sin modificar la base de datos';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.apply_xp_boost(UUID, INTEGER) TO authenticated;
