-- =====================================================
-- Function: gamification_system.recalculate_level_on_xp_change
-- Description: Trigger function que recalcula automáticamente el nivel cuando cambia el XP
-- Parameters: None (trigger function)
-- Returns: trigger
-- Created: 2025-10-28
-- =====================================================

CREATE OR REPLACE FUNCTION gamification_system.recalculate_level_on_xp_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_new_level INTEGER;
BEGIN
    -- Calculate new level based on new XP using existing function
    v_new_level := gamification_system.calculate_level_from_xp(NEW.total_xp);

    -- Only update if level actually changed
    IF v_new_level != NEW.level THEN
        NEW.level := v_new_level;
    END IF;

    RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION gamification_system.recalculate_level_on_xp_change() IS 'Trigger function que recalcula automáticamente el nivel cuando cambia el XP';
