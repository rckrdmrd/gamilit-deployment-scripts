-- Function: gamification_system.get_active_boosts
-- Description: Obtiene los boosts activos de un usuario con tiempo restante hasta expiración
-- Parameters:
--   - p_user_id: UUID - ID del usuario
-- Returns: TABLE (boost_id, boost_type, multiplier, source, activated_at, expires_at, time_remaining)
-- Example:
--   SELECT * FROM gamification_system.get_active_boosts('123e4567-e89b-12d3-a456-426614174000');
-- Dependencies: gamification_system.active_boosts
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.get_active_boosts(
    p_user_id UUID
)
RETURNS TABLE (
    boost_id UUID,
    boost_type VARCHAR(50),
    multiplier NUMERIC(4,2),
    source VARCHAR(100),
    activated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    time_remaining INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ab.id,
        ab.boost_type,
        ab.multiplier,
        ab.source,
        ab.activated_at,
        ab.expires_at,
        ab.expires_at - NOW() as time_remaining
    FROM gamification_system.active_boosts ab
    WHERE ab.user_id = p_user_id
      AND ab.is_active = true
      AND ab.expires_at > NOW()
    ORDER BY ab.expires_at ASC;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION gamification_system.get_active_boosts(UUID) IS
    'Retorna los boosts activos de un usuario con tiempo restante';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.get_active_boosts(UUID) TO authenticated;
