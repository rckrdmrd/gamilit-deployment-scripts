-- =====================================================
-- RLS Policies: auth_management.user_roles
-- Description: Row Level Security para proteger roles de usuario
-- Priority: CRITICAL - Security requirement
-- Created: 2025-10-27
-- =====================================================

-- Enable RLS
ALTER TABLE auth_management.user_roles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- SELECT Policies
-- =====================================================

-- Policy: Admins pueden ver todos los roles
CREATE POLICY "Admins can view all roles"
ON auth_management.user_roles
FOR SELECT
TO authenticated
USING (gamilit.is_admin());

-- Policy: Usuarios pueden ver solo su propio rol
CREATE POLICY "Users can view own role"
ON auth_management.user_roles
FOR SELECT
TO authenticated
USING (user_id = gamilit.get_current_user_id());

-- =====================================================
-- INSERT Policies
-- =====================================================

-- Policy: Solo super admins pueden insertar roles
CREATE POLICY "Only super admins can insert roles"
ON auth_management.user_roles
FOR INSERT
TO authenticated
WITH CHECK (
    gamilit.is_super_admin()
    AND tenant_id = (
        SELECT tenant_id
        FROM auth_management.profiles
        WHERE id = gamilit.get_current_user_id()
    )
);

-- =====================================================
-- UPDATE Policies
-- =====================================================

-- Policy: Solo super admins pueden actualizar roles
CREATE POLICY "Only super admins can update roles"
ON auth_management.user_roles
FOR UPDATE
TO authenticated
USING (gamilit.is_super_admin())
WITH CHECK (
    gamilit.is_super_admin()
    -- Prevent role escalation: can't grant higher role than current user has
    AND (
        role != 'super_admin'
        OR gamilit.is_super_admin()
    )
);

-- =====================================================
-- DELETE Policies
-- =====================================================

-- Policy: Solo super admins pueden eliminar roles
CREATE POLICY "Only super admins can delete roles"
ON auth_management.user_roles
FOR DELETE
TO authenticated
USING (
    gamilit.is_super_admin()
    -- Prevent self-deletion of super_admin role
    AND NOT (
        user_id = gamilit.get_current_user_id()
        AND role = 'super_admin'
    )
);

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON POLICY "Admins can view all roles" ON auth_management.user_roles IS 'Permite a admins ver todos los roles en su tenant';
COMMENT ON POLICY "Users can view own role" ON auth_management.user_roles IS 'Permite a usuarios ver solo su propio rol';
COMMENT ON POLICY "Only super admins can insert roles" ON auth_management.user_roles IS 'Solo super admins pueden asignar roles';
COMMENT ON POLICY "Only super admins can update roles" ON auth_management.user_roles IS 'Solo super admins pueden modificar roles, con prevención de escalación';
COMMENT ON POLICY "Only super admins can delete roles" ON auth_management.user_roles IS 'Solo super admins pueden eliminar roles, excepto su propio rol de super_admin';
