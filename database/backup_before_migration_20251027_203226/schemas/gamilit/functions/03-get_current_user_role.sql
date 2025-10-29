-- =====================================================
-- Function: gamilit.get_current_user_role
-- Description: Retorna el rol del usuario actual
-- Parameters: None
-- Returns: gamilit_role
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.get_current_user_role()
 RETURNS gamilit_role
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_role gamilit_role;
BEGIN
    SELECT role INTO v_role
    FROM auth_management.profiles
    WHERE id = gamilit.get_current_user_id();

    RETURN v_role;
END;
$function$

COMMENT ON FUNCTION gamilit.get_current_user_role() IS 'Retorna el rol del usuario actual';
