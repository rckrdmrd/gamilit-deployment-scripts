-- =====================================================
-- Function: gamilit.is_super_admin
-- Description: Verifica si el usuario actual es super_admin
-- Parameters: None
-- Returns: boolean
-- Created: 2025-10-28
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.is_super_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN gamilit.get_current_user_role() = 'super_admin';
END;
$function$;

COMMENT ON FUNCTION gamilit.is_super_admin() IS 'Verifica si el usuario actual es super_admin';

GRANT EXECUTE ON FUNCTION gamilit.is_super_admin() TO gamilit_user;
