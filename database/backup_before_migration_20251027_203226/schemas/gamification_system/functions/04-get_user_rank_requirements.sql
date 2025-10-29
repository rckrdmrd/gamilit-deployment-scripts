-- =====================================================
-- Function: gamification_system.get_user_rank_requirements
-- Description: Obtiene requisitos para el siguiente rango maya
-- Parameters: p_current_rank rango_maya
-- Returns: record
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamification_system.get_user_rank_requirements(p_current_rank rango_maya)
 RETURNS TABLE(next_rank rango_maya, modules_required integer, xp_required integer, ml_coins_bonus integer)
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        CASE p_current_rank
            WHEN 'nacom' THEN 'batab'::rango_maya
            WHEN 'batab' THEN 'holcatte'::rango_maya
            WHEN 'holcatte' THEN 'guerrero'::rango_maya
            WHEN 'guerrero' THEN 'mercenario'::rango_maya
            ELSE NULL::rango_maya
        END,
        CASE p_current_rank
            WHEN 'nacom' THEN 1      -- 1 módulo para BATAB
            WHEN 'batab' THEN 2      -- 2 módulos para HOLCATTE
            WHEN 'holcatte' THEN 3   -- 3 módulos para GUERRERO
            WHEN 'guerrero' THEN 5   -- 5 módulos para MERCENARIO
            ELSE 0
        END,
        CASE p_current_rank
            WHEN 'nacom' THEN 500
            WHEN 'batab' THEN 1500
            WHEN 'holcatte' THEN 3000
            WHEN 'guerrero' THEN 5000
            ELSE 0
        END,
        CASE p_current_rank
            WHEN 'nacom' THEN 100
            WHEN 'batab' THEN 250
            WHEN 'holcatte' THEN 500
            WHEN 'guerrero' THEN 1000
            ELSE 0
        END;
END;
$function$

COMMENT ON FUNCTION gamification_system.get_user_rank_requirements(p_current_rank rango_maya) IS 'Obtiene requisitos para el siguiente rango maya';
