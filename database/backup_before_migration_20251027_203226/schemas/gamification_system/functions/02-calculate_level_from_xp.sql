-- =====================================================
-- Function: gamification_system.calculate_level_from_xp
-- Description: Calcula el nivel del usuario basado en XP total
-- Parameters: p_xp integer
-- Returns: integer
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamification_system.calculate_level_from_xp(p_xp integer)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    RETURN FLOOR(SQRT(p_xp::numeric / 100.0)) + 1;
END;
$function$

COMMENT ON FUNCTION gamification_system.calculate_level_from_xp(p_xp integer) IS 'Calcula el nivel del usuario basado en XP total';
