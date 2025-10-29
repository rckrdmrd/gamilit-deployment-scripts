-- =====================================================
-- Function: gamification_system.calculate_xp_for_next_level
-- Description: Calcula XP necesaria para alcanzar el siguiente nivel
-- Parameters: p_current_level integer
-- Returns: integer
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamification_system.calculate_xp_for_next_level(p_current_level integer)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    RETURN (p_current_level * p_current_level * 100) - ((p_current_level - 1) * (p_current_level - 1) * 100);
END;
$function$

COMMENT ON FUNCTION gamification_system.calculate_xp_for_next_level(p_current_level integer) IS 'Calcula XP necesaria para alcanzar el siguiente nivel';
