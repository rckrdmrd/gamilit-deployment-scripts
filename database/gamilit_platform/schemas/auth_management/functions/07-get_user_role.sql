-- =====================================================
-- Function: auth_management.get_user_role
-- Description: Obtiene el rol más privilegiado de un usuario
-- Priority: CRITICAL - RLS policies dependency
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION auth_management.get_user_role(p_user_id uuid DEFAULT NULL)
RETURNS gamilit_role
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_role gamilit_role;
    v_user_id uuid;
BEGIN
    -- Use provided user_id or get current user
    v_user_id := COALESCE(p_user_id, gamilit.get_current_user_id());

    IF v_user_id IS NULL THEN
        RETURN 'student'::gamilit_role;
    END IF;

    -- Get highest privilege role (super_admin > admin_teacher > student)
    SELECT role INTO v_role
    FROM auth_management.user_roles
    WHERE user_id = v_user_id
    AND is_active = true
    ORDER BY
        CASE role
            WHEN 'super_admin' THEN 1
            WHEN 'admin_teacher' THEN 2
            WHEN 'student' THEN 3
        END
    LIMIT 1;

    -- Default to student if no role found
    RETURN COALESCE(v_role, 'student'::gamilit_role);
END;
$$;

COMMENT ON FUNCTION auth_management.get_user_role IS 'Obtiene el rol más privilegiado de un usuario. Default: student';

-- Grant permissions
GRANT EXECUTE ON FUNCTION auth_management.get_user_role TO gamilit_user;
