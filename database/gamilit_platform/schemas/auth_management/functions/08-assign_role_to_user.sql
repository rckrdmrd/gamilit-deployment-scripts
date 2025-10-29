-- =====================================================
-- Function: auth_management.assign_role_to_user
-- Description: Asigna un rol a un usuario con validaciones
-- Priority: HIGH - Role management
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION auth_management.assign_role_to_user(
    p_user_id uuid,
    p_role gamilit_role,
    p_permissions jsonb DEFAULT '{}'::jsonb,
    p_assigned_by uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_id uuid;
    v_tenant_id uuid;
    v_current_user_id uuid;
BEGIN
    -- Get current user
    v_current_user_id := COALESCE(p_assigned_by, gamilit.get_current_user_id());

    -- Only super admins can assign roles
    IF NOT gamilit.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can assign roles';
    END IF;

    -- Get user's tenant_id
    SELECT tenant_id INTO v_tenant_id
    FROM auth_management.profiles
    WHERE id = p_user_id;

    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'User profile not found';
    END IF;

    -- Check if user already has this role
    SELECT id INTO v_role_id
    FROM auth_management.user_roles
    WHERE user_id = p_user_id
    AND role = p_role
    AND is_active = true;

    IF v_role_id IS NOT NULL THEN
        RAISE EXCEPTION 'User already has this role';
    END IF;

    -- Insert new role
    INSERT INTO auth_management.user_roles (
        id,
        tenant_id,
        user_id,
        role,
        permissions,
        assigned_by,
        assigned_at,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        uuid_generate_v4(),
        v_tenant_id,
        p_user_id,
        p_role,
        p_permissions,
        v_current_user_id,
        NOW(),
        true,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_role_id;

    -- Log audit event
    PERFORM audit_logging.log_audit_event(
        v_current_user_id,
        'ASSIGN_ROLE',
        'auth_management.user_roles',
        v_role_id,
        NULL,
        jsonb_build_object(
            'user_id', p_user_id,
            'role', p_role,
            'permissions', p_permissions
        )
    );

    RETURN v_role_id;
END;
$$;

COMMENT ON FUNCTION auth_management.assign_role_to_user IS 'Asigna un rol a un usuario con validaciones de seguridad y auditoría';

-- Grant permissions
GRANT EXECUTE ON FUNCTION auth_management.assign_role_to_user TO gamilit_user;
