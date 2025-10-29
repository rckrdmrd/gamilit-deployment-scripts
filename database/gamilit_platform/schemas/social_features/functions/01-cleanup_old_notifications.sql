-- Function: social_features.cleanup_old_notifications
-- Description: Limpia notificaciones leídas más antiguas que el período especificado
-- Parameters:
--   - p_days_to_keep: INTEGER - Número de días a mantener (default 30)
-- Returns: TABLE (deleted_count, oldest_kept_date)
-- Example:
--   SELECT * FROM social_features.cleanup_old_notifications(30);
-- Dependencies: social_features.notifications
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION social_features.cleanup_old_notifications(
    p_days_to_keep INTEGER DEFAULT 30
)
RETURNS TABLE (
    deleted_count INTEGER,
    oldest_kept_date TIMESTAMPTZ
) AS $$
DECLARE
    v_cutoff_date TIMESTAMPTZ;
    v_deleted INTEGER;
BEGIN
    v_cutoff_date := NOW() - (p_days_to_keep || ' days')::INTERVAL;

    DELETE FROM social_features.notifications
    WHERE created_at < v_cutoff_date
      AND is_read = true;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    RETURN QUERY SELECT
        v_deleted,
        v_cutoff_date;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION social_features.cleanup_old_notifications(INTEGER) IS
    'Limpia notificaciones leídas más antiguas que el período especificado';

-- Grant permissions
GRANT EXECUTE ON FUNCTION social_features.cleanup_old_notifications(INTEGER) TO authenticated;
