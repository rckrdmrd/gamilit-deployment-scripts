-- =====================================================
-- Function: gamilit.is_admin
-- Description: No description available
-- Parameters: None
-- Returns: boolean
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.is_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN gamilit.get_current_user_role() IN ('admin_teacher', 'super_admin');
END;
$function$
