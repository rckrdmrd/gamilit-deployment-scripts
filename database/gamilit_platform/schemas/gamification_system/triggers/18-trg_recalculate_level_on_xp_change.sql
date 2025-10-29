-- =====================================================
-- Trigger: trg_recalculate_level_on_xp_change
-- Description: Recalcula automáticamente el nivel cuando cambia total_xp
-- Table: gamification_system.user_stats
-- Created: 2025-10-28
-- =====================================================

CREATE TRIGGER trg_recalculate_level_on_xp_change
    BEFORE UPDATE OF total_xp
    ON gamification_system.user_stats
    FOR EACH ROW
    WHEN (NEW.total_xp IS DISTINCT FROM OLD.total_xp)
    EXECUTE FUNCTION gamification_system.recalculate_level_on_xp_change();

COMMENT ON TRIGGER trg_recalculate_level_on_xp_change ON gamification_system.user_stats IS 'Recalcula automáticamente el nivel cuando cambia total_xp';
