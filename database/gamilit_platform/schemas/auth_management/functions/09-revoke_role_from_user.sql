-- =====================================================
-- Function: auth_management.revoke_role_from_user
-- Description: Revoca un rol de un usuario con validaciones
-- Priority: HIGH - Role management
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION auth_management.revoke_role_from_user(
    p_user_id uuid,
    p_role gamilit_role,
    p_revoked_by uuid DEFAULT NULL
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_id uuid;
    v_current_user_id uuid;
    v_old_data jsonb;
BEGIN
    -- Get current user
    v_current_user_id := COALESCE(p_revoked_by, gamilit.get_current_user_id());

    -- Only super admins can revoke roles
    IF NOT gamilit.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can revoke roles';
    END IF;

    -- Prevent revoking own super_admin role
    IF p_user_id = v_current_user_id AND p_role = 'super_admin' THEN
        RAISE EXCEPTION 'Cannot revoke own super_admin role';
    END IF;

    -- Get role record
    SELECT id, to_jsonb(user_roles.*) INTO v_role_id, v_old_data
    FROM auth_management.user_roles
    WHERE user_id = p_user_id
    AND role = p_role
    AND is_active = true;

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'User does not have this role or role is already inactive';
    END IF;

    -- Deactivate role (soft delete)
    UPDATE auth_management.user_roles
    SET
        is_active = false,
        revoked_by = v_current_user_id,
        revoked_at = NOW(),
        updated_at = NOW()
    WHERE id = v_role_id;

    -- Log audit event
    PERFORM audit_logging.log_audit_event(
        v_current_user_id,
        'REVOKE_ROLE',
        'auth_management.user_roles',
        v_role_id,
        v_old_data,
        jsonb_build_object(
            'user_id', p_user_id,
            'role', p_role,
            'is_active', false
        )
    );

    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to revoke role: %', SQLERRM;
        RETURN false;
END;
$$;

COMMENT ON FUNCTION auth_management.revoke_role_from_user IS 'Revoca un rol de un usuario (soft delete) con validaciones de seguridad y auditoría';

-- Grant permissions
GRANT EXECUTE ON FUNCTION auth_management.revoke_role_from_user TO gamilit_user;
