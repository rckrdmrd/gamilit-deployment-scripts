-- Function: gamification_system.cleanup_expired_boosts
-- Description: Limpia boosts expirados marcándolos como inactivos en la tabla active_boosts
-- Parameters: None
-- Returns: TABLE (cleaned_count INTEGER, execution_time_ms INTEGER)
-- Example:
--   SELECT * FROM gamification_system.cleanup_expired_boosts();
-- Dependencies: gamification_system.active_boosts
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.cleanup_expired_boosts()
RETURNS TABLE (
    cleaned_count INTEGER,
    execution_time_ms INTEGER
) AS $$
DECLARE
    v_start_time TIMESTAMPTZ;
    v_affected_rows INTEGER;
BEGIN
    v_start_time := CLOCK_TIMESTAMP();

    UPDATE gamification_system.active_boosts
    SET is_active = false
    WHERE expires_at < NOW() AND is_active = true;

    GET DIAGNOSTICS v_affected_rows = ROW_COUNT;

    RETURN QUERY SELECT
        v_affected_rows,
        EXTRACT(MILLISECONDS FROM CLOCK_TIMESTAMP() - v_start_time)::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION gamification_system.cleanup_expired_boosts() IS
    'Limpia boosts expirados marcándolos como inactivos';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.cleanup_expired_boosts() TO authenticated;
