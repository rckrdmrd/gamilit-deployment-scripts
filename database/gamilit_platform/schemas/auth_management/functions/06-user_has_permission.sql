-- =====================================================
-- Function: auth_management.user_has_permission
-- Description: Verifica si un usuario tiene un permiso específico
-- Priority: CRITICAL - Authorization requirement
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION auth_management.user_has_permission(
    p_user_id uuid,
    p_permission text
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_has_permission boolean;
    v_is_super_admin boolean;
BEGIN
    -- Super admins have all permissions
    SELECT gamilit.is_super_admin() INTO v_is_super_admin;

    IF v_is_super_admin THEN
        RETURN true;
    END IF;

    -- Check if user has the specific permission in their role
    SELECT EXISTS (
        SELECT 1
        FROM auth_management.user_roles ur
        WHERE ur.user_id = p_user_id
        AND ur.is_active = true
        AND ur.permissions ? p_permission
    ) INTO v_has_permission;

    RETURN COALESCE(v_has_permission, false);
END;
$$;

COMMENT ON FUNCTION auth_management.user_has_permission IS 'Verifica si un usuario tiene un permiso específico. Super admins siempre retornan true.';

-- Grant permissions
GRANT EXECUTE ON FUNCTION auth_management.user_has_permission TO gamilit_user;
